//
//  TaskListItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 4/17/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "TaskListItem.h"

@implementation TaskListItem

@synthesize taskId = _taskId;
@synthesize category = _category;
@synthesize description = _description;
@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;
@synthesize priority = _priority;
@synthesize column = _column;
@synthesize checked = _checked;

#pragma mark - Init

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.taskId = [dict valueForKey:@"Id"];
        self.category = [dict valueForKey:@"Category"];
        self.description = [dict valueForKey:@"Description"];
        self.fileName = [dict valueForKey:@"FileName"];
        self.lineNumber = [[dict valueForKey:@"Line"] integerValue];
        self.priority = [[dict valueForKey:@"Priority"] integerValue];
        self.column = [[dict valueForKey:@"Column"] integerValue];
        self.checked = [[dict valueForKey:@"Checked"] boolValue];
    }
    return self;
}

@end
