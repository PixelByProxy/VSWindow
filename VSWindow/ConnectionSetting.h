//
//  ConnectionSetting.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/28/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionSetting : NSObject

@property (nonatomic, retain) NSString* uniqueId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) BOOL autoConnect;

- (id)initWithValues:(NSString*)uniqueId name:(NSString *)name andPort:(NSInteger)port withPassword:(NSString*)password autoConnect:(BOOL)autoConnect;
- (id)initFromDictionary:(NSDictionary *)dict;

@end