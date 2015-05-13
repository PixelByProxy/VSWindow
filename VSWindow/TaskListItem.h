//
//  TaskListItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 4/17/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskListItem : NSObject

@property (nonatomic, retain) NSString* taskId;
@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, assign) NSInteger lineNumber;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) BOOL checked;

- (id)initFromDictionary:(NSDictionary *)dict;

@end
