//
//  TaskListModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/8/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelBase.h"
#import "CommandResponseDelegate.h"

@interface TaskListModel : ModelBase

- (void)subscribe;
- (void)navigate:(NSString *)taskId;
- (void)addTask:(NSString *)taskName taskPriority:(NSInteger)taskPriority;
- (void)deleteTask:(NSString *)taskId;
- (void)checkTask:(NSString *)taskId;
- (void)uncheckTask:(NSString *)taskId;
- (NSDictionary*)parseGetTaskListResponse:(NSDictionary *)response;
- (BOOL)parseAddTaskResponse:(NSDictionary*)response;

@end
