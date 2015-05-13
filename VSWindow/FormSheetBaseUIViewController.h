//
//  FormSheetBaseUIViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/23/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FormSheetBaseUIViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, retain) AppDelegate *appDelegate;

@end
