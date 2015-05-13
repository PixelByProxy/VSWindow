//
//  ConnectionViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 10/5/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import "ConnectionViewController.h"
#import "SettingUITableViewCell.h"
#import "ExtendedUIBarButtonItem.h"
#import "AddConnectionViewController.h"
#import "ConnectionSetting.h"

@interface ConnectionViewController ()

- (void)dismissDialog;
- (void)addClicked:(id)sender;
- (void)toggleEditMode:(id) sender;
- (void)displayEditMode:(StatefulUIButton*)btn editing:(BOOL)editing;

@end

@implementation ConnectionViewController

@synthesize masterTableView = _masterTableView;

#pragma mark - Private Methods

- (void)dismissDialog
{
    // close the dialog
    [self.appDelegate dismissModalViewController];
}

- (void)addClicked:(id)sender
{
    AddConnectionViewController *controller = [[AddConnectionViewController alloc] initWithNibName:@"AddConnectionViewController" bundle:nil];
    [controller.navigationItem setTitle:@"Add Connection"];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)editClicked:(NSString*)connectionId
{
    AddConnectionViewController *controller = [[AddConnectionViewController alloc] initWithConnection:connectionId];
    [controller.navigationItem setTitle:@"Edit Connection"];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toggleEditMode:(id) sender
{
    StatefulUIButton* btn = (StatefulUIButton*)sender;
    BOOL editing = (btn.tag == 0);
    [self.masterTableView setEditing:editing];
    [self displayEditMode:btn editing:editing];
}

- (void)displayEditMode:(StatefulUIButton*)btn editing:(BOOL)editing
{
    if (btn == nil)
    {
        ExtendedUIBarButtonItem* bti = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        btn = bti.metroButton;
    }
    
    if (editing)
    {
        [btn setTag:1];
        btn.selected = YES;
        btn.title = @"Done";
    }
    else
    {
        [btn setTag:0];
        btn.selected = NO;
        btn.title = @"Edit";
    }
}

#pragma mark - Public Methods

- (IBAction)cancelClicked:(id)sender
{
    [self dismissDialog];
}

#pragma mark - ConnectionStateChangedDelegate

- (void)connectionStateChanged:(BOOL) connected
{
    if (connected)
    {
        [self dismissDialog];
    }
}

- (void)instanceChanged:(InstanceItem *)instance
{
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    ExtendedUIBarButtonItem *editButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Edit" target:self action:@selector(toggleEditMode:)];
    ExtendedUIBarButtonItem *addButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Add" target:self action:@selector(addClicked:)];

    NSArray* rightButtons = [NSArray arrayWithObjects: addButton, editButton, nil];
    [self.navigationItem setRightBarButtonItems:rightButtons];

    ExtendedUIBarButtonItem *cancelButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Cancel" target:self action:@selector(cancelClicked:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.masterTableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.masterTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.appDelegate.connection.connectionDelegate = nil;
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
    if (self.appDelegate.userSettings.connections.count > 0)
        return self.appDelegate.userSettings.connections.count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConnectionSettingCell";
    static NSString *CellDetailTextFormat = @"Port: %d   Auto-Reconnect: %@   Secured with Password: %@";
    
    UITableViewCell* cell = [self.masterTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (self.appDelegate.userSettings.connections.count > 0)
    {
        ConnectionSetting* connection = [self.appDelegate.userSettings.connections objectAtIndex:indexPath.row];
        
        NSString* hasPassword = connection.password != nil && connection.password.length > 0 ? @"Yes" : @"No";
        NSString* autoConnect = connection.autoConnect ? @"Yes" : @"No";
        
        cell.textLabel.text = connection.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:CellDetailTextFormat, connection.port, autoConnect, hasPassword];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else
    {
        cell.textLabel.text = @"Add Connection...";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.masterTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.appDelegate.userSettings.connections.count > 0)
    {
        // set the active connection
        ConnectionSetting* connection = [self.appDelegate.userSettings.connections objectAtIndex:indexPath.row];
        [self.appDelegate.userSettings selectActiveConnection:connection.uniqueId];

        // close and re-open the connection
        [self.appDelegate closeConnection];
        self.appDelegate.connection.didShowConnectionError = NO;
        self.appDelegate.connection.connectionDelegate = self;
        [self.appDelegate getConnection];
    }
    else
    {
        [self addClicked:nil];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ConnectionSetting* conn = [self.appDelegate.userSettings.connections objectAtIndex:indexPath.row];
    
    // close the connection if editing the active
    if (self.appDelegate.userSettings.activeConnection != nil && [self.appDelegate.userSettings.activeConnection.uniqueId isEqualToString:conn.uniqueId])
    {
        [self.appDelegate closeConnection];
    }

    [self editClicked:conn.uniqueId];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSString *ConnectTitle = @"Connections";

    return ConnectTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    static NSString *ConnectFooter = @"You must install the VS Window Visual Studio extension and have the specified port open on your Firewall in order to use this application.";

    return ConnectFooter;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.appDelegate.userSettings.connections.count > 0;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.masterTableView.editing)
    {
        [self displayEditMode:nil editing:true];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self displayEditMode:nil editing:false];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConnectionSetting *conn = [self.appDelegate.userSettings.connections objectAtIndex:indexPath.row];
    
    if (self.appDelegate.userSettings.activeConnection != nil && [self.appDelegate.userSettings.activeConnection.uniqueId isEqualToString:conn.uniqueId])
    {
        [self.appDelegate closeConnection];
    }
    
    [self.appDelegate.userSettings removeConnection:conn.uniqueId];
    
    [self displayEditMode:nil editing:false];
    [self.masterTableView reloadData];
}

@end
