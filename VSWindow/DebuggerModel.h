//
//  DebuggerModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/8/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"

@interface DebuggerModel : ModelBase

- (void)subscribe;
- (void)navigateBreakpoint:(NSString *)breakpointId;
- (void)deleteBreakpoint:(NSString *)breakpointId;
- (void)deleteAllBreakpoints;
- (void)enableBreakpoint:(NSString *)breakpointId;
- (void)enableAllBreakpoints;
- (void)disableBreakpoint:(NSString *)breakpointId;
- (void)disableAllBreakpoints;
- (NSMutableArray*)parseGetBreakpointsResponse:(NSDictionary *)response;

@end
