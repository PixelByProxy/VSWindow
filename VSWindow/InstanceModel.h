//
//  InstanceModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 2/11/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "ModelBase.h"
#import "InstanceItem.h"

@interface InstanceModel : ModelBase

@property (nonatomic, retain) InstanceItem* currentInstance;

- (void)subscribe;
- (void)loadInstances;
- (void)setActiveInstance:(InstanceItem*)instance;
- (NSMutableArray*)parseInstancesResponse:(NSDictionary *)response;
- (InstanceItem*)parseSetActiveInstanceResponse:(NSDictionary *)response;
- (NSString*)parseInstanceClosedResponse:(NSDictionary *)response;

@end