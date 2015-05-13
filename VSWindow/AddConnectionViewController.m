//
//  AddConnectionViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/28/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "AddConnectionViewController.h"
#import "SettingUITableViewCell.h"
#import "ExtendedUIBarButtonItem.h"

@interface AddConnectionViewController ()

@property (nonatomic, retain) NSString *serverUniqueId;
@property (nonatomic, retain) NSString *serverName;
@property (nonatomic, assign) NSInteger serverPort;
@property (nonatomic, retain) NSString *serverPassword;
@property (nonatomic, assign) BOOL autoConnect;
@property (nonatomic, retain) UITextField *activeTextField;

- (void)settingChanged:(NSInteger) row newValue:(NSString*)newValue;
- (BOOL)isValid;

@end

@implementation AddConnectionViewController

@synthesize serverName = _serverName;
@synthesize serverPort = _serverPort;
@synthesize serverPassword = _serverPassword;
@synthesize autoConnect = _autoConnect;
@synthesize activeTextField = _activeTextField;

#pragma mark - Private Methods

- (void)settingChanged:(NSInteger) row newValue:(NSString*)newValue
{
    NSNumber* number = nil;
    
    if (row == 1)
    {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        number = [f numberFromString:newValue];
    }
    
    switch (row)
    {
        case 0:
            self.serverName = newValue;
            break;
        case 1:
            self.serverPort = number == nil ? 0 : [number integerValue];
            break;
        case 2:
            self.serverPassword = newValue;
            break;
        default:
            break;
    }
}

- (BOOL)isValid
{
    NSString* msg = @"";
    
    // validate the server name
    if (self.serverName == nil || self.serverName.length == 0)
        msg = [msg stringByAppendingString:@"The Server is required."];
    
    // validate the port
    if (self.serverPort < 1 || self.serverPort > 65535)
    {
        if (msg.length > 0)
            msg = [msg stringByAppendingString:@"\n"];
        
        msg = [msg stringByAppendingString:@"The Port must be between 1 and 65535."];
    }
    
    BOOL valid = msg.length == 0;
    
    if (!valid)
        [self.appDelegate showAlert:@"Validation Failed" message:msg];
    
    return valid;
}

- (void)switchChanged:(UISwitch*)sender
{
    self.autoConnect = sender.on;
}

- (void)saveClicked:(id)sender
{
    if (self.activeTextField != nil)
        [self.activeTextField resignFirstResponder];
    
    if ([self isValid])
    {
        if (self.serverUniqueId == nil)
            [self.appDelegate.userSettings addConnection:self.serverName andPort:self.serverPort withPassword:self.serverPassword autoConnect:self.autoConnect];
        else
            [self.appDelegate.userSettings updateConnection:self.serverUniqueId withName:self.serverName andPort:self.serverPort withPassword:self.serverPassword autoConnect:self.autoConnect];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (void) activeTextFieldChanged:(UITextField*) newField
{
    self.activeTextField = newField;
}

#pragma mark - View lifecycle

- (id)initWithConnection:(NSString *)uniqueId
{
    self = [super initWithNibName:@"AddConnectionViewController" bundle:nil];
    if (self) {
        self.serverUniqueId = uniqueId;
        AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        ConnectionSetting* conn = [del.userSettings getConnectionById:self.serverUniqueId];
        if (conn != nil)
        {
            self.serverName = conn.name;
            self.serverPort = conn.port;
            self.serverPassword = conn.password;
            self.autoConnect = conn.autoConnect;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    ExtendedUIBarButtonItem *addButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Save" target:self action:@selector(saveClicked:)];
    [self.navigationItem setRightBarButtonItem:addButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.serverName = nil;
    self.serverPassword = nil;
    self.activeTextField = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellNib = @"SettingUITableViewCell";
    static NSString *CellIdentifier = @"SettingCell";
    static NSString *SwitchCellIdentifer = @"SwitchCell";
    
    if (indexPath.row == 3)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifer];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SwitchCellIdentifer];
            cell.textLabel.text = @"Auto-Reconnect when available";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView setOn:self.autoConnect animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
        
        return cell;
    }
    else
    {
        SettingUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = (SettingUITableViewCell *)[SettingUITableViewCell cellFromNibNamed:CellNib];
        }
        
        [cell setDelegate:self];
        [[cell masterText] setTag:indexPath.row];
        
        switch (indexPath.row) {
            case 0:
                [cell setCellValue:@"Server" withValue:self.serverName andPlaceholder:@"Computer Name or IP Address"];
                break;
            case 1:
                
                if (self.serverPort == 0)
                {
                    self.serverPort = 39739;
                }
                
                [cell setCellValue:@"Port" withValue:[NSString stringWithFormat:@"%ld", (long)self.serverPort] andPlaceholder:@"39739"];
                [cell.masterText setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            case 2:
                cell.masterText.secureTextEntry = YES;
                [cell setCellValue:@"Password" withValue:self.serverPassword andPlaceholder:@"Optional"];
                break;
            default:
                break;
        }
        
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSString *ConnectTitle = @"Connection";
    
    return ConnectTitle;
}

@end
