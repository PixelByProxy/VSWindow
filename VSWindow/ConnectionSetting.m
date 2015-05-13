//
//  ConnectionSetting.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/28/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "ConnectionSetting.h"

@implementation ConnectionSetting

@synthesize uniqueId = _uniqueId;
@synthesize name = _name;
@synthesize password = _password;
@synthesize port = _port;
@synthesize autoConnect = _autoConnect;

- (id)initWithValues:(NSString*)uniqueId name:(NSString *)name andPort:(NSInteger)port withPassword:(NSString*)password autoConnect:(BOOL)autoConnect
{
    self = [super init];
    if (self) {
        self.uniqueId = uniqueId;
        self.name = name;
        self.port = port;
        self.password = password;
        self.autoConnect = autoConnect;
    }
    return self;
}

- (id)initFromDictionary:(NSDictionary *)dict
{
    if (self = [self init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
}

@end