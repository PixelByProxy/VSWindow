//
//  AppDelegate.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/30/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSettings.h"
#import "StreamCommander.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (nonatomic, retain) UserSettings *userSettings;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, assign) BOOL detailHasLoaded;
@property (nonatomic, assign) BOOL versionAtLeast8;
@property (nonatomic, assign) BOOL isRetina;

-(void) pushDetailViewController:(UIViewController *) controller;
-(void) popDetailViewController;
-(void) setDetailController:(UIViewController *) view;
-(void) presentModalViewController:(UIViewController *) controller;
-(void) dismissModalViewController;
-(void) showActivity;
-(void) hideActivity;
-(void) showAlert:(NSString*)title message:(NSString*) message;
-(UIAlertView*) showBusy:(NSString*)message withDelegate:(id) delegate;
-(void) setMasterViewTitle:(NSString *) title;
-(StreamCommander *) getConnection;
-(void) openConnection;
-(void) closeConnection;

@end
