//
//  TaskListModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/8/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "TaskListModel.h"
#import "TaskListItem.h"

@implementation TaskListModel

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Subscribe", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.TaskListModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
        
    [self.connection sendCommand:dict];
}

- (void)navigate:(NSString *)taskId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"NavigateTaskItem", @"CommandName", taskId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)addTask:(NSString *)taskName taskPriority:(NSInteger)taskPriority
{
    static NSString *commandFormat = @"%d,%@";

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"AddTaskItem", @"CommandName", [NSString stringWithFormat:commandFormat, taskPriority, taskName], @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)deleteTask:(NSString *)taskId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"DeleteTaskItem", @"CommandName", taskId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)checkTask:(NSString *)taskId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"CheckTaskItem", @"CommandName", taskId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)uncheckTask:(NSString *)taskId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"UncheckTaskItem", @"CommandName", taskId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (NSDictionary*)parseGetTaskListResponse:(NSDictionary *)response
{
    NSArray *userTaskItems = [response valueForKey:@"UserTasks"];
    NSMutableArray* userTasks = [[NSMutableArray alloc] initWithCapacity:userTaskItems.count];
    
    NSArray *commentItems = [response valueForKey:@"Comments"];
    NSMutableArray* comments = [[NSMutableArray alloc] initWithCapacity:commentItems.count];
    
    for (id uti in userTaskItems)
    {
        TaskListItem *item = [[TaskListItem alloc] initFromDictionary:uti];
        [userTasks addObject:item];
        //NSLog(@"UserTask=%@", item);
        item = nil;
    }
    
    for (id ci in commentItems)
    {
        TaskListItem *item = [[TaskListItem alloc] initFromDictionary:ci];
        [comments addObject:item];
        //NSLog(@"Comment=%@", item);
        item = nil;
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:userTasks, @"userTasks", comments, @"comments", nil];
}

- (BOOL)parseAddTaskResponse:(NSDictionary*)response
{
    id commandValue = [response valueForKey:@"CommandValue"];
    
    Class boolClass = [[NSNumber numberWithBool:YES] class];
    if (commandValue != [NSNull null] && [commandValue isKindOfClass:boolClass])
    {
        return [commandValue boolValue];
    }

    return NO;
}

@end
