//
//  DetailViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/30/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolbarModel.h"
#import "ToolbarSearchDelegate.h"
#import "DialogClosedDelegate.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIGestureRecognizerDelegate, ToolbarSearchDelegate, DialogClosedDelegate, CommandResponseDelegate>

-(void) dismissPopover;
-(void) showPopoverButton:(UISplitViewController*) splitController;
-(void) setPopoverButtonTitle:(UISplitViewController*) splitController title:(NSString*)title;

@end
