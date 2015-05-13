//
//  ToolbarModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/15/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"

@interface ToolbarModel : ModelBase

- (void)subscribe;
- (void)findCommands:(NSString *)commandName;
- (void)runCommand:(NSString *)commandText;
- (NSMutableDictionary*)getToolbarLayout;
- (void)saveToolbarLayout:(NSMutableDictionary*)items;
- (void)resetToolbarLayout;
- (NSMutableArray*)parseFindCommandsResponse:(NSDictionary *)response;

@end