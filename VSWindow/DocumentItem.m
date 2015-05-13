//
//  DocumentItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 9/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "DocumentItem.h"

@implementation DocumentItem

@synthesize documentId = _documentId;
@synthesize name = _name;
@synthesize readOnly = _readOnly;
@synthesize saved = _saved;

#pragma mark - Init

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.documentId = [dict valueForKey:@"Id"];
        self.name = [dict valueForKey:@"Name"];
        self.readOnly = [[dict valueForKey:@"ReadOnly"] boolValue];
        self.saved = [[dict valueForKey:@"Saved"] boolValue];
    }
    return self;
}

@end
