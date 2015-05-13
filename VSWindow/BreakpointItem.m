//
//  BreakpointItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 7/10/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "BreakpointItem.h"

@implementation BreakpointItem

@synthesize breakpointId = _breakpointId;
@synthesize enabled = _enabled;
@synthesize fileName = _fileName;
@synthesize fileColumn = _fileColumn;
@synthesize fileLine = _fileLine;
@synthesize functionName = _functionName;
@synthesize name = _name;
@synthesize tag = _tag;

#pragma mark - Init

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.breakpointId = [dict valueForKey:@"Id"];
        self.fileName = [dict valueForKey:@"File"];
        self.fileColumn = [[dict valueForKey:@"FileColumn"] integerValue];
        self.fileLine = [[dict valueForKey:@"FileLine"] integerValue];
        self.functionName = [dict valueForKey:@"FunctionName"];
        self.name = [dict valueForKey:@"Name"];
        self.tag = [dict valueForKey:@"Tag"];
        self.enabled = [[dict valueForKey:@"Enabled"] boolValue];
    }
    return self;
}

@end
