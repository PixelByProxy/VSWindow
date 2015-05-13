//
//  ErrorListItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 7/17/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorListItem : NSObject

@property (nonatomic, retain) NSString* errorId;
@property (nonatomic, retain) NSString* project;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, assign) NSInteger lineNumber;
@property (nonatomic, assign) NSInteger errorLevel;
@property (nonatomic, assign) NSInteger column;

- (id)initFromDictionary:(NSDictionary *)dict;

@end
