//
//  MasterViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 9/30/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BreakpointsDetailViewController.h"
#import "OutputDetailViewController.h"
#import "ConnectionViewController.h"
#import "TaskListDetailViewController.h"
#import "ErrorListDetailViewController.h"
#import "CommandWindowDetailViewController.h"
#import "OpenDocumentsDetailViewController.h"
#import "CompressedUITableViewCell.h"
#import "ExtendedUIBarButtonItem.h"
#import "FormSheetUINavigationController.h"
#import "InstancesTableViewController.h"
#import "InstanceModel.h"
#import "SolutionExplorerDetailViewController.h"

@interface MasterViewController ()

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;

- (void)showConnectionDialog:(id) sender;
- (void)updateInstanceTitle:(InstanceItem*)instance;


@end

@implementation MasterViewController

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;
@synthesize detailViewController = _detailViewController;

const NSInteger InstanceTitleTag = 1000;
static NSString *NoInstanceTitle = @"No instance selected";
static NSString *NotConnectedTitle = @"Not connected";

#pragma mark - Private Methods

- (void)showInstanceDialog:(id) sender
{
    InstancesTableViewController *controller = [[InstancesTableViewController alloc] initWithNibName:@"InstancesTableViewController" bundle:nil];
    
    FormSheetUINavigationController *navController = [[FormSheetUINavigationController alloc] initWithRootViewController:controller];
    
    [self.appDelegate presentModalViewController:navController];
}

- (void)showConnectionDialog:(id) sender
{
    ConnectionViewController *controller = [[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil];
    
    FormSheetUINavigationController *navController = [[FormSheetUINavigationController alloc] initWithRootViewController:controller];
    
    [self.appDelegate presentModalViewController:navController];
}

- (void)updateInstanceTitle:(InstanceItem*)instance
{
    UILabel* label = (UILabel*)[self.tableView viewWithTag:InstanceTitleTag];
    
    if (instance == nil)
        instance = self.connection.activeInstance;
    
    if (!self.connection.connected)
    {
        label.text = NotConnectedTitle;        
    }
    else if (self.connection.activeInstance != nil)
    {
        static NSString *DetailFormat = @"%@ (%d)";
        label.text = [NSString stringWithFormat:DetailFormat, instance.solutionName.length > 0 ? instance.solutionName : instance.title, instance.processId];
    }
    else
    {
        label.text = NoInstanceTitle;
    }
}

#pragma mark - InstancesModelDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    UILabel* label = (UILabel*)[self.tableView viewWithTag:InstanceTitleTag];
    
    if ([commandName isEqual:@"WindowChanged"])
    {
        InstanceModel* instanceModel = [[InstanceModel alloc] init];
        InstanceItem* instance = [instanceModel parseSetActiveInstanceResponse:dict];
        
        [self instanceChanged:instance];
    }
    else if ([commandName isEqual:@"Connected"])
    {
        NSString *title = [dict valueForKey:@"InstanceTitle"];
        
        label.text = title;
    }
}

- (void)connectionStateChanged:(BOOL) connected
{
    UILabel* label = (UILabel*)[self.tableView viewWithTag:InstanceTitleTag];

    if (!connected)
    {        
        label.text = NotConnectedTitle;
    }
    else if ([label.text isEqualToString:NotConnectedTitle])
    {
        label.text = NoInstanceTitle;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = connected;
}

- (void)instanceChanged:(InstanceItem *)instance
{
    [self updateInstanceTitle:instance];
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Explorer", @"Explorer");
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    return self;
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.connection = [self.appDelegate getConnection];
    
    // add the connection button
    ExtendedUIBarButtonItem *instanceButton = [[ExtendedUIBarButtonItem alloc] initWithMetroImage:[UIImage imageNamed:@"instances.png"] target:self action:@selector(showInstanceDialog:)];
    ExtendedUIBarButtonItem *actionButton = [[ExtendedUIBarButtonItem alloc] initWithMetroImage:[UIImage imageNamed:@"gear.png"] target:self action:@selector(showConnectionDialog:)];
    
    instanceButton.enabled = self.connection.connected;
    
    [self.navigationItem setLeftBarButtonItem:instanceButton];
    [self.navigationItem setRightBarButtonItem:actionButton];
    
    // set the bg color for iOS 7
    self.tableView.backgroundColor = [UIColor colorWithRed:0.968628 green:0.968628 blue:0.968628 alpha:1];

    // select the first row by default
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // set the nav bar appearance
    UIImage *image = [UIImage imageNamed:@"navbg@ios7.png"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.appDelegate = nil;
    self.connection = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // update the toolbar text
    [self updateInstanceTitle:self.connection.activeInstance];

    [self.connection subscribe:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

    [self.connection unsubscribe:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
	[v setBackgroundColor:[UIColor grayColor]];
    
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, -10, tableView.bounds.size.width - 10,40)];
	label.text = NotConnectedTitle;
    label.tag = InstanceTitleTag;
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
	label.backgroundColor = [UIColor clearColor];
	[v addSubview:label];
    
	return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MasterCell";
    
    CompressedUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CompressedUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:0.968628 green:0.968628 blue:0.968628 alpha:1];
    }

    // Configure the cell.
    NSString *text = nil;
    
    switch (indexPath.row) {
        case 0:;
            text = NSLocalizedString(@"Toolbar", @"Toolbar");
            cell.imageView.image = [UIImage imageNamed:@"toolbar_icon.png"];
            break;
        /*
        case 1:;
            text = NSLocalizedString(@"Solution Explorer", @"Solution Explorer");
            cell.imageView.image = [UIImage imageNamed:@"document_icon.png"];
            break;
        */
        case 1:;
            text = NSLocalizedString(@"Open Documents", @"Open Documents");
            cell.imageView.image = [UIImage imageNamed:@"document_icon.png"];
            break;
        case 2:;
            text = NSLocalizedString(@"Breakpoints", @"Breakpoints");
            cell.imageView.image = [UIImage imageNamed:@"breakpoint_icon.png"];
            break;
        case 3:;
            text = NSLocalizedString(@"Output", @"Output");
            cell.imageView.image = [UIImage imageNamed:@"output_icon.png"];
            break;
        case 4:;
            text = NSLocalizedString(@"Command", @"Command");
            cell.imageView.image = [UIImage imageNamed:@"command_icon.png"];
            break;
        case 5:;
            text = NSLocalizedString(@"Task List", @"Task List");
            cell.imageView.image = [UIImage imageNamed:@"task_icon.png"];
            break;
        case 6:;
            text = NSLocalizedString(@"Error List", @"Error List");
            cell.imageView.image = [UIImage imageNamed:@"error_icon.png"];
            break;
        default:
            break;
    }
    
    cell.textLabel.text = text;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller = nil;
    
    switch (indexPath.row) {
        case 0:;
            controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
            break;
        /*
        case 1:;
            controller = [[SolutionExplorerDetailViewController alloc] initWithNibName:@"SolutionExplorerDetailViewController" bundle:nil];
            break;
        */
        case 1:;
            controller = [[OpenDocumentsDetailViewController alloc] initWithNibName:@"OpenDocumentsDetailViewController" bundle:nil];
            break;
        case 2:;
            controller = [[BreakpointsDetailViewController alloc] initWithNibName:@"BreakpointsDetailViewController" bundle:nil];
            break;
        case 3:;
            controller = [[OutputDetailViewController alloc] initWithNibName:@"OutputDetailViewController" bundle:nil];
            break;
        case 4:;
            controller = [[CommandWindowDetailViewController alloc] initWithNibName:@"CommandWindowDetailViewController" bundle:nil];
            break;
        case 5:;
            controller = [[TaskListDetailViewController alloc] initWithNibName:@"TaskListDetailViewController" bundle:nil];
            break;
        case 6:;
            controller = [[ErrorListDetailViewController alloc] initWithNibName:@"ErrorListDetailViewController" bundle:nil];
            break;
        default:
            break;
    }
    
    [self.appDelegate setDetailController:controller];
}

@end
