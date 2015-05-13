//
//  CommandWindowDetailViewControllerViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 7/22/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "CommandWindowDetailViewController.h"
#import "ExtendedUIBarButtonItem.h"

@interface CommandWindowDetailViewController ()

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) CommandModel* model;

- (void)clearClicked:(id) sender;
- (void)updateControlsEnabledState:(BOOL) enabled;

@end

@implementation CommandWindowDetailViewController

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;
@synthesize model = _model;
@synthesize textField = _textField;
@synthesize sendButton = _sendButton;
@synthesize webView = _webView;

#pragma mark - Private Methods

- (void)clearClicked:(id) sender
{
    [self.model clearWindow];
}

- (void)updateControlsEnabledState:(BOOL) enabled
{
    // toggle the enabled state of the ui
    self.textField.enabled = enabled;
    self.sendButton.enabled = enabled;
    
    for (UIBarButtonItem* btn in self.navigationItem.rightBarButtonItems)
    {
        btn.enabled = enabled;
    }
}

#pragma mark - Public Methods

- (IBAction)sendClicked:(id)sender
{
    if ([self.textField.text length] > 0)
    {
        [self.model runCommand:self.textField.text];
        [self.textField setText:@""];
    }
}

#pragma mark - CommandResponseDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
    NSString *commandName = [dict valueForKey:@"CommandName"];
    if ([commandName isEqual:@"GetCommandWindowText"])
    {
        NSString* html = [self.model parseGetCommandWindowTextResponse:dict];
        
        [self.webView loadHTMLString:html baseURL:nil];
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

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)sender
{
    [sender resignFirstResponder];
    return YES;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Command", @"Command");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.model = [[CommandModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];
    
    self.textField.enabled = self.connection.connected && self.connection.activeInstance != nil;
    self.sendButton.enabled = self.connection.connected && self.connection.activeInstance != nil;
    
    ExtendedUIBarButtonItem *clearButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Clear" target:self action:@selector(clearClicked:)];
    
    // set the initial enabled state
    clearButton.enabled = self.connection.connected && self.connection.activeInstance != nil;

    [self.navigationItem setRightBarButtonItem:clearButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.appDelegate = nil;
    self.connection = nil;
    self.model = nil;
    self.textField = nil;
    self.sendButton = nil;
    self.webView = nil;
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

@end
