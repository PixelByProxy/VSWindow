//
//  TaskEditViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 7/29/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormSheetBaseUIViewController.h"
#import "SettingChangedDelegate.h"
#import "DialogClosedDelegate.h"
#import "OptionListDelegate.h"
#import "TaskListModel.h"

@interface TaskEditViewController : FormSheetBaseUIViewController <UITableViewDelegate, UITableViewDataSource, SettingChangedDelegate, OptionListDelegate, CommandResponseDelegate>

@property (nonatomic, retain) IBOutlet UITableView* masterTableView;

@end
