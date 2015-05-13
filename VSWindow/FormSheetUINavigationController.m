//
//  FormSheetUINavigationController.m
//  VSWindow
//
//  Created by Ryan Heideman on 7/31/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "FormSheetUINavigationController.h"

@interface FormSheetUINavigationController ()

@end

@implementation FormSheetUINavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
    }
    return self;
}

- (void)loadView
{
    // insert your custom loadView code here.
    [super loadView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

@end
