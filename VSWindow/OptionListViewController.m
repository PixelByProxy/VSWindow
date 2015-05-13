//
//  OptionListViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 7/30/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "OptionListViewController.h"

@interface OptionListViewController ()

@end

@implementation OptionListViewController

@synthesize delegate = _delegate;
@synthesize items = _items;
@synthesize selectedKey = _selectedKey;
@synthesize keys = _keys;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [self.delegate getItems];
    self.keys = [self.items allKeys];
    self.selectedKey = [self.delegate getDefaultKey];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.items = nil;
    self.selectedKey = nil;
    self.keys = nil;
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
    NSInteger count = 0;
    
    if (self.items != nil)
    {
        count = self.items.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OptionListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    id key = [self.keys objectAtIndex:indexPath.row];
    id val = [self.items objectForKey:key];
    
    if (self.selectedKey != nil && [key isEqual:self.selectedKey])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = val;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedKey = [self.keys objectAtIndex:indexPath.row];
    
    [self.delegate optionSelected:self.selectedKey];
    
    [tableView reloadData];
}

@end
