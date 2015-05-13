//
//  CommandModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/8/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "CommandModel.h"

@implementation CommandModel

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Subscribe", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.CommandModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
        
    [self.connection sendCommand:dict];
}

- (void)clearWindow
{
    if (!self.connection.connected)
        return;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"ClearCommandWindowText", @"CommandName", nil];
    
    [self.connection sendCommand:dict];
}

- (void)runCommand:(NSString *)commandText
{
    if (!self.connection.connected)
        return;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"RunCommand", @"CommandName", commandText, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (NSString*)parseGetCommandWindowTextResponse:(NSDictionary *)response
{
    static NSString *HtmlFormat = @"<html><head><meta name='viewport' content=width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=100'></head><body style='white-space:nowrap;'>%@</body></html>";

    NSString *text = [response valueForKey:@"CommandValue"];
    return [NSString stringWithFormat:HtmlFormat, [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"]];
}

@end
