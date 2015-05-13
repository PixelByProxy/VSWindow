//
//  ToolbarItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/15/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolbarItem : NSObject

@property (nonatomic, retain) NSString* itemId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) NSInteger order;

- (id)initFromDictionary:(NSDictionary *)dict;
- (id)initWithValues:(NSString *)newItemId name:(NSString*)newName order:(NSInteger)newOrder;
- (NSDictionary*)toDictionary;

@end
