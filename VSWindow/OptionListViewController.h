//
//  OptionListViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 7/30/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormSheetBaseUITableViewController.h"
#import "OptionListDelegate.h"

@interface OptionListViewController : FormSheetBaseUITableViewController

@property (nonatomic, retain) id<OptionListDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary* items;
@property (nonatomic, retain) NSArray* keys;
@property (nonatomic, retain) id selectedKey;

@end
