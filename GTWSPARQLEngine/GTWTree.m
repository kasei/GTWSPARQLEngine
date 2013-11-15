#import "GTWTree.h"
#import "GTWSPARQLEngine.h"
#import <GTWSWBase/GTWVariable.h>
#import <GTWSWBase/GTWLiteral.h>
#import <GTWSWBase/GTWTriple.h>
#import "NSObject+GTWTree.h"

NSString* __strong const kUsedVariables     = @"us.kasei.sparql.variables.used";
NSString* __strong const kProjectVariables  = @"us.kasei.sparql.variables.project";

// Plans
GTWTreeType __strong const kPlanAsk                     = @"PlanAsk";
GTWTreeType __strong const kPlanEmpty					= @"PlanEmpty";
GTWTreeType __strong const kPlanScan					= @"PlanScan";
GTWTreeType __strong const kPlanBKAjoin					= @"PlanBKAjoin";
GTWTreeType __strong const kPlanHashJoin				= @"PlanHashJoin";
GTWTreeType __strong const kPlanNLjoin					= @"PlanNLjoin";
GTWTreeType __strong const kPlanNLLeftJoin				= @"PlanNLLeftJoin";
GTWTreeType __strong const kPlanProject					= @"PlanProject";
GTWTreeType __strong const kPlanFilter					= @"PlanFilter";
GTWTreeType __strong const kPlanUnion					= @"PlanUnion";
GTWTreeType __strong const kPlanExtend					= @"PlanExtend";
GTWTreeType __strong const kPlanMinus					= @"PlanMinus";
GTWTreeType __strong const kPlanOrder					= @"PlanOrder";
GTWTreeType __strong const kPlanDistinct				= @"PlanDistinct";
GTWTreeType __strong const kPlanGraph                   = @"PlanGraph";
GTWTreeType __strong const kPlanService                 = @"PlanService";
GTWTreeType __strong const kPlanSlice					= @"PlanSlice";
GTWTreeType __strong const kPlanJoinIdentity			= @"PlanJoinIdentity";
GTWTreeType __strong const kPlanFedStub					= @"PlanFedStub";
GTWTreeType __strong const kPlanDescribe				= @"PlanDescribe";
GTWTreeType __strong const kPlanGroup                   = @"PlanGroup";
GTWTreeType __strong const kPlanZeroOrMorePath          = @"PlanZeroOrMorePath";
GTWTreeType __strong const kPlanOneOrMorePath           = @"PlanOneOrMorePath";
GTWTreeType __strong const kPlanZeroOrOnePath           = @"PlanZeroOrOnePath";
GTWTreeType __strong const kPlanNPSPath                 = @"PlanNPS";
GTWTreeType __strong const kPlanConstruct               = @"PlanConstruct";

// Algebras
GTWTreeType __strong const kAlgebraAsk                  = @"AlgebraAsk";
GTWTreeType __strong const kAlgebraBGP					= @"AlgebraBGP";
GTWTreeType __strong const kAlgebraJoin					= @"AlgebraJoin";
GTWTreeType __strong const kAlgebraLeftJoin				= @"AlgebraLeftJoin";
GTWTreeType __strong const kAlgebraFilter				= @"AlgebraFilter";
GTWTreeType __strong const kAlgebraUnion				= @"AlgebraUnion";
GTWTreeType __strong const kAlgebraGraph				= @"AlgebraGraph";
GTWTreeType __strong const kAlgebraService				= @"AlgebraService";
GTWTreeType __strong const kAlgebraExtend				= @"AlgebraExtend";
GTWTreeType __strong const kAlgebraMinus				= @"AlgebraMinus";
GTWTreeType __strong const kAlgebraGroup				= @"AlgebraGroup";
GTWTreeType __strong const kAlgebraToList				= @"AlgebraToList";
GTWTreeType __strong const kAlgebraOrderBy				= @"AlgebraOrderBy";
GTWTreeType __strong const kAlgebraProject				= @"AlgebraProject";
GTWTreeType __strong const kAlgebraDistinct				= @"AlgebraDistinct";
GTWTreeType __strong const kAlgebraReduced				= @"AlgebraReduced";
GTWTreeType __strong const kAlgebraSlice				= @"AlgebraSlice";
GTWTreeType __strong const kAlgebraToMultiset			= @"AlgebraToMultiset";
GTWTreeType __strong const kAlgebraDescribe				= @"AlgebraDescribe";
GTWTreeType __strong const kAlgebraConstruct            = @"AlgebraConstruct";
GTWTreeType __strong const kAlgebraDataset              = @"AlgebraDataset";

// Leaving the tree value space
GTWTreeType __strong const kTreeSet						= @"TreeSet";
GTWTreeType __strong const kTreeList					= @"TreeList";
GTWTreeType __strong const kTreeDictionary				= @"TreeDictionary";
GTWTreeType __strong const kTreeAggregate				= @"TreeAggregate";
GTWTreeType __strong const kTreeTriple					= @"TreeTriple";
GTWTreeType __strong const kTreeQuad					= @"TreeQuad";
GTWTreeType __strong const kTreeExpression				= @"TreeExpression";
GTWTreeType __strong const kTreeNode					= @"TreeNode";
GTWTreeType __strong const kTreePath					= @"TreePath";
GTWTreeType __strong const kTreeOrderCondition			= @"TreeOrderCondition";
GTWTreeType __strong const kTreeSolutionSequence		= @"TreeSolutionSequence";
GTWTreeType __strong const kTreeString					= @"TreeString";

// Property Path types
GTWTreeType __strong const kPathIRI                     = @"link";
GTWTreeType __strong const kPathInverse                 = @"inv";
GTWTreeType __strong const kPathNegate                  = @"!";
GTWTreeType __strong const kPathSequence                = @"seq";
GTWTreeType __strong const kPathOr                      = @"alt";
GTWTreeType __strong const kPathZeroOrMore              = @"*";
GTWTreeType __strong const kPathOneOrMore               = @"+";
GTWTreeType __strong const kPathZeroOrOne               = @"?";

// Expressions
GTWTreeType __strong const kExprAnd						= @"ExprAnd";
GTWTreeType __strong const kExprOr						= @"ExprOr";
GTWTreeType __strong const kExprEq						= @"ExprEq";
GTWTreeType __strong const kExprNeq						= @"ExprNeq";
GTWTreeType __strong const kExprLt						= @"ExprLt";
GTWTreeType __strong const kExprGt						= @"ExprGt";
GTWTreeType __strong const kExprLe						= @"ExprLe";
GTWTreeType __strong const kExprGe						= @"ExprGe";
GTWTreeType __strong const kExprUMinus					= @"ExprUMinus";
GTWTreeType __strong const kExprPlus					= @"ExprPlus";
GTWTreeType __strong const kExprMinus					= @"ExprMinus";
GTWTreeType __strong const kExprMul                     = @"ExprMul";
GTWTreeType __strong const kExprDiv                     = @"ExprDiv";
GTWTreeType __strong const kExprBang					= @"ExprBang";
GTWTreeType __strong const kExprLiteral					= @"ExprLiteral";
GTWTreeType __strong const kExprFunction				= @"ExprFunction";
GTWTreeType __strong const kExprBound					= @"ExprBound";
GTWTreeType __strong const kExprStr						= @"ExprStr";
GTWTreeType __strong const kExprLang					= @"ExprLang";
GTWTreeType __strong const kExprDatatype				= @"ExprDatatype";
GTWTreeType __strong const kExprIsURI					= @"ExprIsURI";
GTWTreeType __strong const kExprIsBlank					= @"ExprIsBlank";
GTWTreeType __strong const kExprIsLiteral				= @"ExprIsLiteral";
GTWTreeType __strong const kExprCast					= @"ExprCast";
GTWTreeType __strong const kExprLangMatches				= @"ExprLangMatches";
GTWTreeType __strong const kExprRegex					= @"ExprRegex";
GTWTreeType __strong const kExprCount					= @"ExprCount";
GTWTreeType __strong const kExprSameTerm				= @"ExprSameTerm";
GTWTreeType __strong const kExprSum						= @"ExprSum";
GTWTreeType __strong const kExprAvg						= @"ExprAvg";
GTWTreeType __strong const kExprMin						= @"ExprMin";
GTWTreeType __strong const kExprMax						= @"ExprMax";
GTWTreeType __strong const kExprCoalesce				= @"ExprCoalesce";
GTWTreeType __strong const kExprIf						= @"ExprIf";
GTWTreeType __strong const kExprURI						= @"ExprURI";
GTWTreeType __strong const kExprIRI						= @"ExprIRI";
GTWTreeType __strong const kExprStrLang					= @"ExprStrLang";
GTWTreeType __strong const kExprStrDT					= @"ExprStrDT";
GTWTreeType __strong const kExprBNode					= @"ExprBNode";
GTWTreeType __strong const kExprGroupConcat				= @"ExprGroupConcat";
GTWTreeType __strong const kExprSample					= @"ExprSample";
GTWTreeType __strong const kExprIn						= @"ExprIn";
GTWTreeType __strong const kExprNotIn					= @"ExprNotIn";
GTWTreeType __strong const kExprIsNumeric				= @"ExprIsNumeric";
GTWTreeType __strong const kExprYear					= @"ExprYear";
GTWTreeType __strong const kExprMonth					= @"ExprMonth";
GTWTreeType __strong const kExprDay						= @"ExprDay";
GTWTreeType __strong const kExprHours					= @"ExprHours";
GTWTreeType __strong const kExprMinutes					= @"ExprMinutes";
GTWTreeType __strong const kExprSeconds					= @"ExprSeconds";
GTWTreeType __strong const kExprTimeZone				= @"ExprTimeZone";
GTWTreeType __strong const kExprCurrentDatetime			= @"ExprCurrentDatetime";
GTWTreeType __strong const kExprNow						= @"ExprNow";
GTWTreeType __strong const kExprFromUnixTime			= @"ExprFromUnixTime";
GTWTreeType __strong const kExprToUnixTime				= @"ExprToUnixTime";
GTWTreeType __strong const kExprConcat					= @"ExprConcat";
GTWTreeType __strong const kExprStrLen					= @"ExprStrLen";
GTWTreeType __strong const kExprSubStr					= @"ExprSubStr";
GTWTreeType __strong const kExprUCase					= @"ExprUCase";
GTWTreeType __strong const kExprLCase					= @"ExprLCase";
GTWTreeType __strong const kExprStrStarts				= @"ExprStrStarts";
GTWTreeType __strong const kExprStrEnds					= @"ExprStrEnds";
GTWTreeType __strong const kExprContains				= @"ExprContains";
GTWTreeType __strong const kExprEncodeForURI			= @"ExprEncodeForURI";
GTWTreeType __strong const kExprTZ						= @"ExprTZ";
GTWTreeType __strong const kExprRand					= @"ExprRand";
GTWTreeType __strong const kExprAbs						= @"ExprAbs";
GTWTreeType __strong const kExprRound					= @"ExprRound";
GTWTreeType __strong const kExprCeil					= @"ExprCeil";
GTWTreeType __strong const kExprFloor					= @"ExprFloor";
GTWTreeType __strong const kExprMD5						= @"ExprMD5";
GTWTreeType __strong const kExprSHA1					= @"ExprSHA1";
GTWTreeType __strong const kExprSHA224					= @"ExprSHA224";
GTWTreeType __strong const kExprSHA256					= @"ExprSHA256";
GTWTreeType __strong const kExprSHA384					= @"ExprSHA384";
GTWTreeType __strong const kExprSHA512					= @"ExprSHA512";
GTWTreeType __strong const kExprStrBefore				= @"ExprStrBefore";
GTWTreeType __strong const kExprStrAfter				= @"ExprStrAfter";
GTWTreeType __strong const kExprReplace					= @"ExprReplace";
GTWTreeType __strong const kExprUUID					= @"ExprUUID";
GTWTreeType __strong const kExprStrUUID					= @"ExprStrUUID";
GTWTreeType __strong const kExprExists                  = @"ExprExists";
GTWTreeType __strong const kExprNotExists               = @"ExprNotExists";

GTWTreeType __strong const kTreeResult					= @"TreeResult";
GTWTreeType __strong const kTreeResultSet				= @"ResultSet";

@implementation GTWTree

- (GTWTree*) init {
    if (self = [super init]) {
        self.annotations = [NSMutableDictionary dictionary];
        self.leaf        = NO;
    }
    return self;
}

- (GTWTree*) initLeafWithType: (GTWTreeType) type treeValue: (id<GTWTree>) treeValue {
    if (self = [self initWithType:type value:nil treeValue:treeValue arguments:nil]) {
        self.leaf   = YES;
    }
    return self;
}

- (GTWTree*) initLeafWithType: (GTWTreeType) type value: (id) value {
    if (self = [self initWithType:type value:value treeValue:nil arguments:nil]) {
        self.leaf   = YES;
    }
    return self;
}

- (GTWTree*) initWithType: (GTWTreeType) type value: (id) value treeValue: (id<GTWTree>) treeValue arguments: (NSArray*) args {
    if (self = [self init]) {
        int i;
        self.leaf   = NO;
        self.type   = type;
        self.ptr	= NULL;
        self.value  = value;
        self.treeValue  = treeValue;
        NSUInteger size     = [args count];
        NSMutableArray* arguments  = [NSMutableArray arrayWithCapacity:size];
        self.arguments  = args;
        
        for (i = 0; i < size; i++) {
            GTWTree* n  = args[i];
            if (n == nil) {
                NSLog(@"NULL node argument passed to gtw_new_tree");
                return nil;
            }
            
            if (![n isKindOfClass:[GTWTree class]]) {
                NSLog(@"argument object isn't a tree object: %@", n);
            }
            
            [arguments addObject:n];
        }
        self.arguments  = arguments;
        if (type == kPlanHashJoin && size >= 3) {
            GTWTree* n	= args[2];
            NSUInteger count	= [n.arguments count];
            if (count == 0) {
                NSLog(@"hashjoin without join variables\n");
            }
        }
    }
    
    if (self.type == kTreeNode && !(self.value || self.treeValue)) {
        NSLog(@"TreeNode without node!");
        return nil;
    }
    
    return self;
}


- (GTWTree*) initWithType: (GTWTreeType) type value: (id) value arguments: (NSArray*) args {
    return [self initWithType:type value:value treeValue:nil arguments:args];
}

- (GTWTree*) initWithType: (GTWTreeType) type treeValue: (id<GTWTree>) treeValue arguments: (NSArray*) args {
    return [self initWithType:type value:nil treeValue:treeValue arguments:args];
}

- (GTWTree*) initWithType: (GTWTreeType) type arguments: (NSArray*) args {
    return [self initWithType:type value:nil treeValue: nil arguments:args];
}

- (id) copyReplacingValues: (NSDictionary*) map {
    id<GTWTree> replace = [map objectForKey:self];
    if (replace) {
        id r    = replace;
        return [r copy];
    } else {
        GTWTree* copy       = [[[self class] alloc] init];
        copy.leaf           = self.leaf;
        copy.type           = self.type;
        NSMutableArray* args    = [NSMutableArray array];
        for (id<GTWTree> a in self.arguments) {
            id<GTWTree> c   = [a copyReplacingValues: map];
            [args addObject:c];
        }
        copy.arguments      = args;
        if ([self.value conformsToProtocol:@protocol(GTWRewriteable)]) {
            id<GTWRewriteable> value    = self.value;
            copy.value          = [value copyReplacingValues: map];
        } else {
            copy.value          = [self.value copy];
        }
        id tv               = self.treeValue;
        copy.treeValue      = [tv copyReplacingValues: map];
        copy.ptr            = self.ptr;
        copy.annotations    = [NSMutableDictionary dictionaryWithDictionary:self.annotations];
        return copy;
    }
}

- (id)copyWithCanonicalization {
    GTWTree* copy       = [[[self class] alloc] init];
    copy.leaf           = self.leaf;
    copy.type           = self.type;
    NSMutableArray* args    = [NSMutableArray array];
    for (id<GTWTree> a in self.arguments) {
        id<GTWTree> c   = [a copyWithCanonicalization];
        [args addObject:c];
    }
    copy.arguments      = args;
    if ([self.value conformsToProtocol:@protocol(GTWRewriteable)]) {
        id<GTWRewriteable> value    = self.value;
        copy.value          = [value copyWithCanonicalization];
    } else {
        copy.value          = [self.value copy];
    }
    id tv               = self.treeValue;
    copy.treeValue      = [tv copyWithCanonicalization];
    copy.ptr            = self.ptr;
    copy.annotations    = [NSMutableDictionary dictionaryWithDictionary:self.annotations];
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

- (GTWTree*) copy {
    return [self copyReplacingValues:@{}];
}


- (NSString*) treeTypeName {
    return self.type;
}

- (id) _applyPrefixBlock: (GTWTreeAccessorBlock)prefix postfixBlock: (GTWTreeAccessorBlock) postfix withParent: (id<GTWTree>) parent level: (NSUInteger) level {
    BOOL stop   = NO;
    id value    = nil;
    if (prefix) {
        value    = prefix(self, parent, level, &stop);
        if (stop)
            return value;
    }
    
    for (GTWTree* child in self.arguments) {
        [child _applyPrefixBlock:prefix postfixBlock:postfix withParent: self level:level+1];
    }
    
    if (postfix) {
        value    = postfix(self, parent, level, &stop);
    }
    
    return value;
}

- (id) applyPrefixBlock: (GTWTreeAccessorBlock)prefix postfixBlock: (GTWTreeAccessorBlock) postfix {
    return [self _applyPrefixBlock:prefix postfixBlock:postfix withParent: nil level:0];
}

- (id) annotationForKey: (NSString*) key {
    return (self.annotations)[key];
}

- (NSSet*) referencedBlanks {
    if (self.type == kTreeNode) {
        if ([self.value isKindOfClass:[GTWBlank class]]) {
            return [NSSet setWithObject:self.value];
        }
        return [NSSet set];
    } else if (self.type == kTreeTriple || self.type == kTreeQuad) {
        NSMutableSet* set   = [NSMutableSet set];
        NSArray* nodes  = [self.value allValues];
        for (id<GTWTerm> n in nodes) {
            if ([n isKindOfClass:[GTWBlank class]]) {
                [set addObject:n];
            }
        }
        return set;
    } else {
        NSMutableSet* set   = [NSMutableSet set];
        for (id<GTWTree> n in self.arguments) {
            [set addObjectsFromArray:[[n referencedBlanks] allObjects]];
        }
        return set;
    }
}

- (NSSet*) inScopeVariables {
    NSSet* set  = [NSSet setWithObjects:[GTWVariable class], nil];
    return [self inScopeNodesOfClass:set];
}

- (NSSet*) inScopeNodesOfClass: (NSSet*) types {
    if (self.type == kTreeNode) {
        for (id type in types) {
            if ([self.value isKindOfClass:type]) {
                return [NSSet setWithObject:self.value];
            }
        }
        return [NSSet set];
    } else if (self.type == kTreeTriple || self.type == kTreeQuad) {
        NSMutableSet* set   = [NSMutableSet set];
        NSArray* nodes  = [self.value allValues];
        for (id<GTWTerm> n in nodes) {
            for (id type in types) {
                if ([n isKindOfClass:type]) {
                    [set addObject:n];
                }
            }
        }
        return set;
    } else if (self.type == kAlgebraGraph) {
        NSMutableSet* set   = [[self.arguments[0] inScopeNodesOfClass:types] mutableCopy];
        id<GTWTree> tn      = self.treeValue;
        id<GTWTerm> term    = tn.value;
        for (id type in types) {
            if ([term isKindOfClass:type]) {
                [set addObject:term];
            }
        }
        return set;
    } else if (self.type == kAlgebraProject || self.type == kPlanProject) {
//        NSLog(@"computing in-scope nodes for projection: %@", self);
        id<GTWTree> project = self.treeValue;
        NSMutableSet* set   = [NSMutableSet set];
        for (id<GTWTree> t in project.arguments) {
            if (t.type == kTreeNode) {
                for (id type in types) {
                    if ([t.value isKindOfClass:type]) {
                        [set addObject:t.value];
                    }
                }
            } else if (t.type == kAlgebraExtend) {
                id<GTWTree> list    = t.treeValue;
                id<GTWTree> node    = list.arguments[1];
                for (id type in types) {
                    if ([node.value isKindOfClass:type]) {
                        [set addObject:node.value];
                    }
                }
                for (id<GTWTree> pattern in t.arguments) {
                    NSSet* patvars      = [pattern inScopeNodesOfClass:types];
                    [set addObjectsFromArray:[patvars allObjects]];
                }
            }
        }
//        NSLog(@"---> %@", set);
        return set;
    } else if (self.type == kAlgebraExtend || self.type == kPlanExtend) {
        id<GTWTree> list    = self.treeValue;
        NSMutableSet* set   = [NSMutableSet setWithSet:[self.arguments[0] inScopeNodesOfClass:types]];
        id<GTWTree> node    = list.arguments[1];
        for (id type in types) {
            if ([node.value isKindOfClass:type]) {
                [set addObject:node.value];
            }
        }
        return set;
    } else {
        NSMutableSet* set   = [NSMutableSet set];
        for (id<GTWTree> n in self.arguments) {
            [set addObjectsFromArray:[[n inScopeNodesOfClass:types] allObjects]];
        }
        return set;
    }
}

- (Class) planResultClass {
    if (self.type == kPlanConstruct || self.type == kPlanDescribe) {
        return [GTWTriple class];
    } else {
        return [NSDictionary class];
    }
}

- (NSSet*) nonAggregatedVariables {
    if (self.type == kTreeNode) {
        id<GTWTerm> t   = self.value;
        if ([t isKindOfClass:[GTWVariable class]]) {
            return [NSSet setWithObject:self.value];
        } else {
            return [NSSet set];
        }
    } else if (self.type == kAlgebraExtend) {
        id<GTWTree> list    = self.treeValue;
        NSMutableSet* set   = [NSMutableSet setWithSet:[list.arguments[0] nonAggregatedVariables]];
        for (id<GTWTree> pattern in self.arguments) {
            NSSet* patvars      = [pattern nonAggregatedVariables];
            [set addObjectsFromArray:[patvars allObjects]];
        }
        return set;
    } else if (self.type == kExprCount || self.type == kExprSum || self.type == kExprMin || self.type == kExprMax || self.type == kExprAvg || self.type == kExprSample || self.type == kExprGroupConcat) {
        return [NSSet set];
    } else {
        NSMutableSet* set   = [NSMutableSet set];
        for (id<GTWTree> n in self.arguments) {
            [set addObjectsFromArray:[[n nonAggregatedVariables] allObjects]];
        }
        return set;
    }
}

- (NSString*) conciseDescription {
    NSMutableString* s = [NSMutableString string];
    GTWTree* node = self;
    if (node.leaf) {
        [s appendFormat: @"%@(", [node treeTypeName]];
        if (node.treeValue) {
            [s appendFormat:@"%@", node.treeValue];
        } else if (node.value) {
            [s appendFormat:@"%@", node.value];
        }
        if (node.ptr) {
            [s appendFormat:@"<%p>", node.ptr];
        }
        [s appendString:@")"];
    } else {
        [s appendFormat: @"%@", [node treeTypeName]];
        if (node.treeValue) {
            [s appendFormat:@"[%@]", node.treeValue];
        } else if (node.value) {
            [s appendFormat:@"[%@]", node.value];
        }
        int i;
        NSUInteger count    = [node.arguments count];
        if (count > 0) {
            [s appendString:@"("];
            [s appendFormat:@"%@", [node.arguments[0] conciseDescription]];
            for (i = 1; i < count; i++) {
                [s appendFormat:@", %@", [node.arguments[i] conciseDescription]];
            }
            [s appendString:@")"];
        }
    }
    return s;
}

- (NSString*) longDescription {
    NSMutableString* s = [NSMutableString string];
    [self applyPrefixBlock:^id(id<GTWTree> node, id<GTWTree> parent, NSUInteger level, BOOL *stop) {
        NSMutableString* indent = [NSMutableString string];
        for (NSUInteger i = 0; i < level; i++) {
            [indent appendFormat:@"  "];
        }
        if (node.leaf) {
            [s appendFormat: @"%@%@", indent, [node treeTypeName]];
            if (node.treeValue) {
                [s appendFormat:@" %@", node.treeValue];
            } else if (node.value) {
                [s appendFormat:@" %@", node.value];
            }
            if (node.ptr) {
                [s appendFormat:@"<%p>", node.ptr];
            }
            [s appendFormat:@"\n"];
        } else {
            [s appendFormat: @"%@%@", indent, [node treeTypeName]];
            if (node.treeValue) {
                [s appendFormat:@" %@", [node.treeValue conciseDescription]];
            } else if (node.value) {
                if ([node.value isKindOfClass:[GTWTree class]]) {
                    [s appendFormat:@" %@", [node.value conciseDescription]];
                } else {
                    [s appendFormat:@" %@", node.value];
                }
            }
            if (node.ptr) {
                [s appendFormat:@"<%p>", node.ptr];
            }
            [s appendFormat:@"\n"];
        }
        return nil;
    } postfixBlock:nil];
    return s;
}

- (NSString*) description {
    if (self.type == kTreeNode || self.type == kTreeQuad || self.type == kTreeList) {
        return [self conciseDescription];
    } else {
        return [self longDescription];
    }
}

- (BOOL)isEqual:(id)anObject {
    return [[self description] isEqual: [anObject description]];
}

- (NSComparisonResult)compare:(id<GTWTree>)tree {
    return [[self description] compare:[tree description]];
}

- (NSUInteger)hash {
    NSUInteger h    = [[self description] hash];
    return h;
}

+ (NSString*) sparqlForAlgebra: (id<GTWTree>) algebra isProjected: (BOOL*) isProjected indentLevel: (NSUInteger) indentLevel {
    NSMutableString* indent = [NSMutableString string];
    NSUInteger i;
    for (i = 0; i < indentLevel; i++) {
        [indent appendString:@"  "];
    }
    if (algebra.type == kTreeTriple) {
        id<GTWTriple> t = algebra.value;
        return [NSString stringWithFormat:@"%@%@", indent, [t description]];
    } else if (algebra.type == kTreeList || algebra.type == kAlgebraBGP) {
        NSMutableArray* s   = [NSMutableArray array];
        for (id<GTWTree> t in algebra.arguments) {
            [s addObject:[self sparqlForAlgebra:t isProjected:isProjected indentLevel:indentLevel+1]];
        }
        return [NSString stringWithFormat:@"%@%@", indent, [s componentsJoinedByString:@"\n"]];
    } else if (algebra.type == kAlgebraLeftJoin) {
        NSString* lhs   = [self sparqlForAlgebra:algebra.arguments[0] isProjected:isProjected indentLevel:indentLevel+1];
        NSString* rhs   = [self sparqlForAlgebra:algebra.arguments[1] isProjected:isProjected indentLevel:indentLevel+1];
        return [NSString stringWithFormat:@"%@%@\n%@OPTIONAL {\n%@\n%@}\n", indent, lhs, indent, indent, rhs];
    } else if (algebra.type == kAlgebraService) {
        id<GTWTree> list        = algebra.treeValue;
        id<GTWTree> eptree      = list.arguments[0];
        id<GTWTree> silenttree  = list.arguments[1];
        id<GTWTerm> epterm      = eptree.value;
        GTWLiteral* silentTerm  = silenttree.value;
        BOOL silent             = [silentTerm booleanValue];

        NSString* lhs   = [self sparqlForAlgebra:algebra.arguments[0] isProjected:isProjected indentLevel:indentLevel+1];
        NSString* sparql    = [NSString stringWithFormat:@"%@SERVICE %@%@ {\n%@\n%@}\n", indent, (silent ? @"SILENT " : @""), epterm, indent, lhs];
        return sparql;
    } else if (algebra.type == kAlgebraGraph) {
        id<GTWTree> gtree   = algebra.treeValue;
        id<GTWTerm> gterm   = gtree.value;
        NSString* lhs   = [self sparqlForAlgebra:algebra.arguments[0] isProjected:isProjected indentLevel:indentLevel+1];
        return [NSString stringWithFormat:@"%@GRAPH %@ {\n%@\n%@}\n", indent, gterm, indent, lhs];
    } else {
        // TODO: implement more coverage of Algebra types (esp. dealing with projection in subqueries)
        NSLog(@"Do not know how to serialize algebra as SPARQL: %@", algebra);
        return nil;
    }
}

+ (NSString*) sparqlForAlgebra: (id<GTWTree>) algebra {
    BOOL isProjected  = NO;
    NSString* sparql    = [self sparqlForAlgebra:algebra isProjected:&isProjected indentLevel:1];
    if (!isProjected) {
        sparql  = [NSString stringWithFormat:@"SELECT * WHERE {\n%@\n}", sparql];
    }
    
//    NSLog(@"SPARQL:\n-----------\n%@\n-------\n", sparql);
    return sparql;
}

@end

@implementation GTWQueryPlan
@end
