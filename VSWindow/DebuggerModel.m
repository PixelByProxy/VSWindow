//
//  DebuggerModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/8/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "DebuggerModel.h"
#import "BreakpointItem.h"

@implementation DebuggerModel

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Subscribe", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.DebuggerModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
        
    [self.connection sendCommand:dict];
}

- (void)navigateBreakpoint:(NSString *)breakpointId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"NavigateBreakpoint", @"CommandName", breakpointId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)deleteBreakpoint:(NSString *)breakpointId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"DeleteBreakpoint", @"CommandName", breakpointId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)deleteAllBreakpoints
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"DeleteAllBreakpoints", @"CommandName", nil];
    
    [self.connection sendCommand:dict];
}

- (void)enableBreakpoint:(NSString *)breakpointId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"EnableBreakpoint", @"CommandName", breakpointId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)enableAllBreakpoints
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"EnableAllBreakpoints", @"CommandName", nil];
    
    [self.connection sendCommand:dict];
}

- (void)disableBreakpoint:(NSString *)breakpointId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"DisableBreakpoint", @"CommandName", breakpointId, @"CommandArgs", nil];
    
    [[self.appDelegate getConnection] sendCommand:dict];
}

- (void)disableAllBreakpoints
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"DisableAllBreakpoints", @"CommandName", nil];
    
    [self.connection sendCommand:dict];
}

- (NSMutableArray*)parseGetBreakpointsResponse:(NSDictionary *)response;
{
    NSArray *items = [response valueForKey:@"Items"];
    NSMutableArray* breakpointItems = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for (id myArrayElement in items)
    {
        BreakpointItem *item = [[BreakpointItem alloc] initFromDictionary:myArrayElement];
        [breakpointItems addObject:item];
        //NSLog(@"Item=%@", item);
        item = nil;
    }

    return breakpointItems;
}

@end
