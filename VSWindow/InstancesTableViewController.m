//
//  InstancesTableViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 2/11/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "InstancesTableViewController.h"
#import "InstanceModel.h"
#import "InstanceItem.h"
#import "ExtendedUIBarButtonItem.h"

@interface InstancesTableViewController ()

@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) InstanceModel* model;
@property (nonatomic, retain) NSMutableArray *instances;
@property (nonatomic, retain) UIAlertView* busyBox;

@end

@implementation InstancesTableViewController

@synthesize connection = _connection;
@synthesize model = _model;
@synthesize instances = _instances;
@synthesize busyBox = _busyBox;

#pragma mark - Private Methods

- (void)dismissDialog
{
    // close the dialog
    [self.appDelegate dismissModalViewController];
}

- (IBAction)cancelClicked:(id)sender
{
    [self dismissDialog];
}

#pragma mark - InstancesModelDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    
    if ([commandName isEqual:@"Instances"])
    {
        self.instances = [self.model parseInstancesResponse:dict];
        
        [self.tableView reloadData];
    }
    else if ([commandName isEqual:@"SetActiveInstance"])
    {
        BOOL completed = [[dict valueForKey:@"CommandValue"] boolValue];

        if (self.busyBox)
        {
            [self.busyBox dismissWithClickedButtonIndex:0 animated:NO];
            self.busyBox = nil;
        }
        
        if (completed)
        {
            [self dismissDialog];
        }
        else
        {
            [self.appDelegate showAlert:@"Failed" message:@"Unable to select that instance."];
            [self.model subscribe];
        }
    }
    else if ([commandName isEqual:@"InstanceClosed"])
    {
        [self.model subscribe];
    }
}

- (void)connectionStateChanged:(BOOL) connected
{
    if (connected)
    {
        [self.model subscribe];
    }
    else
    {
        [self.instances removeAllObjects];
        [self.tableView reloadData];
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
        self.title = NSLocalizedString(@"Visual Studio Instances", @"Visual Studio Instances");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [[InstanceModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];

    ExtendedUIBarButtonItem *cancelButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Cancel" target:self action:@selector(cancelClicked:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.connection = nil;
    self.appDelegate = nil;
    self.model = nil;
    self.instances = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.connection subscribe:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.connection unsubscribe:self];
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
    return self.instances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InstanceCell";
    static NSString *DetailFormat = @"Visual Studio %d - Process ID: %d";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    InstanceItem* item = [self.instances objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:DetailFormat, item.version, item.processId];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSString *Title = @"Select Instance";
    
    return Title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstanceItem* item = [self.instances objectAtIndex:indexPath.row];
    
    self.busyBox = [self.appDelegate showBusy:@"Selecting..." withDelegate:nil];
    
    [self.model setActiveInstance:item];    
}

@end
