//
//  SolutionExplorerItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 12/22/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "SolutionExplorerItem.h"

@implementation SolutionExplorerItem

@synthesize itemId = _itemId;
@synthesize name = _name;
@synthesize saved = _saved;
@synthesize isFile = _isFile;

#pragma mark - Init

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.itemId = [dict valueForKey:@"Id"];
        self.name = [dict valueForKey:@"Name"];
        self.saved = [[dict valueForKey:@"Saved"] boolValue];
        self.isFile = [[dict valueForKey:@"IsFile"] boolValue];
    }
    return self;
}

@end