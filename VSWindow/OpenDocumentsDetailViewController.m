//
//  OpenDocumentsDetailViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 9/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "OpenDocumentsDetailViewController.h"
#import "DocumentModel.h"
#import "DocumentItem.h"
#import "ExtendedUIBarButtonItem.h"

@interface OpenDocumentsDetailViewController ()

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) DocumentModel* model;
@property (nonatomic, assign) NSInteger openDocCount;
@property (nonatomic, retain) NSMutableArray* openDocs;

- (void)closeAll:(id)sender;
- (void)updateControlsEnabledState;
- (void)toggleEditMode:(id) sender;
- (void)displayEditMode:(StatefulUIButton*)btn editing:(BOOL)editing;

@end

@implementation OpenDocumentsDetailViewController

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;
@synthesize model = _model;
@synthesize openDocCount = _openDocCount;
@synthesize openDocs = _openDocs;

#pragma mark - Private Methods

- (void)closeAll:(id)sender
{
    [self.model closeAll];
}

- (void)updateControlsEnabledState
{
    BOOL enabled = self.connection.connected && self.connection.activeInstance != nil;
    
    // toggle the enabled state of the ui
    for (UIBarButtonItem* btn in self.navigationItem.rightBarButtonItems)
    {
        btn.enabled = enabled;
    }
}

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

#pragma mark - CommandResponseDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    
    if ([commandName isEqual:@"GetOpenDocuments"])
    {
        self.openDocCount = [[dict valueForKey:@"OpenDocumentCount"] integerValue];
        self.openDocs = [self.model parseGetOpenDocumentsResponse:dict];
        
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

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Open Documents", @"Open Documents");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.model = [[DocumentModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];
    
    ExtendedUIBarButtonItem *editButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Edit" target:self action:@selector(toggleEditMode:)];
    ExtendedUIBarButtonItem *closeButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Close All" target:self action:@selector(closeAll:)];
    
    // set the initial enabled state
    editButton.enabled = self.connection.connected && self.connection.activeInstance != nil;
    closeButton.enabled = self.connection.connected && self.connection.activeInstance != nil;

    NSArray* rightButtons = [NSArray arrayWithObjects: closeButton, editButton, nil];
    [self.navigationItem setRightBarButtonItems:rightButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.appDelegate = nil;
    self.connection = nil;
    self.model = nil;
    self.openDocs = nil;
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
    return self.openDocCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OpenDocCell";
    static NSString *itemTextFormat = @"%@ *";
    UITableViewCell *cell;
    
    DocumentItem *item = [self.openDocs objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (item.saved)
    {
        cell.textLabel.text = item.name;
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:itemTextFormat, item.name];
    }
    
    if (item.documentId != nil && item.documentId.length > 0)
    {
        NSArray* pathParts = [item.documentId componentsSeparatedByString:@"\\"];
        
        if (pathParts.count > 1)
            cell.detailTextLabel.text = [[pathParts subarrayWithRange:NSMakeRange(0, pathParts.count - 1)] componentsJoinedByString:@"\\"];
    }
    
    /*
    if (item.readOnly == YES)
    {
        cell.imageView.image = [UIImage imageNamed:@"lock.png"];
    }
    else
    {
        cell.imageView.image = nil;
    }
    */

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Close";
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
    DocumentItem *item = [self.openDocs objectAtIndex:indexPath.row];
    
    [self.model close:item.documentId];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.connection.connected || self.connection.activeInstance == nil)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    DocumentItem *item = [self.openDocs objectAtIndex:indexPath.row];
    
    [self.model navigate:item.documentId];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
