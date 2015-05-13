//
//  AddConnectionViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/28/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormSheetBaseUITableViewController.h"
#import "SettingChangedDelegate.h"

@interface AddConnectionViewController : FormSheetBaseUITableViewController <UITableViewDelegate, UITableViewDataSource, SettingChangedDelegate>

- (id)initWithConnection:(NSString *)uniqueId;

@end
