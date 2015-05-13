//
//  ErrorModelDelgate.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/7/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DelegateBase.h"

@protocol ErrorModelDelegate <DelegateBase>

- (void)errorListLoaded:(NSInteger)loadedErrorCount loadedWarningCount:(NSInteger)loadedWarningCount loadedErrors:(NSMutableArray*)loadedErrors loadedWarnings:(NSMutableArray*) loadedWarnings;

@end