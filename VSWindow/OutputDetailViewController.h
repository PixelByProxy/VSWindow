//
//  OutputDetailViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 10/3/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandResponseDelegate.h"

@interface OutputDetailViewController : UIViewController <CommandResponseDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end