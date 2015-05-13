//
//  OutputDetailViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 10/3/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import "OutputDetailViewController.h"
#import "ExtendedUIBarButtonItem.h"
#import "OutputModel.h"

@interface OutputDetailViewController ()

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) OutputModel* model;

- (void)clearClicked:(id) sender;
- (void)updateControlsEnabledState:(BOOL) enabled;

@end

@implementation OutputDetailViewController

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;
@synthesize model = _model;
@synthesize webView = _webView;

#pragma mark - Private Methods

- (void)clearClicked:(id) sender
{
    [self.model clearWindow];
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
    if ([commandName isEqual:@"GetOutputWindowText"])
    {
        NSString* html = [self.model parseGetOutputWindowTextResponse:dict];
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

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Output", @"Output");
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
    self.model = [[OutputModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];

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
