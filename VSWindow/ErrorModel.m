//
//  ErrorModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/7/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "ErrorModel.h"
#import "ErrorListItem.h"

@implementation ErrorModel

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Subscribe", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.ErrorModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
        
    [self.connection sendCommand:dict];
}

- (void)navigate:(NSString *)errorId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"NavigateErrorItem", @"CommandName", errorId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (NSDictionary*)parseGetErrorListResponse:(NSDictionary *)response
{
    NSArray *errorItems = [response valueForKey:@"Errors"];
    NSMutableArray* errors = [[NSMutableArray alloc] initWithCapacity:errorItems.count];
    
    NSArray *warningItems = [response valueForKey:@"Warnings"];
    NSMutableArray* warnings = [[NSMutableArray alloc] initWithCapacity:warningItems.count];
    
    for (id ei in errorItems)
    {
        ErrorListItem *item = [[ErrorListItem alloc] initFromDictionary:ei];
        [errors addObject:item];
        item = nil;
    }
    
    for (id wi in warningItems)
    {
        ErrorListItem *item = [[ErrorListItem alloc] initFromDictionary:wi];
        [warnings addObject:item];
        item = nil;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:errors, @"errors", warnings, @"warnings", nil];
}

@end
