#import "GTWQueryPlanner.h"
#import "GTWQuad.h"
#import "SPARQLEngine.h"

@implementation GTWQueryPlanner

- (GTWTree*) queryPlanForAlgebra: (GTWTree*) algebra usingDataset: (GTWQueryDataset*) dataset optimize: (BOOL) opt {
    GTWTree* plan   = [self queryPlanForAlgebra:algebra usingDataset:dataset];
    if (opt) {
        [plan computeScopeVariables];
    }
    return plan;
}

- (GTWTree*) queryPlanForAlgebra: (GTWTree*) algebra usingDataset: (GTWQueryDataset*) dataset {
    id<GTWTriple> t;
    NSInteger count;
    NSArray* defaultGraphs;
    NSArray* list;
    switch (algebra.type) {
        case ALGEBRA_DISTINCT:
            return [[GTWTree alloc] initWithType:PLAN_DISTINCT arguments:@[[self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset]]];
        case ALGEBRA_PROJECT:
            return [[GTWTree alloc] initWithType:PLAN_PROJECT value: algebra.value arguments:@[[self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset]]];
        case ALGEBRA_JOIN:
            return [[GTWTree alloc] initWithType:PLAN_NLJOIN arguments:@[[self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset], [self queryPlanForAlgebra:algebra.arguments[1] usingDataset:dataset]]];
        case ALGEBRA_BGP:
            return [self planBGP: algebra.arguments usingDataset: dataset];
        case ALGEBRA_FILTER:
            return [[GTWTree alloc] initWithType:PLAN_FILTER value: algebra.value arguments:@[[self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset]]];
        case ALGEBRA_ORDERBY:
            list    = algebra.arguments[1];
            return [[GTWTree alloc] initWithType:PLAN_ORDER arguments:@[[self queryPlanForAlgebra:algebra.arguments[0] usingDataset:dataset], algebra.arguments[1]]];
        case TREE_TRIPLE:
            t   = algebra.value;
            defaultGraphs   = [dataset defaultGraphs];
            count   = [defaultGraphs count];
            if (count == 0) {
                return [[GTWTree alloc] initWithType:PLAN_EMPTY arguments:@[]];
            } else if (count == 1) {
                return [[GTWTree alloc] initLeafWithType:TREE_QUAD value: [[GTWQuad alloc] initWithSubject:t.subject predicate:t.predicate object:t.object graph:defaultGraphs[0]] pointer:NULL];
            } else {
                GTWTree* plan   = [[GTWTree alloc] initLeafWithType:TREE_QUAD value: [[GTWQuad alloc] initWithSubject:t.subject predicate:t.predicate object:t.object graph:defaultGraphs[0]] pointer:NULL];
                NSInteger i;
                for (i = 1; i < count; i++) {
                    plan    = [[GTWTree alloc] initWithType:PLAN_UNION arguments:@[plan, [[GTWTree alloc] initLeafWithType:TREE_QUAD value: [[GTWQuad alloc] initWithSubject:t.subject predicate:t.predicate object:t.object graph:defaultGraphs[i]] pointer:NULL]]];
                }
                return plan;
            }
        default:
            NSLog(@"cannot plan query algebra of type %@\n", [algebra treeTypeName]);
            break;
    }
    return nil;
}

- (GTWTree*) queryPlanForAlgebra: (GTWTree*) algebra {
    GTWQueryDataset* dataset    = [[GTWQueryDataset alloc] initDatasetWithDefaultGraphs:@[]];
    return [self queryPlanForAlgebra:algebra usingDataset:dataset];
}

- (GTWTree*) planBGP: (NSArray*) triples usingDataset: (GTWQueryDataset*) dataset {
//    NSLog(@"planning BGP: %@\n", triples);
    NSArray* defaultGraphs   = [dataset defaultGraphs];
    NSInteger count   = [defaultGraphs count];
    NSInteger i;
    GTWTree* plan;
    if (count == 0) {
        return [[GTWTree alloc] initWithType:PLAN_EMPTY arguments:@[]];
    } else {
        plan   = [self queryPlanForAlgebra:triples[0] usingDataset:dataset];
        for (i = 1; i < [triples count]; i++) {
            GTWTree* quad    = [self queryPlanForAlgebra:triples[i] usingDataset:dataset];
            plan    = [[GTWTree alloc] initWithType:PLAN_NLJOIN arguments:@[plan, quad]];
        }
    }
    return plan;
}

@end
