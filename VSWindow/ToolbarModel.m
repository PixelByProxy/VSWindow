//
//  ToolbarModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/15/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "ToolbarModel.h"
#import "ToolbarItem.h"

@implementation ToolbarModel

NSString* const toolbarFileName = @"Toolbar.plist";

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Subscribe", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.ToolBarModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
        
    [self.connection sendCommand:dict];
}

- (void)findCommands:(NSString *)commandName
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"FindCommands", @"CommandName", commandName, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (void)runCommand:(NSString *)commandText
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"RunCommand", @"CommandName", commandText, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (NSMutableDictionary*)getToolbarLayout
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:toolbarFileName];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableDictionary* items = nil;
    
    if (dict != nil)
    {
        items = [NSMutableDictionary dictionaryWithCapacity:dict.count];
        
        for (NSString* key in [dict allKeys])
        {
            ToolbarItem* tbi = [[ToolbarItem alloc] initFromDictionary:[dict objectForKey:key]];
            [items setValue:tbi forKey:tbi.itemId];
        }
    }
    
    return items;
}

- (void)saveToolbarLayout:(NSMutableDictionary*)items
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:toolbarFileName];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:[items count]];
    
    for (NSString* key in items.allKeys)
    {
        ToolbarItem* tbi = [items objectForKey:key];
        [dict setValue:[tbi toDictionary] forKey:tbi.itemId];
    }
    
    [dict writeToFile:filePath atomically:YES];    
}

- (void)resetToolbarLayout
{
    // get the Documents directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    // delete the file using NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[documentsDirectoryPath stringByAppendingPathComponent:toolbarFileName] error:nil];
}

- (NSMutableArray*)parseFindCommandsResponse:(NSDictionary *)response
{
    NSArray *items = [response valueForKey:@"Items"];
    NSMutableArray* toolbarItems = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for (id myArrayElement in items)
    {
        ToolbarItem *item = [[ToolbarItem alloc] initFromDictionary:myArrayElement];
        [toolbarItems addObject:item];
        //NSLog(@"Item=%@", item);
        item = nil;
    }
    
    return toolbarItems;
}

@end
