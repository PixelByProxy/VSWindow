//
//  ToolbarItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/15/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "ToolbarItem.h"

@implementation ToolbarItem

@synthesize itemId = _itemId;
@synthesize name = _name;
@synthesize order = _order;

#pragma mark - Init

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.itemId = [dict valueForKey:@"Id"];
        self.name = [dict valueForKey:@"Name"];
        
        id savedOrder = [dict valueForKey:@"Order"];
        if (savedOrder != nil)
        {
            self.order = [savedOrder integerValue];
        }
    }
    return self;
}

- (id)initWithValues:(NSString *)newItemId name:(NSString*)newName order:(NSInteger)newOrder
{
    self = [super init];
    if (self) {
        self.itemId = newItemId;
        self.name = newName;
        self.order = newOrder;
    }
    return self;
}

#pragma mark - Public Methods

- (NSDictionary*)toDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.itemId, @"Id", self.name, @"Name", [NSNumber numberWithInt:(int)self.order], @"Order", nil];
    
    return dict;
}

@end