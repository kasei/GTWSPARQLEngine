//
//  SPKQuery.m
//  SPARQLKit
//
//  Created by Gregory Williams on 12/6/13.
//  Copyright (c) 2013 Gregory Williams. All rights reserved.
//

#import "SPKQuery.h"
#import "SPKSPARQLParser.h"
#import "SPKSimpleQueryEngine.h"
#import "SPKQueryPlanner.h"

@implementation SPKQuery

- (SPKQuery*) initWithQueryString: (NSString*) queryString baseURI: (NSString*) base {
    if (self = [self init]) {
        self.opString    = [queryString copy];
        self.opBase      = [base copy];
        self.parser         = [[SPKSPARQLParser alloc] init];
        self.engine         = [[SPKSimpleQueryEngine alloc] init];
        self.planner        = [[SPKQueryPlanner alloc] init];
        self.prefixes       = [NSMutableDictionary dictionary];
        GTWIRI* defGraph    = [[GTWIRI alloc] initWithValue: base];
        self.dataset        = [[GTWDataset alloc] initDatasetWithDefaultGraphs:@[defGraph]];
    }
    return self;
}

- (id<SPKTree>) parseWithError: (NSError*__autoreleasing*) error {
    NSError* e;
    id<SPKTree> algebra;
    
    algebra = [self.parser parseSPARQLQuery:self.opString withBaseURI:self.opBase settingPrefixes:self.prefixes error:&e];
    
    if (e) {
        NSLog(@"parser error: %@", e);
        if (error)
            *error  = e;
        return nil;
    }
    if (self.verbose) {
        NSLog(@"query:\n%@", algebra);
    }
    
    self.algebra    = algebra;
    return algebra;
}

@end
