//
//  CommandModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/8/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"

@interface CommandModel : ModelBase

- (void)subscribe;
- (void)clearWindow;
- (void)runCommand:(NSString *)commandText;
- (NSString*)parseGetCommandWindowTextResponse:(NSDictionary *)response;

@end