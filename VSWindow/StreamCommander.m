//
//  StreamCommander.m
//  VSWindow
//
//  Created by Ryan Heideman on 4/17/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "StreamCommander.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSStream.h>
#import "SBjson.h"
#import "AppDelegate.h"
#import "CommandResponseDelegate.h"
#include <CFNetwork/CFSocketStream.h>
#import "InstanceModel.h"
@interface StreamCommander ()

@property (nonatomic, assign) BOOL connectInProgress;
@property (nonatomic, retain) NSMutableArray* subscribers;
@property (nonatomic, retain) NSMutableArray* commandQueue;
@property (nonatomic, retain) UIAlertView *busyBox;
@property (nonatomic, retain) NSTimer *connectionTimer;
@property (nonatomic, retain) NSTimer *idleTimer;
@property (nonatomic, retain) NSMutableData *dataBuffer;
@property (nonatomic, retain) NSOutputStream *oStream;
@property (nonatomic, retain) NSInputStream *iStream;

- (void)updateConnectionState:(BOOL)isConnected;
- (void)updateInstance:(InstanceItem*)instance;
- (void)sendNextCommand;
- (void)sendCommandToStream:(NSDictionary*) dict;
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent;
- (void)timerConnect:(id)sender;
- (void)clearTimer;
- (void)updateIdleTimer;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)showBusy;
- (void)hideBusy;
- (void)openStreams;
- (void)closeStreams;

@end

@implementation StreamCommander

@synthesize connectionDelegate = _connectionDelegate;
@synthesize connected = _connected;
@synthesize didShowConnectionError = _didShowConnectionError;
@synthesize activeInstance = _activeInstance;
@synthesize connectInProgress = _connectInProgress;
@synthesize subscribers = _subscribers;
@synthesize commandQueue = _commandQueue;
@synthesize busyBox = _busyBox;
@synthesize connectionTimer = _connectionTimer;
@synthesize dataBuffer = _dataBuffer;
@synthesize oStream = _oStream;
@synthesize iStream = _iStream;

NSInteger const expectedServiceVersion = 6;

#pragma mark - Public Methods

- (void)connect
{
    if (!self.connectInProgress)
    {
        self.connectInProgress = YES;
        [self updateConnectionState:NO];
        
        AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString* serverName = del.userSettings.activeConnection.name;
        NSInteger serverPort = del.userSettings.activeConnection.port;
        
        if (serverName != nil && serverName.length > 0)
        {
            [del showActivity];
            [self showBusy];
                        
            CFReadStreamRef readStream = NULL;
            CFWriteStreamRef writeStream = NULL;
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)serverName, (int)serverPort, &readStream, &writeStream);
            if (readStream && writeStream) {
                CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
                CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
                
                self.iStream = (__bridge NSInputStream *)readStream;
                self.oStream = (__bridge NSOutputStream *)writeStream;
            }
            
            if (readStream)
                CFRelease(readStream);
            
            if (writeStream)
                CFRelease(writeStream);

            [self openStreams];
        }
    }
}

- (void)disconnect
{
    [self clearTimer];
    
    if (self.connected == YES || self.connectInProgress)
    {
        [self closeStreams];
        AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [del hideActivity];
        [self hideBusy];
    }
}

- (void)sendCommand:(NSDictionary *) dict
{
    if (!self.oStream.hasSpaceAvailable)
    {
        [self.commandQueue addObject:dict];
    }
    else
    {
        [self sendCommandToStream:dict];
    }
}

- (void)subscribe:(id<CommandResponseDelegate>) subscriber
{
    if (self.subscribers == nil)
    {
        self.subscribers = [[NSMutableArray alloc] initWithObjects:subscriber, nil];
        [subscriber connectionStateChanged:self.connected];
    }
    else
    {
        if (![self.subscribers containsObject:subscriber])
        {
            [self.subscribers addObject:subscriber];
            [subscriber connectionStateChanged:self.connected];
        }
    }
}

- (void)unsubscribe:(id<CommandResponseDelegate>) subscriber
{
    if ([self.subscribers containsObject:subscriber])
        [self.subscribers removeObject:subscriber];
}

#pragma mark - Private Methods

- (void)updateConnectionState:(BOOL)isConnected
{
    if (self.connected != isConnected)
    {
        self.connected = isConnected;
        
        if (self.subscribers != nil)
        {
            for (id<CommandResponseDelegate> subscriber in self.subscribers) {
                [subscriber connectionStateChanged:isConnected];
            }
        }
        
        if (self.connectionDelegate != nil)
        {
            [self.connectionDelegate connectionStateChanged:isConnected];
        }
                
        AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (isConnected)
        {
            [del setMasterViewTitle:del.userSettings.activeConnection.name];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        }
        else
        {
            [del setMasterViewTitle:@"Explorer"];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
    }
    
    [self hideBusy];
}

- (void)updateInstance:(InstanceItem*)instance;
{
    self.activeInstance = instance;

    if (self.subscribers != nil)
    {
        for (id<CommandResponseDelegate> subscriber in self.subscribers) {
            [subscriber instanceChanged:instance];
        }
    }
    
    if (self.connectionDelegate != nil)
    {
        [self.connectionDelegate instanceChanged:instance];
    }
}

- (void)sendNextCommand
{
    if (self.commandQueue.count > 0)
    {
        NSDictionary* dict = [self.commandQueue objectAtIndex:0];
        [self.commandQueue removeObject:dict];        
        [self sendCommandToStream:dict];
    }
}

- (void)sendCommandToStream:(NSDictionary*) dict
{
    AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del showActivity];
    
    NSString *command = [dict JSONRepresentation];
    
    const uint8_t *rawString=(const uint8_t *)[command UTF8String];
    
    [self.oStream write:rawString maxLength:[command length]];
}

- (void)validateConnection:(NSDictionary*) dict
{
    AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BOOL isValid = YES;
    
    // validate the version
    NSInteger serviceVersion = [[dict valueForKey:@"ServiceVersion"] integerValue];
    if (serviceVersion != expectedServiceVersion)
    {
        isValid = NO;

        if (serviceVersion > expectedServiceVersion)
        {
            [del showAlert:@"Connection Error" message:@"An update to this application is required."];
        }
        else
        {
            [del showAlert:@"Connection Error" message:@"An update to the Visual Studio extension is required."];            
        }
    }
    
    // validate the password
    NSString* expectedPassword = del.userSettings.activeConnection.password;
    NSString* password = [dict valueForKey:@"Password"];
    
    if (expectedPassword != nil && (expectedPassword == (id)[NSNull null] || expectedPassword.length == 0))
    {
        expectedPassword = nil;
    }
    
    if (password != nil && (password == (id)[NSNull null] || password.length == 0))
    {
        password = nil;
    }
    
    if ((password != nil && password.length > 0 && ![password isEqualToString:expectedPassword]) || (password == nil && expectedPassword != nil))
    {
        isValid = NO;
        [del showAlert:@"Connection Error" message:@"Incorrect Password."];        
    }
    
    if (isValid)
    {
        [self updateConnectionState:YES];
    }
    else
    {
        [self closeStreams];
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
	printf("stream called\n");
    AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    switch(streamEvent) {
        case NSStreamEventHasSpaceAvailable:;
            [self sendNextCommand];
            break;
        case NSStreamEventHasBytesAvailable:;

            if (aStream == self.iStream && aStream.streamError == nil)
            {
                // reset the idle timer
                [self updateIdleTimer];
                
                //read data
                uint8_t buffer[1024];
                int len;
                while ([self.iStream hasBytesAvailable])
                {
                    len = (int)[self.iStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        if(!self.dataBuffer)
                        {
                            self.dataBuffer = [[NSMutableData alloc] initWithCapacity:8192];
                            [del showActivity];
                        }
                        
                        [self.dataBuffer appendBytes:(const void *)buffer length:len];
                        
                        // get the last character to see if we are done
                        NSInteger nullIndex = [self nullCharIndex:self.dataBuffer];
                        
                        while (nullIndex > -1)
                        {
                            // parse out the first command
                            NSData* data = [self.dataBuffer subdataWithRange:NSMakeRange(0, nullIndex)];
                            
                            if (data.length > 0)
                            {
                                NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                NSString* fixedString = [[NSString alloc] initWithUTF8String:[string UTF8String]]; // sometimes the buffer has the wrong size so we re-init it with the UTF8String
                               
                                //NSLog(@"Received %i-%i-%i-%i %@", self.dataBuffer.length, data.length, string.length, fixedString.length, fixedString);
                                
                                // send the json string to the delegate
                                NSDictionary* dict = [fixedString JSONValue];
                                
                                NSString* commandName = [dict valueForKey:@"CommandName"];
                                
                                if (!self.connected)
                                {
                                    // on the connect command we have to
                                    // validate the connection before moving on
                                    if ([commandName isEqual:@"Connected"])
                                    {
                                        [self validateConnection:dict];
                                    }
                                }
                                
                                if ([commandName isEqual:@"SetActiveInstance"])
                                {
                                    BOOL completed = [[dict valueForKey:@"CommandValue"] boolValue];
                                                                        
                                    if (completed)
                                    {
                                        InstanceModel* instanceModel = [[InstanceModel alloc] init];
                                        InstanceItem* instance = [instanceModel parseSetActiveInstanceResponse:dict];
                                        
                                        [self updateInstance:instance];
                                    }
                                }
                                else if ([commandName isEqual:@"InstanceClosed"])
                                {
                                    [self updateInstance:nil];
                                }


                                // notify the delegate the operation completed
                                if (self.subscribers != nil)
                                {
                                    for (id<CommandResponseDelegate> subscriber in self.subscribers) {
                                        [subscriber operationShouldProceed:dict];
                                    }
                                }

                                // cleanup
                                data = nil;
                                string = nil;
                                fixedString = nil;
                            }

                            // remove the command that was completed
                            [self.dataBuffer replaceBytesInRange:NSMakeRange(0, nullIndex + 1) withBytes:nil length:0];
                            
                            // get the next command index
                            nullIndex = [self nullCharIndex:self.dataBuffer];
                        }
                        
                        if (self.dataBuffer.length == 0)
                        {
                            self.dataBuffer = nil;
                            [del hideActivity];                            
                        }
                    }
                }    
            }
            
            break;
        case NSStreamEventEndEncountered:;
            printf("Close stream");
            [self closeStreams];
            [self connect];
            break;
        case NSStreamEventErrorOccurred:;
			printf("Stream Error");
            [self closeStreams];
            
            if (!self.didShowConnectionError)
            {
                self.didShowConnectionError = YES;

                static NSString *ConnectMessage = @"Unable to connect to %@.";
                [del showAlert:@"Connection Error" message:[NSString stringWithFormat:ConnectMessage, del.userSettings.activeConnection.name]];
            }
            
            // attempt another connection if we are not
            // in the connection settings dialog
            if (del.userSettings.activeConnection.autoConnect && self.connectionDelegate == nil)
            {
                [self clearTimer];
                self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerConnect:) userInfo:nil repeats:NO];
            }
            else
            {
                [del hideActivity];
            }
            
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventNone:
        default:
            break;
    }
}

- (NSInteger)nullCharIndex:(NSMutableData*)data
{
    const char endChar = '\0';
    NSInteger charIndex = -1;
    const char *bytes = [data bytes];
    
    for(int i = 0; i < data.length; i++)
    {
        if (bytes[i] == endChar)
        {
            charIndex = i;
            break;
        }
    }
    
    return charIndex;
}

- (void)timerConnect:(id)sender
{
    self.connectionTimer = nil;
    [self connect];
}

- (void)clearTimer;
{
    if (self.connectionTimer != nil)
    {
        [self.connectionTimer invalidate];
        self.connectionTimer = nil;
    }
}

- (void)updateIdleTimer
{
    // reset the timer
    if (self.idleTimer != nil)
    {
        [self.idleTimer invalidate];
    }
    else
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    
    self.idleTimer = [NSTimer scheduledTimerWithTimeInterval:600.0 target:self selector:@selector(timerEnableIdle:) userInfo:nil repeats:NO];
}

- (void)timerEnableIdle:(id)sender
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.idleTimer = nil;
    NSLog(@"Idle Timer Enabled");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        [self disconnect];
    }
}

- (void)showBusy
{
    if (self.connectionDelegate != nil)
    {
        AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.busyBox = [del showBusy:@"Connecting..." withDelegate:self];
    }
}

- (void)hideBusy
{
    // hide the busy dialog
    if (self.busyBox != nil)
    {
        [self.busyBox dismissWithClickedButtonIndex:0 animated:YES];
        self.busyBox = nil;
    }
}

- (void)openStreams
{
	printf("openStreams called\n");
    [self.iStream setDelegate:self];
    [self.oStream setDelegate:self];
    [self.iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.iStream open];
    [self.oStream open];
    self.commandQueue = [NSMutableArray array];
}

- (void)closeStreams
{
	printf("closeStreams called\n");
    [self.iStream close];
    [self.oStream close];
    [self.iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.iStream setDelegate:nil];
    [self.oStream setDelegate:nil];
    self.iStream = nil;
    self.oStream = nil;
    self.connectInProgress = NO;
    self.commandQueue = nil;
    [self updateConnectionState:NO];
}

@end