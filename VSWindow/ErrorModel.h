//
//  ErrorModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/7/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"

@interface ErrorModel : ModelBase

- (void)subscribe;
- (void)navigate:(NSString *)errorId;
- (NSDictionary*)parseGetErrorListResponse:(NSDictionary *)response;

@end
