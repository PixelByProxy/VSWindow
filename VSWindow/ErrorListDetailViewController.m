//
//  BreakpointsDetailViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 10/2/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import "ErrorListDetailViewController.h"
#import "ErrorModel.h"
#import "ErrorListItem.h"

@interface ErrorListDetailViewController ()

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) ErrorModel* model;
@property (nonatomic, assign) NSInteger errorCount;
@property (nonatomic, assign) NSInteger warningCount;
@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic, retain) NSMutableArray* warnings;

@end

@implementation ErrorListDetailViewController

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;
@synthesize model = _model;
@synthesize errorCount = _errorCount;
@synthesize warningCount = _warningCount;
@synthesize errors = _errors;
@synthesize warnings = _warnings;

#pragma mark - CommandResponseDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    
    if ([commandName isEqual:@"GetErrorList"])
    {
        self.errorCount = [[dict valueForKey:@"ErrorCount"] integerValue];
        self.warningCount = [[dict valueForKey:@"WarningCount"] integerValue];
        
        NSDictionary* result = [self.model parseGetErrorListResponse:dict];
        
        self.errors = [result mutableArrayValueForKey:@"errors"];
        self.warnings = [result mutableArrayValueForKey:@"warnings"];

        [self.tableView reloadData];
    }
}

- (void)connectionStateChanged:(BOOL) connected
{
    // toggle the enabled state of the ui
    
    if (connected)
    {
        [self.model subscribe];
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
        self.title = NSLocalizedString(@"Error List", @"Error List");
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
    self.model = [[ErrorModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.appDelegate = nil;
    self.connection = nil;
    self.model = nil;
    self.errors = nil;
    self.warnings = nil;
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
    NSInteger sectionCount = 0;
    
    if (self.errors.count > 0)
    {
        sectionCount++;
    }
    
    if (self.warnings.count > 0)
    {
        sectionCount++;
    }
    
    return sectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSString *ErrorTitle = @"Errors";
    static NSString *ErrorTitleFormat = @"Errors (showing %d of %d)";
    static NSString *WarningTitle = @"Warnings";
    static NSString *WarningTitleFormat = @"Warnings (showing %d of %d)";

    NSString* headerTitle;
    
    if (section == 0 && self.errors.count > 0)
    {
        if (self.errors != nil && self.errorCount > self.errors.count)
        {
            headerTitle = [NSString stringWithFormat:ErrorTitleFormat, self.errors.count, self.errorCount];
        }
        else
        {
            headerTitle = ErrorTitle;            
        }
    }
    else
    {
        if (self.warnings != nil && self.warningCount > self.warnings.count)
        {
            headerTitle = [NSString stringWithFormat:WarningTitleFormat, self.warnings.count, self.warningCount];
        }
        else
        {
            headerTitle = WarningTitle;
        }
    }
    
    return headerTitle;
}
            
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if (section == 0 && self.errors.count > 0)
    {
        rows = self.errors.count;
    }
    else
    {
        rows = self.warnings.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ErrorListItemCell";
    static NSString *errorItemCellDetailTextFormat = @"File: %@  Line: %d  Character: %d  Project:  %@";
    UITableViewCell *cell;
    
    ErrorListItem *item;
    
    if (indexPath.section == 0 && self.errors.count > 0)
    {
        item = [self.errors objectAtIndex:indexPath.row];
    }
    else
    {
        item = [self.warnings objectAtIndex:indexPath.row];
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:errorItemCellDetailTextFormat, item.fileName, item.lineNumber, item.column, item.project];
    cell.textLabel.text = item.description;
        
    switch (item.errorLevel) {
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"Warning.png"];
            break;
        case 4:
            cell.imageView.image = [UIImage imageNamed:@"Error.png"];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.connection.connected || self.connection.activeInstance == nil)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }

    ErrorListItem *item;
    
    if (indexPath.section == 0 && self.errors.count > 0)
    {
        item = [self.errors objectAtIndex:indexPath.row];
    }
    else
    {
        item = [self.warnings objectAtIndex:indexPath.row];
    }
    
    [self.model navigate:item.errorId];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
