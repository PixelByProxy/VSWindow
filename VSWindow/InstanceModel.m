//
//  InstanceModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 2/11/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "InstanceModel.h"

@implementation InstanceModel

@synthesize currentInstance = _currentInstance;

#pragma mark - Public Methods

- (void)subscribe
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"ListInstances", @"CommandName", @"PixelByProxy.VSWindow.Server.Shared.Model.DocumentModel, PixelByProxy.VSWindow.Server.Shared", @"CommandArgs", nil];
        
    [self.connection sendCommand:dict];
}

- (void)loadInstances
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"ListInstances", @"CommandName", nil];
    
    [self.connection sendCommand:dict];
}

- (void)setActiveInstance:(InstanceItem*)instance
{
    self.currentInstance = instance;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"SetActiveInstance", @"CommandName", instance.connectionId, @"CommandArgs", nil];
    
    [self.connection sendCommand:dict];
}

- (NSMutableArray*)parseInstancesResponse:(NSDictionary *)response
{
    NSArray *items = [response valueForKey:@"Instances"];
    NSMutableArray* instances = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for (id item in items)
    {
        InstanceItem *instance = [[InstanceItem alloc] initFromDictionary:item];
        [instances addObject:instance];
        //NSLog(@"UserTask=%@", item);
        instance = nil;
    }

    return instances;
}

- (InstanceItem*)parseSetActiveInstanceResponse:(NSDictionary *)response
{
    NSDictionary* item = [response valueForKey:@"Instance"];
    
    InstanceItem *instance = [[InstanceItem alloc] initFromDictionary:item];

    return instance;
}

- (NSString*)parseInstanceClosedResponse:(NSDictionary *)response
{
    return [response valueForKey:@"CommandValue"];
}

@end
