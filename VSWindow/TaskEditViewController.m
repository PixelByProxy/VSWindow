//
//  TaskEditViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 7/29/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "TaskEditViewController.h"
#import "SettingUITableViewCell.h"
#import "OptionListViewController.h"
#import "ExtendedUIBarButtonItem.h"

@interface TaskEditViewController ()

@property (nonatomic, retain) TaskListModel* model;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) UITextField* activeTextField;
@property (nonatomic, retain) NSString* taskName;
@property (nonatomic, retain) NSNumber* taskPriority;
@property (nonatomic, retain) NSMutableDictionary* optionListItems;

- (void)cancelClicked:(id)sender;
- (void)saveClicked:(id)sender;
- (void)textFieldDidChange:(UITextField *)textField;
- (void)updateControlsEnabledState;

@end

@implementation TaskEditViewController

@synthesize model = _model;
@synthesize connection = _connection;
@synthesize activeTextField = _activeTextField;
@synthesize taskName = _taskName;
@synthesize taskPriority = _taskPriority;
@synthesize optionListItems = _optionListItems;
@synthesize masterTableView = _masterTableView;

#pragma mark - Private Methods

- (void)cancelClicked:(id)sender
{
    [self.appDelegate dismissModalViewController];
}

- (void)saveClicked:(id)sender
{
    if (self.activeTextField != nil)
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
    
    [self.model addTask:self.taskName taskPriority:[self.taskPriority integerValue]];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = (textField.text.length > 0 && self.connection.connected && self.connection.activeInstance != nil);
}

- (void)updateControlsEnabledState
{
    self.navigationItem.rightBarButtonItem.enabled = (((self.taskName != nil && self.taskName.length > 0) || (self.activeTextField != nil && self.activeTextField.text.length > 0)) && self.connection.connected && self.connection.activeInstance != nil);
}

#pragma mark - CommandResponseDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    
    if ([commandName isEqual:@"AddTaskItem"])
    {
        BOOL added = [self.model parseAddTaskResponse:dict];
        
        if (added)
        {
            [self.appDelegate dismissModalViewController];
        }
        else
        {
            [self.appDelegate showAlert:@"Add Task Failed" message:@"Unable to add the new task."];
        }
    }
}

- (void)connectionStateChanged:(BOOL) connected
{
    [self updateControlsEnabledState];
}

- (void)instanceChanged:(InstanceItem *)instance
{
    [self updateControlsEnabledState];
}

#pragma mark - SettingChangedDelegate

- (void)settingChanged:(NSInteger) row newValue:(NSString*)newValue
{
    switch (row)
    {
        case 0:
            self.taskName = newValue;
            break;
        default:
            break;
    }
}

- (void)activeTextFieldChanged:(UITextField*) newField
{
    self.activeTextField = newField;
}

#pragma mark - OptionListDelegate

- (NSMutableDictionary*)getItems
{
    return self.optionListItems;
}

- (id)getDefaultKey
{
    return self.taskPriority;
}

- (void)optionSelected:(id)selectedOption
{
    self.taskPriority = selectedOption;
    
    [self.masterTableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connection = [self.appDelegate getConnection];
    
    self.model = [[TaskListModel alloc] init];
    
    [self.navigationItem setTitle:@"Add Task"];
    
    ExtendedUIBarButtonItem *addButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Add" target:self action:@selector(saveClicked:)];
    [addButton setEnabled:NO];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    ExtendedUIBarButtonItem *cancelButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Cancel" target:self action:@selector(cancelClicked:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    self.taskPriority = [NSNumber numberWithInt:2]; // default is 2 (Normal)
    self.optionListItems = [[NSMutableDictionary alloc] init];
    [self.optionListItems setObject:@"High" forKey:[NSNumber numberWithInt:3]];
    [self.optionListItems setObject:@"Normal" forKey:self.taskPriority];
    [self.optionListItems setObject:@"Low" forKey:[NSNumber numberWithInt:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.connection = nil;
    self.model = nil;
    self.activeTextField = nil;
    self.taskName = nil;
    self.taskPriority = nil;
    self.optionListItems = nil;
    self.masterTableView = nil;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    static NSString *OptionCellIdentifier = @"OptionCell";
    static NSString *CellNib = @"SettingUITableViewCell";
    UITableViewCell *cell;
    
    if (indexPath.row == 0)
    {
        SettingUITableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (customCell == nil)
        {
            customCell = (SettingUITableViewCell *)[SettingUITableViewCell cellFromNibNamed:CellNib];
        }
        
        customCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [customCell setDelegate:self];
        [[customCell masterText] setTag:indexPath.row];
        
        [customCell setCellValue:@"Name" withValue:self.taskName andPlaceholder:@"Required"];
        
        [[customCell masterText] addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        cell = customCell;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:OptionCellIdentifier];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        id val = [self.optionListItems objectForKey:self.taskPriority];

        cell.textLabel.text = @"Priority";
        cell.detailTextLabel.text = val;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activeTextField != nil)
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }

    if (indexPath.row == 1)
    {
        OptionListViewController *controller = [[OptionListViewController alloc] initWithNibName:@"OptionListViewController" bundle:nil];
        [controller setDelegate:self];
        [controller.navigationItem setTitle:@"Priority"];
        
        [self.navigationController pushViewController:controller animated:YES];

        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
