//
//  OutputModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/8/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"

@interface OutputModel : ModelBase

- (void)subscribe;
- (void)clearWindow;
- (NSString*)parseGetOutputWindowTextResponse:(NSDictionary *)response;

@end
