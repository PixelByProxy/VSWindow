//
//  SettingsModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 10/7/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionSetting.h"

@interface UserSettings : NSObject

@property (nonatomic, retain) ConnectionSetting* activeConnection;
@property (nonatomic, retain) NSMutableArray* connections;

- (ConnectionSetting*)addConnection:(NSString *)name andPort:(NSInteger)port withPassword:(NSString*)password autoConnect:(BOOL)autoConnect;

- (void)updateConnection:(NSString *)uniqueId withName:(NSString *)name andPort:(NSInteger)port withPassword:(NSString*)password autoConnect:(BOOL)autoConnect;

- (void)removeConnection:(NSString *)uniqueId;

- (void)selectActiveConnection:(NSString *)uniqueId;

- (ConnectionSetting*)getConnectionById:(NSString *)uniqueId;

@end