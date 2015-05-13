//
//  ConnectionStatusChangedDelegate.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/29/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstanceItem.h"

@protocol ConnectionStateChangedDelegate <NSObject>

- (void)connectionStateChanged:(BOOL) connected;
- (void)instanceChanged:(InstanceItem*) instance;

@end
