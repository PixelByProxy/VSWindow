//
//  SolutionExplorerModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 12/22/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "SolutionExplorerModel.h"
#import "SolutionExplorerItem.h"

@implementation SolutionExplorerModel

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Subscribe", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.SolutionModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)navigate:(NSString *)documentId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"NavigateItem", @"CommandName", documentId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)close:(NSString *)documentId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Close", @"CommandName", documentId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)closeAll
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"CloseAll", @"CommandName", nil];
    
    [self.connection sendCommand:dict];
}

- (NSMutableArray*)parseGetItemsResponse:(NSDictionary *)response;
{
    NSArray *items = [response valueForKey:@"Items"];
    NSMutableArray* parsedList = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for (id odi in items)
    {
        SolutionExplorerItem *item = [[SolutionExplorerItem alloc] initFromDictionary:odi];
        [parsedList addObject:item];
        //NSLog(@"UserTask=%@", item);
        item = nil;
    }
    
    return parsedList;
}

@end
