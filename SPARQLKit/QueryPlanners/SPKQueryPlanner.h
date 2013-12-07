#import <Foundation/Foundation.h>
#import "SPARQLKit.h"
#import "SPKTree.h"
#import <GTWSWBase/GTWIRI.h>
#import <GTWSWBase/GTWDataset.h>

@interface SPKQueryPlanner : NSObject<SPKQueryPlanner>

@property id<GTWLogger> logger;
@property NSUInteger bnodeCounter;
@property NSUInteger varID;
@property NSMutableDictionary* bnodeMap;

- (id<SPKTree,GTWQueryPlan>) queryPlanForAlgebra: (id<SPKTree>) algebra usingDataset: (id<GTWDataset>) dataset withModel: (id<GTWModel>) model optimize:(BOOL)optFlag options: (NSDictionary*) options;

@end
