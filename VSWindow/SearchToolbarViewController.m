//
//  SearchToolbarViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "SearchToolbarViewController.h"
#import "ToolbarItem.h"
#import "ExtendedUIBarButtonItem.h"

@interface SearchToolbarViewController ()

@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) ToolbarModel* model;
@property (nonatomic, assign) BOOL maxItemsMessageShown;
@property (nonatomic, assign) NSInteger initialItemCount;
@property (nonatomic, assign) NSInteger maxItemCount;
@property (nonatomic, retain) NSMutableArray *listOfItems;
@property (nonatomic, retain) NSMutableDictionary *selectedItems;

- (void)searchTableView;
- (void)searchFinished:(id)sender;
- (void)cancelClicked:(id)sender;
- (void)saveClicked:(id)sender;
- (void)updateControlsEnabledState;

@end

@implementation SearchToolbarViewController

@synthesize connection = _connection;
@synthesize model = _model;
@synthesize maxItemsMessageShown = _maxItemsMessageShown;
@synthesize initialItemCount = _initialItemCount;
@synthesize maxItemCount = _maxItemCount;
@synthesize listOfItems = _listOfItems;
@synthesize selectedItems = _selectedItems;
@synthesize masterSearchBar = _masterSearchBar;

#pragma mark - Private Methods

- (void)searchTableView
{
    if (!self.connection.connected || self.connection.activeInstance == nil)
        return;
    
    [self.model findCommands:self.masterSearchBar.text];
}

- (void)searchFinished:(id)sender
{    
    [self.masterSearchBar setText:@""];
    [self.masterSearchBar resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.tableView reloadData];
}

- (void)cancelClicked:(id)sender
{
    [self.delegate dialogClosed];
    [self.appDelegate dismissModalViewController];
}

- (void)saveClicked:(id)sender
{
    [self.delegate commandsAdded:self.selectedItems];
    [self.delegate dialogClosed];
    [self.appDelegate dismissModalViewController];
}

- (void)updateControlsEnabledState
{
    NSInteger totalItemCount = (self.initialItemCount + self.selectedItems.count);
    [self.navigationItem.rightBarButtonItem setEnabled: (self.selectedItems.count > 0 && totalItemCount <= self.maxItemCount && self.connection.connected && self.connection.activeInstance != nil)];
}

#pragma mark - CommandResponseDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    
    if ([commandName isEqual:@"FindCommands"])
    {
        NSMutableArray* toolbarItems = [self.model parseFindCommandsResponse:dict];

        self.listOfItems = toolbarItems;
        [self.selectedItems removeAllObjects];
        [self.navigationItem.rightBarButtonItem setEnabled: NO];
        
        [self.tableView reloadData];
    }
}

- (void)connectionStateChanged:(BOOL) connected
{
    [self updateControlsEnabledState];
    
    if (connected)
    {
        [self.model subscribe];
    }
}

- (void)instanceChanged:(InstanceItem *)instance
{
    [self updateControlsEnabledState];
}

#pragma mark - UISearchBarDelegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{    
    [self searchTableView];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{    
    [self searchTableView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // initialize the view
    [self.navigationItem setTitle:@"Add Commands"];
    [self.tableView setTableHeaderView:self.masterSearchBar];
    
    self.model = [[ToolbarModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];

    // add the navigation buttons
    ExtendedUIBarButtonItem *addButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Add" target:self action:@selector(saveClicked:)];
    [addButton setEnabled:NO];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    ExtendedUIBarButtonItem *cancelButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Cancel" target:self action:@selector(cancelClicked:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];

    self.selectedItems = [[NSMutableDictionary alloc] init];
    self.initialItemCount = [self.delegate initialItemCount];
    self.maxItemCount = [self.delegate maxItemCount];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.connection = nil;
    self.model = nil;
    self.listOfItems = nil;
    self.selectedItems = nil;
    self.delegate = nil;
    self.masterSearchBar = nil;
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
    NSInteger rows = 0;
    
    if (self.listOfItems != nil)
    {
        rows = self.listOfItems.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ToolbarItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    ToolbarItem* item = [self.listOfItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.itemId;
    cell.detailTextLabel.text = item.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.selectedItems objectForKey:item.itemId] == nil)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToolbarItem* item = [self.listOfItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    // update the check mark
    if ([self.selectedItems objectForKey:item.itemId] == nil)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedItems setValue:item forKey:item.itemId];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedItems removeObjectForKey:item.itemId];
    }
    
    // enable/disable the save button
    NSInteger totalItemCount = (self.initialItemCount + self.selectedItems.count);
    [self.navigationItem.rightBarButtonItem setEnabled: (self.selectedItems.count > 0 && totalItemCount <= self.maxItemCount && self.connection.connected && self.connection.activeInstance != nil)];
    
    // show an alert to the user if they are selecting more item than allowed
    if (!self.maxItemsMessageShown && totalItemCount > self.maxItemCount)
    {
        self.maxItemsMessageShown = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Toolbar"
                                                        message:[NSString stringWithFormat:@"The Toolbar can only contain %li items.", (long)self.maxItemCount]
                                                        delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
