//
//  DocumentModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 9/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "DocumentModel.h"
#import "DocumentItem.h"

@implementation DocumentModel

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Subscribe", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.DocumentModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
        
    [self.connection sendCommand:dict];
}

- (void)navigate:(NSString *)documentId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"NavigateDocumentItem", @"CommandName", documentId, @"CommandArgs", nil];
    
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

- (NSMutableArray*)parseGetOpenDocumentsResponse:(NSDictionary *)response;
{
    NSArray *items = [response valueForKey:@"OpenDocuments"];
    NSMutableArray* openDocs = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for (id odi in items)
    {
        DocumentItem *item = [[DocumentItem alloc] initFromDictionary:odi];
        [openDocs addObject:item];
        //NSLog(@"UserTask=%@", item);
        item = nil;
    }
    
    return openDocs;
}

@end
