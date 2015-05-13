//
//  BreakpointItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 7/10/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BreakpointItem : NSObject

@property (nonatomic, retain) NSString* breakpointId;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, assign) NSInteger fileColumn;
@property (nonatomic, assign) NSInteger fileLine;
@property (nonatomic, retain) NSString* functionName;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* tag;

- (id)initFromDictionary:(NSDictionary *)dict;

@end
