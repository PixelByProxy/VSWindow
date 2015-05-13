//
//  MasterViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/30/11.
//  Copyright (c) 2011 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <CommandResponseDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
