//
//  AppDelegate.m
//  VSWindow
//
//  Created by Ryan Heideman on 9/30/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize userSettings = _userSettings;
@synthesize connection = _connection;
@synthesize detailHasLoaded = _detailHasLoaded;
@synthesize versionAtLeast8 = _versionAtLeast8;
@synthesize isRetina = _isRetina;

#pragma Public Methods

- (void)pushDetailViewController:(UIViewController *) controller
{
    [[self.splitViewController.viewControllers objectAtIndex:1] pushViewController:controller animated:YES];
}

- (void)popDetailViewController
{
    [[self.splitViewController.viewControllers objectAtIndex:1] popDetailViewController];
}

- (void)setDetailController:(UIViewController *) controller
{
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];

    NSArray *viewControllers=[[NSArray alloc] initWithObjects:[self.splitViewController.viewControllers objectAtIndex:0],detailNavigationController,nil];
    
    
    [self.splitViewController setViewControllers:viewControllers];

    [((DetailViewController*)self.splitViewController.delegate) showPopoverButton:self.splitViewController];
    
    // hide the popover
    [((DetailViewController*)self.splitViewController.delegate) dismissPopover];
}

- (void)presentModalViewController:(UIViewController *) controller
{
    [controller setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [((DetailViewController*)self.splitViewController.delegate) dismissPopover];
    
    [self.splitViewController presentViewController:controller animated:YES completion:nil];
}

- (void)dismissModalViewController
{
    [self.splitViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showActivity
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)hideActivity
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)showAlert:(NSString*)title message:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

-(UIAlertView*)showBusy:(NSString*)message withDelegate:(id) delegate
{
    UIAlertView *alert = [[UIAlertView alloc]
                           initWithTitle:message
                           message:nil delegate:delegate cancelButtonTitle:@"Cancel"
                           otherButtonTitles: nil];
    
    [alert show];
    
    return alert;
}

-(void)setMasterViewTitle:(NSString *) title;
{
    MasterViewController *master = (MasterViewController*)[[[self.splitViewController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    if (title.length > 15)
    {
        title = [title substringToIndex:15];
    }

    master.title = title;
    
    [((DetailViewController*)self.splitViewController.delegate) setPopoverButtonTitle:self.splitViewController title:title];
}

-(StreamCommander *) getConnection
{
    if (self.connection == nil)
    {
        self.connection = [[StreamCommander alloc] init];
    }
    
    [self openConnection];
    
    return self.connection;
}

-(void) openConnection
{
    if (self.connection == nil || !self.connection.connected)
    {
        [self.connection connect];
    }
}

-(void) closeConnection
{
    if (self.connection != nil)
    {
        [self.connection disconnect];
    }
}

#pragma Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    self.versionAtLeast8 = iOSVersion >= 8.0f;
    self.isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) ? 1:0;

    // init the user settings
    self.userSettings = [[UserSettings alloc] init];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    masterViewController.detailViewController = detailViewController;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [self closeConnection];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [self openConnection];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [self closeConnection];
}

@end
