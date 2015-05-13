//
//  CommandWindowDetailViewControllerViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 7/22/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandModel.h"
#import "CommandResponseDelegate.h"

@interface CommandWindowDetailViewController : UIViewController <UITextFieldDelegate, CommandResponseDelegate>

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)sendClicked:(id)sender;

@end