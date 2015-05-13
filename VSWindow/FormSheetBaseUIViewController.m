//
//  FormSheetBaseUIViewController.m
//  VSWindow
//
//  Created by Ryan Heideman on 9/23/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import "FormSheetBaseUIViewController.h"

@interface FormSheetBaseUIViewController ()

@property (nonatomic, retain) UITapGestureRecognizer* bgRecognizer;

@end

@implementation FormSheetBaseUIViewController

@synthesize bgRecognizer = _bgRecognizer;
@synthesize appDelegate = _appDelegate;

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil];
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && _appDelegate.versionAtLeast8)
        {
            location = CGPointMake(location.y, location.x);
        }
        
        // if tap outside pincode inputscreen
        if (!([self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil] || [self.navigationController.view pointInside:[self.navigationController.view convertPoint:location fromView:self.navigationController.view.window] withEvent:nil]))
            
        {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.view.window removeGestureRecognizer:sender];
            }];
        }
    }
    
    /*
    if (sender.state == UIGestureRecognizerStateEnded && !_appDelegate.versionAtLeast8)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        if (!([self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil] || [self.navigationController.view pointInside:[self.navigationController.view convertPoint:location fromView:self.navigationController.view.window] withEvent:nil]))
            
        {
            [self.appDelegate dismissModalViewController];
        }
    }*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.appDelegate = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.bgRecognizer == nil)
    {
        self.bgRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
        [self.bgRecognizer setNumberOfTapsRequired:1];
        self.bgRecognizer.cancelsTouchesInView = NO;
        self.bgRecognizer.delegate = self;
        [self.view.window addGestureRecognizer:self.bgRecognizer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view.window removeGestureRecognizer:self.bgRecognizer];
    self.bgRecognizer = nil;
}

@end
