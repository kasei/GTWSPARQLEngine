#import <Foundation/Foundation.h>
#import "SPARQLKit.h"

@interface GTWMemoryQuadStore : NSObject<GTWQuadStore,GTWMutableQuadStore>

@property id<GTWLogger> logger;
@property NSMutableSet* quads;
@property dispatch_queue_t queue;
@property NSMutableDictionary* indexes;
@property NSMutableDictionary* indexKeys;

- (BOOL) addIndexType: (NSString*) type value: (NSArray*) positions synchronous: (BOOL) sync error: (NSError**) error;
- (NSString*) bestIndexForMatchingSubject: (id<GTWTerm>) s predicate: (id<GTWTerm>) p object: (id<GTWTerm>) o graph: (id<GTWTerm>) g;

@end
