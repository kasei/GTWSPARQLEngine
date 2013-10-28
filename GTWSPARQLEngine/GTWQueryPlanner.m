#import "GTWQueryPlanner.h"
#import <GTWSWBase/GTWTriple.h>
#import <GTWSWBase/GTWQuad.h>
#import <GTWSWBase/GTWVariable.h>
#import "GTWSPARQLEngine.h"

@implementation GTWQueryPlanner

- (GTWQueryPlanner*) init {
    if (self = [super init]) {
        self.bnodeCounter   = 0;
    }
    return self;
}

- (id<GTWTree,GTWQueryPlan>) queryPlanForAlgebra: (id<GTWTree>) algebra usingDataset: (id<GTWDataset>) dataset withModel: (id<GTWModel>) model optimize: (BOOL) opt {
    id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra usingDataset:dataset withModel:model];
    if (opt) {
        [plan computeScopeVariables];
    }
    return plan;
}

- (id<GTWTree,GTWQueryPlan>) queryPlanForAlgebra: (id<GTWTree>) algebra usingDataset: (id<GTWDataset>) dataset withModel: (id<GTWModel>) model {
    if (algebra == nil) {
        NSLog(@"trying to plan nil algebra");
        return nil;
    }
    id<GTWTriple> t;
    NSInteger count;
    NSArray* defaultGraphs;
    NSArray* list;
    
    // TODO: if any of these recursive calls fails and returns nil, we need to propogate that nil up the stack instead of having it crash when an array atempts to add the nil value
    if (algebra.type == kAlgebraDistinct || algebra.type == kAlgebraReduced) {
        if ([algebra.arguments count] != 1) {
            NSLog(@"DISTINCT/REDUCED must be 1-ary");
            return nil;
        }
        id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        if (!plan)
            return nil;
        return [[GTWQueryPlan alloc] initWithType:kPlanDistinct arguments:@[plan]];
    } else if (algebra.type == kAlgebraAsk) {
        if ([algebra.arguments count] != 1) {
            NSLog(@"ASK must be 1-ary");
            return nil;
        }
        id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        if (!plan)
            return nil;
        return [[GTWQueryPlan alloc] initWithType:kPlanAsk arguments:@[plan]];
    } else if (algebra.type == kAlgebraGroup) {
        if ([algebra.arguments count] != 1) {
            NSLog(@"Group must be 1-ary");
            return nil;
        }
        id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        if (!plan)
            return nil;
        return [[GTWQueryPlan alloc] initWithType:kPlanGroup treeValue: algebra.treeValue arguments:@[plan]];
    } else if (algebra.type == kAlgebraGraph) {
        if ([algebra.arguments count] != 1) {
            NSLog(@"GRAPH must be 1-ary");
            return nil;
        }
        id<GTWTree> graphtree   = algebra.value;
        id<GTWTerm> graph       = graphtree.value;
        if ([graph isKindOfClass:[GTWIRI class]]) {
            GTWDataset* newDataset  = [[GTWDataset alloc] initDatasetWithDefaultGraphs:@[graph]];
            id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:newDataset withModel:model];
            if (!plan)
                return nil;
            return [[GTWQueryPlan alloc] initWithType:kPlanGraph value: algebra.value arguments:@[plan]];
        } else {
            NSArray* graphs = [dataset availableGraphsFromModel:model];
            
            id<GTWTree,GTWQueryPlan> gplan     = nil;
            for (id<GTWTerm> g in graphs) {
                GTWDataset* newDataset  = [[GTWDataset alloc] initDatasetWithDefaultGraphs:@[g]];
                id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:newDataset withModel:model];
                if (!plan)
                    return nil;
                
                id<GTWTree> list   = [[GTWTree alloc] initWithType:kTreeList arguments:@[
                                                                                      [[GTWTree alloc] initWithType:kTreeNode value:g arguments:@[]],
                                                                                      graphtree,
                                                                                      ]];
                id<GTWTree, GTWQueryPlan> extend    = (id<GTWTree, GTWQueryPlan>) [[GTWTree alloc] initWithType:kPlanExtend treeValue:list arguments:@[plan]];
                if (gplan) {
                    gplan   = [[GTWQueryPlan alloc] initWithType:kPlanUnion arguments:@[gplan, extend]];
                } else {
                    gplan   = extend;
                }
            }
            return gplan;
        }
    } else if (algebra.type == kAlgebraUnion) {
        id<GTWQueryPlan> lhs    = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        id<GTWQueryPlan> rhs    = [self queryPlanForAlgebra:algebra.arguments[1] usingDataset:dataset withModel:model];
        if (!(lhs && rhs)) {
            NSLog(@"Failed to plan both sides of UNION");
            return nil;
        }
        return [[GTWQueryPlan alloc] initWithType:kPlanUnion arguments:@[lhs, rhs]];
    } else if (algebra.type == kAlgebraProject) {
        if ([algebra.arguments count] != 1) {
            NSLog(@"PROJECT must be 1-ary");
            return nil;
        }
        id<GTWQueryPlan> lhs    = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        if (!lhs) {
            NSLog(@"Failed to plan PROJECT sub-plan");
            return nil;
        }
        // TODO: need to convert kAlgebraExtend in algebra.treeValue[] to kPlanExtend
        id<GTWTree> list    = [self treeByPlanningSubTreesOf:algebra.treeValue usingDataset:dataset withModel:model];
        return [[GTWQueryPlan alloc] initWithType:kPlanProject treeValue: list arguments:@[lhs]];
    } else if (algebra.type == kAlgebraJoin || algebra.type == kTreeList) {
        if ([algebra.arguments count] == 0) {
            return [[GTWQueryPlan alloc] initWithType:kPlanEmpty arguments:@[]];
        } else if ([algebra.arguments count] == 1) {
            return [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        } else if ([algebra.arguments count] == 2) {
            id<GTWQueryPlan> lhs    = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
            id<GTWQueryPlan> rhs    = [self queryPlanForAlgebra:algebra.arguments[1] usingDataset:dataset withModel:model];
            if (!lhs || !rhs) {
                NSLog(@"Failed to plan both sides of JOIN");
                return nil;
            }
            return [[GTWQueryPlan alloc] initWithType:kPlanNLjoin arguments:@[lhs, rhs]];
        } else {
            id<GTWQueryPlan> lhs    = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
            id<GTWQueryPlan> rhs    = [self queryPlanForAlgebra:algebra.arguments[1] usingDataset:dataset withModel:model];
            if (!lhs || !rhs) {
                NSLog(@"Failed to plan both sides of %lu-way JOIN", [algebra.arguments count]);
                return nil;
            }
            id<GTWTree, GTWQueryPlan> plan   = [[GTWQueryPlan alloc] initWithType:kPlanNLjoin arguments:@[lhs, rhs]];
            for (NSUInteger i = 2; i < [algebra.arguments count]; i++) {
                id<GTWQueryPlan> rhs    = [self queryPlanForAlgebra:algebra.arguments[i] usingDataset:dataset withModel:model];
                if (!rhs) {
                    NSLog(@"Failed to plan JOIN branch");
                    return nil;
                }
                plan    = [[GTWQueryPlan alloc] initWithType:kPlanNLjoin arguments:@[plan, rhs]];
            }
            return plan;
        }
    } else if (algebra.type == kAlgebraMinus) {
        NSLog(@"MINUS must be 2-ary");
        if ([algebra.arguments count] != 2)
            return nil;
        // should probably have a new plan type for MINUS blocks
        return [[GTWQueryPlan alloc] initWithType:kPlanNLjoin value: @"minus" arguments:@[[self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model], [self queryPlanForAlgebra:algebra.arguments[1] usingDataset:dataset withModel:model]]];
    } else if (algebra.type == kAlgebraLeftJoin) {
        if ([algebra.arguments count] != 2) {
            NSLog(@"LEFT JOIN must be 2-ary");
            return nil;
        }
        id<GTWQueryPlan> lhs    = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        id<GTWQueryPlan> rhs    = [self queryPlanForAlgebra:algebra.arguments[1] usingDataset:dataset withModel:model];
        if (!lhs || !rhs) {
            NSLog(@"Failed to plan both sides of LEFT JOIN");
            return nil;
        }
        return [[GTWQueryPlan alloc] initWithType:kPlanNLjoin value: @"left" arguments:@[lhs, rhs]];
    } else if (algebra.type == kAlgebraBGP) {
        return [self planBGP: algebra.arguments usingDataset: dataset withModel:model];
    } else if (algebra.type == kAlgebraFilter) {
        if ([algebra.arguments count] != 1) {
            NSLog(@"FILTER must be 1-ary");
            return nil;
        }
        id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        if (!plan)
            return nil;
        id<GTWTree> expr    = [self treeByPlanningSubTreesOf:algebra.treeValue usingDataset:dataset withModel:model];
        return [[GTWQueryPlan alloc] initWithType:kPlanFilter treeValue: expr arguments:@[plan]];
    } else if (algebra.type == kAlgebraExtend) {
        if ([algebra.arguments count] > 1) {
            NSLog(@"EXTEND must be 0- or 1-ary");
            NSLog(@"Extend: %@", algebra);
            return nil;
        }
        id<GTWTree> pat = ([algebra.arguments count]) ? algebra.arguments[0] : nil;
        if (pat) {
            id<GTWTree,GTWQueryPlan> p   = [self queryPlanForAlgebra:pat usingDataset:dataset withModel:model];
            if (!p)
                return nil;
            id<GTWTree> expr    = [self treeByPlanningSubTreesOf:algebra.treeValue usingDataset:dataset withModel:model];
            return [[GTWQueryPlan alloc] initWithType:kPlanExtend treeValue: expr arguments:@[p]];
        } else {
            id<GTWQueryPlan> empty    = [[GTWQueryPlan alloc] initLeafWithType:kPlanEmpty value:nil pointer:NULL];
            id<GTWTree> expr    = [self treeByPlanningSubTreesOf:algebra.treeValue usingDataset:dataset withModel:model];
            return [[GTWQueryPlan alloc] initWithType:kPlanExtend treeValue: expr arguments:@[empty]];
        }
    } else if (algebra.type == kAlgebraSlice) {
        id<GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        id<GTWTree> offset      = algebra.arguments[1];
        id<GTWTree> limit       = algebra.arguments[2];
        return [[GTWQueryPlan alloc] initWithType:kPlanSlice arguments:@[plan, offset, limit]];
    } else if (algebra.type == kAlgebraOrderBy) {
        if ([algebra.arguments count] != 1)
            return nil;
        id<GTWTree> list    = [self treeByPlanningSubTreesOf:algebra.treeValue usingDataset:dataset withModel:model];
        id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset withModel:model];
        if (!plan)
            return nil;
        
        return [[GTWQueryPlan alloc] initWithType:kPlanOrder treeValue: list arguments:@[plan]];
    } else if (algebra.type == kTreeTriple) {
        t   = algebra.value;
        defaultGraphs   = [dataset defaultGraphs];
        count   = [defaultGraphs count];
        __block NSUInteger varID    = 0;
        __block NSMutableDictionary* bnodeMap   = [NSMutableDictionary dictionary];
        id<GTWTerm> (^mapBnodes)(id<GTWTerm> t) = ^id<GTWTerm>(id<GTWTerm> t){
            if ([t isKindOfClass:[GTWBlank class]]) {
                if ([bnodeMap objectForKey:t]) {
                    return [bnodeMap objectForKey:t];
                } else {
                    NSUInteger vid  = ++varID;
                    id<GTWTerm> v   = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@".b%lu", vid]];
                    [bnodeMap setObject:v forKey:t];
                    return v;
                }
            } else {
                return t;
            }
        };
        if (count == 0) {
            return [[GTWQueryPlan alloc] initWithType:kPlanEmpty arguments:@[]];
        } else if (count == 1) {
            return [[GTWQueryPlan alloc] initLeafWithType:kTreeQuad value: [[GTWQuad alloc] initWithSubject:mapBnodes(t.subject) predicate:mapBnodes(t.predicate) object:mapBnodes(t.object) graph:defaultGraphs[0]] pointer:NULL];
        } else {
            id<GTWTree,GTWQueryPlan> plan   = [[GTWQueryPlan alloc] initLeafWithType:kTreeQuad value: [[GTWQuad alloc] initWithSubject:mapBnodes(t.subject) predicate:mapBnodes(t.predicate) object:mapBnodes(t.object) graph:defaultGraphs[0]] pointer:NULL];
            NSInteger i;
            for (i = 1; i < count; i++) {
                plan    = [[GTWQueryPlan alloc] initWithType:kPlanUnion arguments:@[plan, [[GTWQueryPlan alloc] initLeafWithType:kTreeQuad value: [[GTWQuad alloc] initWithSubject:mapBnodes(t.subject) predicate:mapBnodes(t.predicate) object:mapBnodes(t.object) graph:defaultGraphs[i]] pointer:NULL]]];
            }
            return plan;
        }
    } else if (algebra.type == kTreePath) {
        return [self queryPlanForPathAlgebra:algebra usingDataset:dataset withModel:model];
    } else if (algebra.type == kTreeResultSet) {
        return (id<GTWTree, GTWQueryPlan>) algebra;
    } else {
        NSLog(@"cannot plan query algebra of type %@\n", [algebra treeTypeName]);
    }
    
    NSLog(@"returning nil query plan");
    return nil;
}

- (id<GTWTree>) treeByPlanningSubTreesOf: (id<GTWTree>) expr usingDataset: (id<GTWDataset>) dataset withModel: (id<GTWModel>) model {
    if (!expr)
        return nil;
    if (expr.type == kExprExists) {
        id<GTWTree> algebra = expr.arguments[0];
        id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra usingDataset:dataset withModel:model];
        return [[GTWTree alloc] initWithType:kExprExists arguments:@[plan]];
    } else if (expr.type == kExprNotExists) {
            id<GTWTree> algebra = expr.arguments[0];
            id<GTWTree,GTWQueryPlan> plan   = [self queryPlanForAlgebra:algebra usingDataset:dataset withModel:model];
            return [[GTWTree alloc] initWithType:kExprNotExists arguments:@[plan]];
    } else {
        NSMutableArray* arguments   = [NSMutableArray array];
        for (id<GTWTree> t in expr.arguments) {
            id<GTWTree> newt    = [self treeByPlanningSubTreesOf:t usingDataset:dataset withModel:model];
            [arguments addObject:newt];
        }
        id<GTWTree> tv  = [self treeByPlanningSubTreesOf:expr.treeValue usingDataset:dataset withModel:model];
        return [[[expr class] alloc] initWithType:expr.type value:expr.value treeValue:tv arguments:arguments];
    }
}

- (id<GTWTree,GTWQueryPlan>) queryPlanForPathAlgebra: (id<GTWTree>) algebra usingDataset: (id<GTWDataset>) dataset withModel: (id<GTWModel>) model {
    id<GTWTree> s       = algebra.arguments[0];
    id<GTWTree> path    = algebra.arguments[1];
    id<GTWTree> o       = algebra.arguments[2];
    return [self queryPlanForPath:path starting:s ending:o usingDataset:dataset withModel:model];
}

- (void) negationPath: (id<GTWTree>) path forwardPredicates: (NSMutableSet*) fwd inversePredicates: (NSMutableSet*) inv negate: (BOOL) negate {
    if (path.type == kPathInverse) {
        [self negationPath:path.arguments[0] forwardPredicates:fwd inversePredicates:inv negate:!negate];
        return;
    } else if (path.type == kPathOr) {
        [self negationPath:path.arguments[0] forwardPredicates:fwd inversePredicates:inv negate:negate];
        [self negationPath:path.arguments[1] forwardPredicates:fwd inversePredicates:inv negate:negate];
        return;
    } else if (path.type == kTreeNode) {
        if (negate) {
            [inv addObject:path.value];
        } else {
            [fwd addObject:path.value];
        }
    } else {
        return;
    }
        
}

- (id<GTWTree,GTWQueryPlan>) queryPlanForPath: (id<GTWTree>) path starting: (id<GTWTree>) s ending: (id<GTWTree>) o usingDataset: (id<GTWDataset>) dataset withModel: (id<GTWModel>) model {
    if (path.type == kPathSequence) {
        GTWVariable* b = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@"qp__%lu", self.bnodeCounter++]];
        id<GTWTree> blank   = [[GTWTree alloc] initWithType:kTreeNode value:b arguments:nil];
        id<GTWTree> first   = path.arguments[0];
        id<GTWTree> rest    = path.arguments[1];
        id<GTWTree> lhsPath = [[GTWTree alloc] initWithType:kTreePath arguments:@[s, first, blank]];
        id<GTWTree> rhsPath = [[GTWTree alloc] initWithType:kTreePath arguments:@[blank, rest, o]];
        id<GTWTree, GTWQueryPlan> lhs = [self queryPlanForPathAlgebra:lhsPath usingDataset:dataset withModel:model];
        id<GTWTree, GTWQueryPlan> rhs = [self queryPlanForPathAlgebra:rhsPath usingDataset:dataset withModel:model];
        if (!(lhs && rhs))
            return nil;
        return [[GTWQueryPlan alloc] initWithType:kPlanNLjoin arguments:@[lhs, rhs]];
    } else if (path.type == kPathOr) {
        id<GTWQueryPlan> lhs    = [self queryPlanForPath:path.arguments[0] starting:s ending:o usingDataset:dataset withModel:model];
        id<GTWQueryPlan> rhs    = [self queryPlanForPath:path.arguments[1] starting:s ending:o usingDataset:dataset withModel:model];
        return [[GTWQueryPlan alloc] initWithType:kPlanUnion arguments:@[lhs, rhs]];
    } else if (path.type == kPathNegate) {
        NSMutableSet* fwd   = [NSMutableSet set];
        NSMutableSet* inv   = [NSMutableSet set];
        [self negationPath:path.arguments[0] forwardPredicates:fwd inversePredicates:inv negate:NO];
        NSLog(@"%@\n%@", fwd, inv);
        NSMutableArray* plans   = [NSMutableArray array];
        NSArray* graphs     = [dataset defaultGraphs];
        id<GTWTree> graph   = [[GTWTree alloc] initWithType:kTreeNode value:graphs[0] arguments:nil];
        if ([fwd count]) {
            id<GTWTree> set     = [[GTWTree alloc] initWithType:kTreeSet value:fwd arguments:nil];
            id<GTWTree> plan    = [[GTWQueryPlan alloc] initWithType:kPlanNPSPath arguments:@[s, set, o, graph]];
            [plans addObject:plan];
        }
        if ([inv count]) {
            id<GTWTree> set     = [[GTWTree alloc] initWithType:kTreeSet value:inv arguments:nil];
            id<GTWTree> plan    = [[GTWQueryPlan alloc] initWithType:kPlanNPSPath arguments:@[s, set, o, graph]];
            [plans addObject:plan];
        }
        
        if ([plans count] > 1) {
            return [[GTWQueryPlan alloc] initWithType:kPlanUnion arguments:plans];
        } else {
            return plans[0];
        }
    } else if (path.type == kPathZeroOrOne) {
        GTWVariable* ts = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@".zm%lu", self.bnodeCounter++]];
        GTWVariable* to = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@".zm%lu", self.bnodeCounter++]];
        id<GTWTree> temps  = [[GTWTree alloc] initWithType:kTreeNode value:ts arguments:nil];
        id<GTWTree> tempo  = [[GTWTree alloc] initWithType:kTreeNode value:to arguments:nil];
        id<GTWTree, GTWQueryPlan> plan  = [self queryPlanForPath:path.arguments[0] starting:temps ending:tempo usingDataset:dataset withModel:model];
        NSArray* graphs     = [dataset defaultGraphs];
        NSMutableArray* graphsTrees = [NSMutableArray array];
        for (id<GTWTerm> g in graphs) {
            id<GTWTree> t   = [[GTWTree alloc] initWithType:kTreeNode value:g arguments:nil];
            [graphsTrees addObject:t];
        }
        id<GTWTree> activeGraphs    = [[GTWTree alloc] initWithType:kTreeList arguments:graphsTrees];
        id<GTWTree> list   = [[GTWTree alloc] initWithType:kTreeList arguments:@[ s, o, temps, tempo, activeGraphs ]];
        return [[GTWQueryPlan alloc] initWithType:kPlanZeroOrOnePath treeValue:list arguments:@[plan]];
    } else if (path.type == kPathZeroOrMore) {
        GTWVariable* ts = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@".zm%lu", self.bnodeCounter++]];
        GTWVariable* to = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@".zm%lu", self.bnodeCounter++]];
        id<GTWTree> temps  = [[GTWTree alloc] initWithType:kTreeNode value:ts arguments:nil];
        id<GTWTree> tempo  = [[GTWTree alloc] initWithType:kTreeNode value:to arguments:nil];
        id<GTWTree, GTWQueryPlan> plan  = [self queryPlanForPath:path.arguments[0] starting:temps ending:tempo usingDataset:dataset withModel:model];
        NSArray* graphs     = [dataset defaultGraphs];
        NSMutableArray* graphsTrees = [NSMutableArray array];
        for (id<GTWTerm> g in graphs) {
            id<GTWTree> t   = [[GTWTree alloc] initWithType:kTreeNode value:g arguments:nil];
            [graphsTrees addObject:t];
        }
        id<GTWTree> activeGraphs    = [[GTWTree alloc] initWithType:kTreeList arguments:graphsTrees];
        id<GTWTree> list   = [[GTWTree alloc] initWithType:kTreeList arguments:@[ s, o, temps, tempo, activeGraphs ]];
        return [[GTWQueryPlan alloc] initWithType:kPlanZeroOrMorePath treeValue:list arguments:@[plan]];
    } else if (path.type == kPathOneOrMore) {
        GTWVariable* ts = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@".zm%lu", self.bnodeCounter++]];
        GTWVariable* to = [[GTWVariable alloc] initWithValue:[NSString stringWithFormat:@".zm%lu", self.bnodeCounter++]];
        id<GTWTree> temps  = [[GTWTree alloc] initWithType:kTreeNode value:ts arguments:nil];
        id<GTWTree> tempo  = [[GTWTree alloc] initWithType:kTreeNode value:to arguments:nil];
        id<GTWTree, GTWQueryPlan> plan  = [self queryPlanForPath:path.arguments[0] starting:temps ending:tempo usingDataset:dataset withModel:model];
        NSArray* graphs     = [dataset defaultGraphs];
        NSMutableArray* graphsTrees = [NSMutableArray array];
        for (id<GTWTerm> g in graphs) {
            id<GTWTree> t   = [[GTWTree alloc] initWithType:kTreeNode value:g arguments:nil];
            [graphsTrees addObject:t];
        }
        id<GTWTree> activeGraphs    = [[GTWTree alloc] initWithType:kTreeList arguments:graphsTrees];
        id<GTWTree> list   = [[GTWTree alloc] initWithType:kTreeList arguments:@[ s, o, temps, tempo, activeGraphs ]];
        return [[GTWQueryPlan alloc] initWithType:kPlanOneOrMorePath treeValue:list arguments:@[plan]];
    } else if (path.type == kPathInverse) {
        id<GTWTree> p   = [[GTWTree alloc] initWithType:kTreePath arguments:@[o, path.arguments[0], s]];
        return [self queryPlanForPathAlgebra:p usingDataset:dataset withModel:model];
    } else if (path.type == kTreeNode) {
        id<GTWTerm> subj    = s.value;
        id<GTWTerm> pred    = path.value;
        id<GTWTerm> obj     = o.value;
        GTWTriple* t        = [[GTWTriple alloc] initWithSubject:subj predicate:pred object:obj];
        id<GTWTree> triple  = [[GTWTree alloc] initWithType:kTreeTriple value: t arguments:nil];
        return [self queryPlanForAlgebra:triple usingDataset:dataset withModel:model];
    } else {
        NSLog(@"Cannot plan property path <%@ %@>: %@", s, o, path);
        return nil;
    }
    return nil;
}

- (id<GTWTree,GTWQueryPlan>) queryPlanForAlgebra: (id<GTWTree>) algebra withModel: (id<GTWModel>) model {
    GTWDataset* dataset    = [[GTWDataset alloc] initDatasetWithDefaultGraphs:@[]];
    return [self queryPlanForAlgebra:algebra usingDataset:dataset withModel:model];
}

- (id<GTWTree,GTWQueryPlan>) planBGP: (NSArray*) triples usingDataset: (id<GTWDataset>) dataset withModel: (id<GTWModel>) model {
//    NSLog(@"planning BGP: %@\n", triples);
    NSArray* defaultGraphs   = [dataset defaultGraphs];
    NSInteger graphCount   = [defaultGraphs count];
    NSInteger i;
    id<GTWTree,GTWQueryPlan> plan;
    if (graphCount == 0) {
        return [[GTWQueryPlan alloc] initWithType:kPlanEmpty arguments:@[]];
    } else if ([triples count] == 0) {
        return [[GTWQueryPlan alloc] initWithType:kPlanEmpty arguments:@[]];
    } else {
        plan   = [self queryPlanForAlgebra:triples[0] usingDataset:dataset withModel:model];
        for (i = 1; i < [triples count]; i++) {
            id<GTWTree> triple  = triples[i];
            NSSet* projvars     = [triple annotationForKey:kProjectVariables];
            id<GTWTree,GTWQueryPlan> quad    = [self queryPlanForAlgebra:triples[i] usingDataset:dataset withModel:model];
            plan    = [[GTWQueryPlan alloc] initWithType:kPlanNLjoin arguments:@[plan, quad]];
        }
    }
    return plan;
}

@end
