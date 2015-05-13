//
//  TaskListDetailViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 4/17/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "TaskListDetailViewController.h"
#import "AppDelegate.h"
#import "TaskListItem.h"
#import "TaskEditViewController.h"
#import "FormSheetUINavigationController.h"
#import "StatefulUIButton.h"
#import "ExtendedUIBarButtonItem.h"

@interface TaskListDetailViewController ()

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) TaskListModel* model;
@property (nonatomic, assign) NSInteger userTaskCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, retain) NSMutableArray* userTasks;
@property (nonatomic, retain) NSMutableArray* comments;

- (void)showAddDialog:(id) sender;
- (void)toggleEditMode:(id) sender;
- (void)displayEditMode:(StatefulUIButton*)btn editing:(BOOL)editing;
- (void)updateControlsEnabledState:(BOOL) enabled;

@end

@implementation TaskListDetailViewController

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;
@synthesize model = _model;
@synthesize userTaskCount = _userTaskCount;
@synthesize commentCount = _commentCount;
@synthesize userTasks = _userTasks;
@synthesize comments = _comments;

#pragma mark - Private Methods

- (void)showAddDialog:(id) sender
{
    TaskEditViewController *controller = [[TaskEditViewController alloc] initWithNibName:@"TaskEditViewController" bundle:nil];
    
    FormSheetUINavigationController *navController = [[FormSheetUINavigationController alloc] initWithRootViewController:controller];
    
	AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del presentModalViewController:navController];
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
    
    if ([commandName isEqual:@"GetTaskList"])
    {
        NSDictionary* result = [self.model parseGetTaskListResponse:dict];
        
        self.userTaskCount = [[dict valueForKey:@"UserTaskCount"] integerValue];
        self.commentCount = [[dict valueForKey:@"CommentCount"] integerValue];
        self.userTasks = [result mutableArrayValueForKey:@"userTasks"];
        self.comments = [result mutableArrayValueForKey:@"comments"];
        
        [self.tableView reloadData];
    }
    else if ([commandName isEqual:@"AddTaskItem"])
    {
        BOOL added = [self.model parseAddTaskResponse:dict];
        
        if (added)
        {
            [self.model subscribe];
        }        
    }
}

- (void)connectionStateChanged:(BOOL) connected
{
    [self updateControlsEnabledState:connected && self.connection.activeInstance != nil];
    [self setButtonState];
    
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
    
    [self setButtonState];
}

- (void)setButtonState {
    if (self.connection.connected && self.connection.activeInstance != nil && self.connection.activeInstance.version < 2015) {
        ExtendedUIBarButtonItem* editButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Edit" target:self action:@selector(toggleEditMode:)];
        ExtendedUIBarButtonItem* addButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Add" target:self action:@selector(showAddDialog:)];
     
        NSArray* rightButtons = [NSArray arrayWithObjects: addButton, editButton, nil];
        [self.navigationItem setRightBarButtonItems:rightButtons];
    } else {
        [self.navigationItem setRightBarButtonItems:nil];
    }
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Task List", @"Task List");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.model = [[TaskListModel alloc] init];

    self.connection = [self.appDelegate getConnection];

    [self setButtonState];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.appDelegate = nil;
    self.connection = nil;
    self.model = nil;
    self.userTasks = nil;
    self.comments = nil;
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
    
    if (self.userTasks.count > 0)
    {
        sectionCount++;
    }
    
    if (self.comments.count > 0)
    {
        sectionCount++;
    }
    
    return sectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSString *UserTasksTitle = @"User Tasks";
    static NSString *UserTasksTitleFormat = @"User Tasks (showing %d of %d)";
    static NSString *CommentsTitle = @"Comments";
    static NSString *CommentsTitleFormat = @"Comments (showing %d of %d)";

    NSString* headerTitle;
    
    if (section == 0 && self.userTasks.count > 0)
    {
        if (self.userTasks != nil && self.userTaskCount > self.userTasks.count)
        {
            headerTitle = [NSString stringWithFormat:UserTasksTitleFormat, self.userTasks.count, self.userTaskCount];
        }
        else
        {
            headerTitle = UserTasksTitle;
        }
    }
    else
    {
        if (self.comments != nil && self.commentCount > self.comments.count)
        {
            headerTitle = [NSString stringWithFormat:CommentsTitleFormat, self.comments.count, self.commentCount];
        }
        else
        {
            headerTitle = CommentsTitle;
        }
    }
    
    return headerTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if (section == 0 && self.userTasks.count > 0)
    {
        rows = self.userTasks.count;
    }
    else
    {
        rows = self.comments.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskListCell";
    static NSString *commentCategoryIdentifier = @"Comment";
    static NSString *commentCellDetailTextFormat = @"File: %@  Line: %d";
    UITableViewCell *cell;
    
    TaskListItem *item;
    
    if (indexPath.section == 0 && self.userTasks.count > 0)
    {
        item = [self.userTasks objectAtIndex:indexPath.row];
    }
    else
    {
        item = [self.comments objectAtIndex:indexPath.row];
    }

    if ([item.category isEqualToString:commentCategoryIdentifier])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:commentCategoryIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:commentCategoryIdentifier];
        }

        cell.detailTextLabel.text = [NSString stringWithFormat:commentCellDetailTextFormat, item.fileName, item.lineNumber];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (item.checked == YES)
        {
            cell.imageView.image = [UIImage imageNamed:self.appDelegate.isRetina ? @"checked@2x.png" : @"checked.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:self.appDelegate.isRetina ? @"unchecked@2x.png" : @"unchecked.png"];
        }
        
        switch (item.priority) {
            case 1:
                cell.textLabel.textColor = [UIColor blueColor];
                break;
            case 3:
                cell.textLabel.textColor = [UIColor redColor];
                break;
            default:
                cell.textLabel.textColor = [UIColor blackColor];
                break;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
        [cell.imageView addGestureRecognizer:tap];
        cell.imageView.userInteractionEnabled = YES;
    }
    
    cell.textLabel.text = item.description;

    return cell;
}

- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer
{
    if (!self.connection.connected || self.connection.activeInstance == nil)
    {
        return;
    }

    CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    TaskListItem *item = [self.userTasks objectAtIndex:tappedIndexPath.row];
    
    if (item.checked)
    {
        [self.model uncheckTask:item.taskId];
    }
    else
    {
        [self.model checkTask:item.taskId];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0 && self.userTasks.count > 0);
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
    TaskListItem *item = [self.userTasks objectAtIndex:indexPath.row];
    
    [self.model deleteTask:item.taskId];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.connection.connected || self.connection.activeInstance == nil)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if (indexPath.section == 1 || self.userTasks.count == 0)
    {
        TaskListItem *item = [self.comments objectAtIndex:indexPath.row];
        
        [self.model navigate:item.taskId];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
