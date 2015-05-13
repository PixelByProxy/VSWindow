//
//  StreamCommander.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/29/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandResponseDelegate.h"
#import "ConnectionStateChangedDelegate.h"
#import "InstanceItem.h"


@interface StreamCommander : NSObject <NSStreamDelegate>

@property (nonatomic, retain) id<ConnectionStateChangedDelegate> connectionDelegate;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL didShowConnectionError;
@property (nonatomic, retain) InstanceItem* activeInstance;

- (void)connect;
- (void)disconnect;
- (void)sendCommand:(NSDictionary *) command;
- (void)subscribe:(id<CommandResponseDelegate>) subscriber;
- (void)unsubscribe:(id<CommandResponseDelegate>) subscriber;

@end