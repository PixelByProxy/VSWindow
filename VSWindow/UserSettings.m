//
//  SettingsModel.m
//  VSWindow
//
//  Created by Ryan Heideman on 10/7/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import "UserSettings.h"
#import "KeychainItemWrapper.h"

@implementation UserSettings

@synthesize activeConnection = _activeConnection;
@synthesize connections = _connections;

static NSString *PassIdentifier = @"VS Window.Connection.%@.Password";

NSUserDefaults* defaults;

- (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

#pragma mark - Public Methods

- (ConnectionSetting*)addConnection:(NSString *)name andPort:(NSInteger)port withPassword:(NSString*)password autoConnect:(BOOL)autoConnect;
{
    // create the connection object
    NSString* connId = [self getUUID];
    ConnectionSetting* setting = [[ConnectionSetting alloc] initWithValues:connId name:name andPort:port withPassword:password autoConnect:autoConnect];
    [self.connections addObject:setting];
    
    // get the connections
    NSMutableArray* savedConnections = [(NSMutableArray*)[defaults objectForKey:@"Connections"] mutableCopy];
    
    if (savedConnections == nil)
        savedConnections = [[NSMutableArray alloc] init];
    
    // create the dictionary from the object
    NSDictionary* settingDict = [setting dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"uniqueId", @"name", @"port", @"autoConnect", nil]];
    [savedConnections addObject:settingDict];
    [defaults setObject:savedConnections forKey:@"Connections"];

    // store the password
    if (password != nil || password.length == 0)
    {
        NSString* passKey = [NSString stringWithFormat:PassIdentifier, connId];
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:passKey accessGroup:nil];
        [keychainItem setObject:password forKey:(__bridge id)(kSecValueData)];
        keychainItem = nil;
    }
    
    return setting;
}

- (void)updateConnection:(NSString *)uniqueId withName:(NSString *)name andPort:(NSInteger)port withPassword:(NSString*)password autoConnect:(BOOL)autoConnect;
{
    NSArray* conns = (NSMutableArray*)[defaults objectForKey:@"Connections"];
    NSMutableArray *savedConnections = [conns mutableCopy];
    
    // get from the saved defaults
    if (savedConnections != nil && savedConnections.count > 0)
    {
        for (NSDictionary* dict in savedConnections) {
            
            NSString* connId = [dict valueForKey:@"uniqueId"];
            
            if ([connId isEqualToString:uniqueId])
            {
                // update the object
                NSMutableDictionary* editDict = [dict mutableCopy];
                [editDict setValue:name forKey:@"name"];
                [editDict setValue:[NSNumber numberWithInt:(int)port] forKey:@"port"];
                [editDict setValue:[NSNumber numberWithBool:autoConnect] forKey:@"autoConnect"];
                
                NSString* passKey = [NSString stringWithFormat:PassIdentifier, connId];
                KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:passKey accessGroup:nil];
                
                if (password == nil || password.length == 0)
                    [keychainItem resetKeychainItem];
                else
                    [keychainItem setObject:password forKey:(__bridge id)(kSecValueData)];
                
                keychainItem = nil;
                
                [savedConnections setObject:editDict atIndexedSubscript:[savedConnections indexOfObjectIdenticalTo:dict]];
                [defaults setObject:savedConnections forKey:@"Connections"];
                
                break;
            }
        }
    }
    
    // update the connection object
    ConnectionSetting* currentConn = nil;
    
    if (self.connections != nil && self.connections.count > 0)
    {
        for (ConnectionSetting* setting in self.connections) {
            
            if ([setting.uniqueId isEqualToString:uniqueId])
            {
                setting.name = name;
                setting.port = port;
                setting.autoConnect = autoConnect;
                setting.password = password;
                currentConn = setting;
                
                break;
            }
        }
    }

    // reset the active connection
    if (self.activeConnection != nil && [self.activeConnection.uniqueId isEqualToString:uniqueId])
    {
        self.activeConnection = currentConn;
    }
}

- (void)removeConnection:(NSString *)uniqueId
{
    // get the connections
    NSArray* conns = (NSMutableArray*)[defaults objectForKey:@"Connections"];
    NSMutableArray *savedConnections = [conns mutableCopy];
    
    // remove from the saved defaults
    if (savedConnections != nil && savedConnections.count > 0)
    {
        for (NSDictionary* dict in savedConnections) {
            
            NSString* connId = [dict valueForKey:@"uniqueId"];
            
            if ([connId isEqualToString:uniqueId])
            {
                [savedConnections removeObject:dict];
                
                NSString* passKey = [NSString stringWithFormat:PassIdentifier, connId];
                KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:passKey accessGroup:nil];
                [keychainItem resetKeychainItem];
                keychainItem = nil;
                
                [defaults setObject:savedConnections forKey:@"Connections"];
                
                break;
            }
        }
    }
    
    // reset the active connection
    if (self.activeConnection != nil && [self.activeConnection.uniqueId isEqualToString:uniqueId])
    {
        self.activeConnection = nil;
        [defaults removeObjectForKey:@"SelectedConnection"];
    }
    
    // remove from the connection objects
    if (self.connections != nil && self.connections.count > 0)
    {
        for (ConnectionSetting* setting in self.connections) {
            
            if ([setting.uniqueId isEqualToString:uniqueId])
            {
                [self.connections removeObject:setting];
                
                break;
            }
        }
    }
}


- (void)selectActiveConnection:(NSString *)uniqueId
{
    if (self.connections != nil && self.connections.count > 0)
    {
        for (ConnectionSetting* conn in self.connections) {
            
            if ([conn.uniqueId isEqualToString:uniqueId])
            {
                // update the default conn
                [defaults setValue:uniqueId forKey:@"SelectedConnection"];
                
                // load the connection info
                self.activeConnection = conn;

                break;
            }
        }
    }

    /*
    // get the connections
    NSMutableArray* savedConnections = (NSMutableArray*)[defaults objectForKey:@"Connections"];
    
    if (savedConnections != nil && savedConnections.count > 0)
    {
        for (NSDictionary* dict in savedConnections) {
            
            NSString* connId = [dict valueForKey:@"uniqueId"];
            
            if ([connId isEqualToString:uniqueId])
            {
                // update the default conn
                [defaults setValue:uniqueId forKey:@"SelectedConnection"];
                
                // load the connection info
                self.activeConnection = [[ConnectionSetting alloc] initFromDictionary:dict];
                
                break;
            }
        }
    } */
}

- (ConnectionSetting*)getConnectionById:(NSString *)uniqueId
{
    ConnectionSetting* setting = nil;
    
    if (self.connections != nil && self.connections.count > 0)
    {
        for (ConnectionSetting* conn in self.connections) {
            
            if ([conn.uniqueId isEqualToString:uniqueId])
            {
                setting = conn;
                
                break;
            }
        }
    }
    
    return setting;
}

#pragma mark - Init

-(id)init
{
    if (self = [super init])
    {
        defaults = [NSUserDefaults standardUserDefaults];
        self.connections = [[NSMutableArray alloc] init];
        NSMutableArray* savedConnections = (NSMutableArray*)[defaults objectForKey:@"Connections"];
        
        if (savedConnections != nil && savedConnections.count > 0)
        {
            for (NSDictionary* dict in savedConnections)
            {
                ConnectionSetting* connection = [[ConnectionSetting alloc] init];
                [connection setValuesForKeysWithDictionary:dict];

                // extract the password
                NSString* passKey = [NSString stringWithFormat:PassIdentifier, connection.uniqueId];
                KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:passKey accessGroup:nil];
                connection.password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
                keychainItem = nil;

                [self.connections addObject:connection];
            }
        }
        
        NSString* serverName = [defaults stringForKey:@"ServerName"];
        
        // for upgrade take the existing connection and
        // insert it into the array in the new format
        if (serverName != nil && serverName.length > 0)
        {
            NSInteger serverPort = [defaults integerForKey:@"ServerPort"];
            BOOL autoConnect = [defaults boolForKey:@"AutoConnect"];

            KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"VS Window" accessGroup:nil];
            NSString* serverPassword = [keychainItem objectForKey:(__bridge id)(kSecValueData)];

            // add it to the connection array
            ConnectionSetting* defaultConn = [self addConnection:serverName andPort:serverPort withPassword:serverPassword autoConnect:autoConnect];
            [defaults setValue:defaultConn.uniqueId forKey:@"SelectedConnection"];
            self.activeConnection = defaultConn;
            
            // delete the old values
            [defaults removeObjectForKey:@"ServerName"];
            [defaults removeObjectForKey:@"ServerPort"];
            [defaults removeObjectForKey:@"AutoConnect"];
            
            [keychainItem resetKeychainItem];
            keychainItem = nil;
        }
        else
        {
            // select the last active connection
            NSString* lastConnId = [defaults stringForKey:@"SelectedConnection"];
            if (lastConnId != nil && lastConnId.length > 0)
                [self selectActiveConnection:lastConnId];
        }
    }
    
    return self;
}

@end
