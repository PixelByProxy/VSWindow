//
//  ToolbarSearchDelegate.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialogClosedDelegate.h"

@protocol ToolbarSearchDelegate <DialogClosedDelegate>

- (NSInteger)initialItemCount;
- (NSInteger)maxItemCount;
- (void)commandsAdded:(NSMutableDictionary*) commands;

@end
