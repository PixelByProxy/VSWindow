//
//  SearchToolbarViewController.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormSheetBaseUITableViewController.h"
#import "ToolbarModel.h"
#import "ToolbarSearchDelegate.h"
#import "CommandResponseDelegate.h"

@interface SearchToolbarViewController : FormSheetBaseUITableViewController <UISearchBarDelegate, CommandResponseDelegate>

@property (nonatomic, retain) id<ToolbarSearchDelegate> delegate;
@property (nonatomic, retain) IBOutlet UISearchBar* masterSearchBar;

@end
