//
//  CommandResponseDelegate.h
//  VSWindow
//
//  Created by Ryan Heideman on 7/23/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionStateChangedDelegate.h"

@protocol CommandResponseDelegate <ConnectionStateChangedDelegate>

- (void)operationShouldProceed:(NSDictionary*) dict;

@end
