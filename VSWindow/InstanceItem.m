//
//  InstanceItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 2/11/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "InstanceItem.h"

@implementation InstanceItem

@synthesize instanceId = _instanceId;
@synthesize connectionId = _connectionId;
@synthesize solutionName = _solutionName;
@synthesize title = _title;
@synthesize processId = _processId;

#pragma mark - Init

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.instanceId = [dict valueForKey:@"Id"];
        self.connectionId = [dict valueForKey:@"ConnectionId"];
        self.solutionName = [dict valueForKey:@"SolutionName"];
        self.title = [dict valueForKey:@"Title"];
        self.processId = [[dict valueForKey:@"ProcessId"] integerValue];
        self.version = [[dict valueForKey:@"Version"] integerValue];
    }
    return self;
}

@end
