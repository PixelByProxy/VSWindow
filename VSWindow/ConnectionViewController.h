//
//  ConnectionViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 10/5/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormSheetBaseUIViewController.h"
#import "ConnectionStateChangedDelegate.h"

@interface ConnectionViewController : FormSheetBaseUIViewController <UITableViewDelegate, UITableViewDataSource, ConnectionStateChangedDelegate>

@property (nonatomic, retain) IBOutlet UITableView* masterTableView;

- (IBAction)cancelClicked:(id)sender;

@end
