#import <Foundation/Foundation.h>
#import "SPARQLEngine.h"

@interface GTWVariable : NSObject<GTWVariable>

@property (retain, readwrite) NSString* value;

- (GTWVariable*) initWithValue: (NSString*) value;
- (GTWVariable*) initWithName: (NSString*) name;

@end
