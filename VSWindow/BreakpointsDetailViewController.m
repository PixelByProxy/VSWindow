//
//  BreakpointsDetailViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 10/2/11.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "BreakpointsDetailViewController.h"
#import "DebuggerModel.h"
#import "BreakpointItem.h"
#import "StatefulUIButton.h"
#import "ExtendedUIBarButtonItem.h"

@interface BreakpointsDetailViewController ()

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) DebuggerModel* model;
@property (nonatomic, assign) NSInteger breakpointCount;
@property (nonatomic, retain) NSMutableArray* breakpointItems;

- (void)toggleEditMode:(id) sender;
- (void)displayEditMode:(StatefulUIButton*)btn editing:(BOOL)editing;
- (void)toggleDisableAllBreakpoints:(id) sender;
- (void)deleteAllClicked:(id) sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)updateControlsEnabledState:(BOOL) enabled;

@end

@implementation BreakpointsDetailViewController

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;
@synthesize model = _model;
@synthesize breakpointCount = _breakpointCount;
@synthesize breakpointItems = _breakpointItems;

#pragma mark - Private Methods

- (void)toggleEditMode:(id) sender
{
    StatefulUIButton* btn = (StatefulUIButton*)sender;
    BOOL editing = (btn.tag == 0);
    [self.tableView setEditing:editing];
    [self displayEditMode:btn editing:editing];
}

- (void)displayEditMode:(StatefulUIButton*)btn editing:(BOOL)editing
{
    if (btn == nil)
    {
        ExtendedUIBarButtonItem* bti = [self.navigationItem.rightBarButtonItems objectAtIndex:2];
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

- (void)toggleDisableAllBreakpoints:(id) sender
{
    StatefulUIButton* btn = (StatefulUIButton*)sender;
    
    if (btn.tag == 1)
    {
        [self.model enableAllBreakpoints];

        [btn setTag:0];
        [btn setTitle:@"Disable"];
        btn.selected = NO;
    }
    else
    {
        [self.model disableAllBreakpoints];

        [btn setTag:1];
        [btn setTitle:@"Enable"];
        btn.selected = YES;
    }
}

- (void)deleteAllClicked:(id) sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Breakpoints"
                                                    message:@"Delete all breakpoints?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
        [self.model deleteAllBreakpoints];
	}
}

- (void)updateControlsEnabledState:(BOOL) enabled
{
    // toggle the enabled state of the ui
    for (UIBarButtonItem* btn in self.navigationItem.rightBarButtonItems)
    {
        btn.enabled = enabled;
    }
}

#pragma mark - CommandResponseDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    
    if ([commandName isEqual:@"GetBreakpoints"])
    {
        self.breakpointCount = [[dict valueForKey:@"ItemCount"] integerValue];
        self.breakpointItems = [self.model parseGetBreakpointsResponse:dict];
        
        [self.tableView reloadData];
    }
}

- (void)connectionStateChanged:(BOOL) connected
{
    [self updateControlsEnabledState:connected && self.connection.activeInstance != nil];
    
    if (connected)
    {
        [self.model subscribe];
    }
}

- (void)instanceChanged:(InstanceItem *)instance
{
    if (instance != nil)
    {
        [self updateControlsEnabledState:self.connection.connected];
    }
    else
    {
        [self updateControlsEnabledState:NO];
    }
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Breakpoints", @"Breakpoints");
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

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.model = [[DebuggerModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];

    ExtendedUIBarButtonItem *editButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Edit" target:self action:@selector(toggleEditMode:)];
    ExtendedUIBarButtonItem *disableButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Disable" target:self action:@selector(toggleDisableAllBreakpoints:)];
    ExtendedUIBarButtonItem *deleteButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Delete" target:self action:@selector(deleteAllClicked:)];
    
    // set the initial enabled state
    BOOL enabled = self.connection.connected && self.connection.activeInstance != nil;
    editButton.enabled = enabled;
    disableButton.enabled = enabled;
    deleteButton.enabled = enabled;
    
    NSArray* rightButtons = [NSArray arrayWithObjects: deleteButton, disableButton, editButton, nil];
    [self.navigationItem setRightBarButtonItems:rightButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.appDelegate = nil;
    self.connection = nil;
    self.model = nil;
    self.breakpointItems = nil;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSString *BreakpointsTitleFormat = @"Breakpoints (showing %d of %d)";
    
    NSString* headerTitle = nil;
    
    if (self.breakpointItems != nil && self.breakpointCount > self.breakpointItems.count)
    {
        headerTitle = [NSString stringWithFormat:BreakpointsTitleFormat, self.breakpointItems.count, self.breakpointCount];
    }
    
    return headerTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if (self.breakpointItems != nil)
    {
        rows = self.breakpointItems.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BreakpointsCell";
    static NSString *commentCellDetailTextFormat = @"Line: %d  Character: %d";
    UITableViewCell *cell;
    
    BreakpointItem *item = [self.breakpointItems objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
        
    if (item.enabled == YES)
    {
        cell.imageView.image = [UIImage imageNamed:self.appDelegate.isRetina ? @"redcircle_full@2x.png" : @"redcircle_full.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:self.appDelegate.isRetina ? @"redcircle_empty@2x.png" : @"redcircle_empty.png"];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
    [cell.imageView addGestureRecognizer:tap];
    cell.imageView.userInteractionEnabled = YES;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:commentCellDetailTextFormat, item.fileLine, item.fileColumn];
    cell.textLabel.text = item.fileName;
    
    return cell;
}

- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer
{
    if (![self.connection connected])
    {
        return;
    }

    CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    BreakpointItem *item = [self.breakpointItems objectAtIndex:tappedIndexPath.row];
        
    if (item.enabled)
    {
        [self.model disableBreakpoint:item.breakpointId];
    }
    else
    {
        [self.model enableBreakpoint:item.breakpointId];
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.editing)
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
    BreakpointItem *item = [self.breakpointItems objectAtIndex:indexPath.row];
    
    [self.model deleteBreakpoint:item.breakpointId];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.connection connected])
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }

    BreakpointItem *item = [self.breakpointItems objectAtIndex:indexPath.row];
    
    [self.model navigateBreakpoint:item.breakpointId];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
