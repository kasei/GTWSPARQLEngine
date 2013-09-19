#import <Foundation/Foundation.h>
#import "GTWTree.h"
#import "GTWSPARQLEngine.h"

@interface GTWExpression : GTWTree

+ (id<GTWTerm>) evaluateExpression: (GTWTree*) expr WithResult: (NSDictionary*) result;

@end