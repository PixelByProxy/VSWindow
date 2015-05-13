//
//  ModelBase.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/4/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "StreamCommander.h"

@interface ModelBase : NSObject

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander* connection;

@end
