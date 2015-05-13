//
//  TaskListDetailViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 4/17/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskListModel.h"
#import "DialogClosedDelegate.h"
#import "CommandResponseDelegate.h"

@interface TaskListDetailViewController : UITableViewController <CommandResponseDelegate>

@end
