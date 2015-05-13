//
//  ErrorListItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 7/17/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "ErrorListItem.h"

@implementation ErrorListItem

@synthesize errorId = _errorId;
@synthesize description = _description;
@synthesize errorLevel = _errorLevel;
@synthesize column = _column;
@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;
@synthesize project = _project;

#pragma mark - Init

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.errorId = [dict valueForKey:@"Id"];
        self.project = [dict valueForKey:@"Project"];
        self.description = [dict valueForKey:@"Description"];
        self.fileName = [dict valueForKey:@"FileName"];
        self.lineNumber = [[dict valueForKey:@"Line"] integerValue];
        self.errorLevel = [[dict valueForKey:@"ErrorLevel"] integerValue];
        self.column = [[dict valueForKey:@"Column"] integerValue];
    }
    return self;
}

@end
