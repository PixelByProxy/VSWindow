//
//  InstanceItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 2/11/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstanceItem : NSObject

@property (nonatomic, retain) NSString* instanceId;
@property (nonatomic, retain) NSString* connectionId;
@property (nonatomic, retain) NSString* solutionName;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, assign) NSInteger processId;
@property (nonatomic, assign) NSInteger version;

- (id)initFromDictionary:(NSDictionary *)dict;

@end
