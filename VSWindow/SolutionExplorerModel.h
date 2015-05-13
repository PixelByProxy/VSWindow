//
//  SolutionExplorerModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 12/22/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"

@interface SolutionExplorerModel : ModelBase

- (void)subscribe;
- (void)navigate:(NSString *)itemId;
- (void)close:(NSString *)itemId;
- (void)closeAll;
- (NSMutableArray*)parseGetItemsResponse:(NSDictionary *)response;;

@end