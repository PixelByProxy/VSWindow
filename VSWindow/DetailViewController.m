//
//  DetailViewController.m
//  test
//
//  Created by Ryan Heideman on 8/5/12.
//  Copyright (c) 2012 Ryan Heideman. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchToolbarViewController.h"
#import "FormSheetUINavigationController.h"
#import "AppDelegate.h"
#import "ToolbarItem.h"
#import "ExtendedUIBarButtonItem.h"
#import "StatefulUIButton.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, retain) UIBarButtonItem *masterPopoverBarButtonItem;
@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) StreamCommander *connection;
@property (nonatomic, retain) ToolbarModel* model;
@property (nonatomic, retain) NSMutableDictionary* buttons;
@property (nonatomic, retain) NSMutableDictionary *selectedItems;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL buttonsRemoved;
@property (nonatomic, retain) UIView* draggedView;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, retain) UIView* overView;

- (void)showAddDialog:(id) sender;
- (void)toggleEditMode:(id) sender;
- (void)resetClicked:(id) sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)removeCommand:(id)sender;
- (void)saveLayout;
- (void)runCommand:(id)sender;
- (BOOL)isButtonView:(UIView*)view;
- (BOOL)isPlaceHolderView:(UIView*)view;
- (BOOL)isRemoveButtonView:(UIView*)view;
- (void)updateControlsEnabledState:(BOOL)enabled;
- (void)renderGrid:(BOOL)inPortraitMode;
- (void)resetButtons;
- (void)toggleGridEditMode:(BOOL)editing;
- (void)toggleGridRemoveButton:(UIView*)view editing:(BOOL)editing;
- (void)addButton:(ToolbarItem*)item;
- (void)longPressHandlerDragger:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)reorderButtons:(UIView*)button draggedAt:(NSInteger)draggedAt;
- (void)configureView;

@end

@implementation DetailViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize masterPopoverBarButtonItem = _masterPopoverBarButtonItem;
@synthesize model = _model;
@synthesize buttons = _buttons;
@synthesize selectedItems = _selectedItems;
@synthesize isEditing = _isEditing;
@synthesize buttonsRemoved = _buttonsRemoved;
@synthesize draggedView = _draggedView;
@synthesize originalCenter = _originalCenter;
@synthesize overView = _overView;

NSInteger const ButtonsPerView = 16;
NSInteger const ButtonsPerRowLandscape = 4;
NSInteger const ButtonSize = 160;
NSInteger const ButtonOffset = 30;
NSInteger const TagOffset = 100;
NSInteger const OrgTagOffset = 200;
NSInteger const RemoveTagOffset = 300;
NSInteger const OrientationXOffset = 36;
NSInteger const OrientationYOffset = 120;

#pragma mark - Private Methods (Events)

- (void)showAddDialog:(id) sender
{
    if (self.isEditing)
    {
        [self toggleEditMode:nil];
    }
    
    SearchToolbarViewController *controller = [[SearchToolbarViewController alloc] initWithNibName:@"SearchToolbarViewController" bundle:nil];
    [controller setDelegate:self];
    
    FormSheetUINavigationController *navController = [[FormSheetUINavigationController alloc] initWithRootViewController:controller];
    
	AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del presentModalViewController:navController];
}

- (void)toggleEditMode:(id) sender
{
    StatefulUIButton* btn;
    
    if (sender != nil)
    {
        btn = (StatefulUIButton*)sender;
    }
    else
    {
        ExtendedUIBarButtonItem* bbi = [self.navigationItem.rightBarButtonItems objectAtIndex:2];
        btn = bbi.metroButton;
    }
    
    if (btn.tag == 1)
    {
        self.isEditing = NO;
        [btn setTag:0];
        [btn setTitle:@"Edit"];
        [btn setSelected:NO];
        
        [self toggleGridEditMode:self.isEditing];

        // remove the drag & drop events
        for(UIButton* btn in self.view.subviews)
        {
            if ([btn isKindOfClass:[UIButton class]] && [self isButtonView:btn])
            {
                for(UILongPressGestureRecognizer* gesture in btn.gestureRecognizers)
                {
                    [btn removeGestureRecognizer:gesture];
                }
            }
        }
        
        // save the layout
        [self saveLayout];
    }
    else
    {
        self.isEditing = YES;
        self.buttonsRemoved = NO;
        [btn setTag:1];
        [btn setTitle:@"Done"];
        [btn setSelected:YES];

        // add the drag & drop events
        for(UIButton* btn in self.view.subviews)
        {
            if ([btn isKindOfClass:[UIButton class]] && [self isButtonView:btn])
            {
                UILongPressGestureRecognizer *longpressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandlerDragger:)];
                longpressGesture.minimumPressDuration = 0.01f;
                [btn addGestureRecognizer:longpressGesture];
            }
        }

        // render the grid
        [self toggleGridEditMode:self.isEditing];
        
    }
}

- (void)resetClicked:(id) sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Toolbar"
                                                    message:@"Are you sure you want to reset the toolbar layout?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
        [self.model resetToolbarLayout];
        [self resetButtons];
        
        if (self.isEditing)
        {
            [self toggleEditMode:nil];
        }
	}
}

- (void)removeCommand:(id)sender
{
    UIButton* removeBtn = (UIButton*)sender;
    NSInteger btnTag = (removeBtn.tag - RemoveTagOffset);
    UIButton* btn = (UIButton*)[self.view viewWithTag:btnTag];
    
    if (btn != nil)
    {
        NSNumber* key = [NSNumber numberWithInt:(int)(btn.titleLabel.tag - OrgTagOffset)];
        NSString* itemId = [self.buttons objectForKey:key];
        [self.selectedItems removeObjectForKey:itemId];
        [self.buttons removeObjectForKey:key];
        [btn removeFromSuperview];
        [removeBtn removeFromSuperview];
        self.buttonsRemoved = YES;
    }
}

- (void)saveLayout
{
    NSLog(@"---Layout Saving---");
    
    /*
     for(NSNumber* key in self.buttons.allKeys)
     {
     NSLog(@"%@ %@", [self.buttons objectForKey:key], key);
     }
     */
    
    BOOL hasChanges = NO;
    
    // update the button tags
    //NSMutableDictionary* newButtons = [NSMutableDictionary dictionaryWithCapacity:self.selectedItems.count];
    
    // update the button tags
    for(UIButton* btn in self.view.subviews)
    {
        if ([btn isKindOfClass:[UIButton class]] && [self isButtonView:btn])
        {
            NSInteger orgTag = (btn.titleLabel.tag - OrgTagOffset);
            NSInteger newOrder = btn.tag;
            
            if (orgTag != newOrder)
            {
                NSString* itemId = [self.buttons objectForKey:[NSNumber numberWithInt:(int)orgTag]];
                ToolbarItem* item = [self.selectedItems objectForKey:itemId];
                item.order = newOrder;
                //btn.titleLabel.tag = (newOrder + OrgTagOffset);
                //[newButtons setObject:itemId forKey:[NSNumber numberWithInt:newOrder]];
                
                hasChanges = YES;
            }
        }
    }
    
    if (hasChanges || self.buttonsRemoved)
    {
        [self.model saveToolbarLayout:self.selectedItems];
        [self resetButtons];
        //self.buttons = newButtons;
        
        NSLog(@"---Layout Saved---");
        
        /*
         for(NSNumber* key in self.buttons.allKeys)
         {
         NSLog(@"%@ %@", [self.buttons objectForKey:key], key);
         }
         */
    }
}

- (void)runCommand:(id)sender
{
    if (!self.connection.connected || self.connection.activeInstance == nil)
        return;

    UIButton* btn = (UIButton*)sender;
    NSString* tag = [self.buttons objectForKey:[NSNumber numberWithInt:(int)btn.tag]];
    
    [self.model runCommand:tag];
}

#pragma mark - Private Methods (Helper Methods)

- (BOOL)isButtonView:(UIView*)view
{
    return (view.tag > 0 && view.tag < TagOffset);
}

- (BOOL)isPlaceHolderView:(UIView*)view
{
    return (view.tag >= TagOffset && view.tag < OrgTagOffset);
}

- (BOOL)isRemoveButtonView:(UIView*)view
{
    return (view.tag >= RemoveTagOffset);
}

- (void)updateControlsEnabledState:(BOOL) enabled
{
    // toggle the enabled state of the ui
    for (UIButton *btn in [self.view subviews])
    {
        if ([btn isKindOfClass:[UIButton class]] && [self isButtonView:btn])
        {
            if (enabled)
            {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else
            {
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }
        }
    }
    
    UIBarButtonItem* addButton = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
    addButton.enabled = enabled;
}

#pragma mark - Private Methods (Grid Display)

- (void)renderGrid:(BOOL)inPortraitMode
{
    NSInteger rowIndex = 0;
    NSInteger cellIndex = 0;
    
    for(int i = 0; i < ButtonsPerView; i++)
    {
        NSInteger leftOffset = 0;
        NSInteger topOffset = 0;

        if (cellIndex >= ButtonsPerRowLandscape)
        {
            cellIndex = 0;
            rowIndex++;
        }
        
        if (rowIndex > 0)
        {
            topOffset = (ButtonSize * rowIndex);
        }        

        if (cellIndex > 0)
        {
            leftOffset = (ButtonSize * cellIndex);
        }

        topOffset += ButtonOffset;
        leftOffset += ButtonOffset;
        
        // center for portrait orientation
        if (inPortraitMode)
        {
            topOffset += OrientationYOffset;
            leftOffset += OrientationXOffset;
        }
        
        cellIndex++;
        
        CGRect coords = CGRectMake(leftOffset, topOffset, ButtonSize, ButtonSize);
        
        UIView *placeHolder = [[UIView alloc] initWithFrame:coords];
        placeHolder.tag = (i + TagOffset + 1);
        placeHolder.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"placeholder_bg.png"]];
        placeHolder.alpha = 0;
        [self.view addSubview:placeHolder];
        [self.view sendSubviewToBack:placeHolder];
    }
}

- (void)resetButtons
{
    for (UIView *btn in [self.view subviews])
    {
        if ([btn isKindOfClass:[UIButton class]])
        {
            [btn removeFromSuperview];
        }
    }
    
    self.buttons = nil;
    self.selectedItems = nil;
    [self configureView];
}

- (void)toggleGridEditMode:(BOOL)editing
{
    for (UIView *subView in self.view.subviews)
    {
        if (![subView isKindOfClass:[UIButton class]])
        {
            if (editing)
            {
                subView.alpha = 0.5;
            }
            else
            {
                subView.alpha = 0;
            }
        }
        else if ([self isButtonView:subView])
        {
            [self toggleGridRemoveButton:subView editing:editing];            
        }
    }
}

- (void)toggleGridRemoveButton:(UIView*)view editing:(BOOL)editing
{
    NSInteger removeButtonTag = (view.tag + RemoveTagOffset);
    
    if (editing)
    {
        // add the button
        CGRect coords = CGRectMake(view.frame.origin.x - 4, view.frame.origin.y - 4, 30, 30);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(removeCommand:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        btn.frame = coords;
        btn.tag = removeButtonTag;
        [btn setTitleColor:[UIColor colorWithRed:0/255 green:122/255 blue:204/255 alpha:255] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn.titleLabel setFont:[UIFont systemFontOfSize: 16]];
        [btn.titleLabel setLineBreakMode: NSLineBreakByWordWrapping];
        [btn.titleLabel setShadowOffset:CGSizeMake(1.0, 0.0)];
        
        [self.view addSubview:btn];
    }
    else
    {
        // remove the button
        UIView* removeButtonView = [self.view viewWithTag:removeButtonTag];
        if (removeButtonView != nil)
        {
            [removeButtonView removeFromSuperview];
        }
    }
}

- (void)addButton:(ToolbarItem*)item
{
    UIView* ph = [self.view viewWithTag:(item.order + TagOffset)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn addTarget:self action:@selector(runCommand:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
    btn.frame = ph.frame;
    btn.tag = item.order;
    [btn setTitle:item.name forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btn.titleLabel setFont:[UIFont systemFontOfSize: 16]];
    [btn.titleLabel setLineBreakMode: NSLineBreakByWordWrapping];
    //[btn.titleLabel setShadowOffset:CGSizeMake(1.0, 0.0)];
    [btn setBackgroundImage:[UIImage imageNamed:@"bigbutton_black.png"] forState:UIControlStateNormal];
    btn.titleLabel.tag = (item.order + OrgTagOffset);
    
    if (self.connection.connected && self.connection.activeInstance != nil)
    {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
        
    [self.view addSubview:btn];
    
    if (self.buttons == nil)
    {
        self.buttons = [NSMutableDictionary dictionaryWithObject:item.itemId forKey:[NSNumber numberWithInt:(int)item.order]];
    }
    else
    {
        [self.buttons setObject:item.itemId forKey:[NSNumber numberWithInt:(int)item.order]];
    }
}

#pragma mark - Private Methods (Grid Ordering)

- (void)longPressHandlerDragger:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (!self.isEditing || (self.draggedView != nil && self.draggedView != gestureRecognizer.view))
    {
        return;
    }
    
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state)
    {
        // Called on start of gesture, do work here
        self.draggedView = gestureRecognizer.view;
        self.originalCenter = self.draggedView.center;

        // hide the remove buttons
        for(UIView* view in self.view.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] && [self isButtonView:view])
            {
                [self toggleGridRemoveButton:view editing:NO];
            }
        }
    }
    else if (UIGestureRecognizerStateChanged == gestureRecognizer.state)
    {
        // Do repeated work here (repeats continuously) while finger is down
        CGPoint coords = [gestureRecognizer locationInView:self.view];
        
        for (UIView *subView in self.view.subviews)
        {
            if (![subView isKindOfClass:[UIButton class]])
            {
                CGRect intersectRect = CGRectMake((subView.frame.origin.x + 60), (subView.frame.origin.y + 60), 100, 100);
                
                if (gestureRecognizer.view != subView && CGRectIntersectsRect(gestureRecognizer.view.frame, intersectRect))
                {
                    [UIView animateWithDuration:0.2 animations:^{
                        subView.alpha = 1.0;
                    }];
                    
                    [self reorderButtons:self.draggedView draggedAt:subView.tag];
                    
                    if (self.overView != nil && self.overView != subView)
                    {
                        [UIView animateWithDuration:0.2 animations:^{
                            self.overView.alpha = 0.5;
                        }];
                    }
                    
                    self.overView = subView;

                    //NSLog(@"%i over", self.overView.tag);
                    break;
                }
            }
        }
        
        [self.view bringSubviewToFront:gestureRecognizer.view];

        gestureRecognizer.view.frame = CGRectMake(coords.x-80, coords.y-80, ButtonSize, ButtonSize);
    }
    else if (UIGestureRecognizerStateEnded == gestureRecognizer.state)
    {
        // re-add the remove buttons
        for(UIView* view in self.view.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] && self.draggedView != view && [self isButtonView:view])
            {
                [self toggleGridRemoveButton:view editing:YES];
            }
        }
        
        // drop on the appropriate place holder
        CGPoint moveTo = self.originalCenter;
        
        if (self.overView != nil)
        {
            moveTo = self.overView.center;
            self.draggedView.tag = (self.overView.tag - TagOffset);
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.draggedView.center = moveTo;
            self.originalCenter = CGPointZero;
            self.overView.alpha = 0.5;
        }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self toggleGridRemoveButton:self.draggedView editing:YES];
                                 self.draggedView = nil;
                             }
                         }];

        self.overView = nil;
    }
}

- (void)reorderButtons:(UIView*)button draggedAt:(NSInteger)draggedAt
{
    draggedAt = (draggedAt - TagOffset);
    
    UIView* existingView = [self.view viewWithTag:draggedAt];
    if (existingView != nil)
    {
        //NSLog(@"Needs to move from %i to %d", button.tag, draggedAt);
        
        if (button.tag > draggedAt)
        {
            NSMutableDictionary* movedButtons = [NSMutableDictionary dictionary];
            
            for(int i = (int)draggedAt; i < button.tag; i++)
            {
                UIView* btn = [self.view viewWithTag:i];
                if (btn != nil)
                {
                    //NSLog(@"Move %i Forward %@", i, ((UIButton*)btn).titleLabel.text);
                    UIView* ph = [self.view viewWithTag:(i + TagOffset + 1)];
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        btn.center = ph.center;
                    }];
                    
                    [movedButtons setValue:btn forKey:[NSString stringWithFormat:@"%d", (i + 1)]];
                }
                else
                {
                    break;
                }
            }
            
            for(NSString* key in [movedButtons allKeys])
            {
                UIView* btn = [movedButtons valueForKey:key];
                btn.tag = [key integerValue];
            }
            
            button.tag = draggedAt;
        }
        else if (button.tag < draggedAt)
        {
            NSMutableDictionary* movedButtons = [NSMutableDictionary dictionary];
            
            for(int i = (int)draggedAt; i > button.tag; i--)
            {
                UIView* btn = [self.view viewWithTag:i];
                if (btn != nil)
                {
                    //NSLog(@"Move %i Back %@", i, ((UIButton*)btn).titleLabel.text);
                    UIView* ph = [self.view viewWithTag:(i + TagOffset - 1)];
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        btn.center = ph.center;
                    }];
                    
                    [movedButtons setValue:btn forKey:[NSString stringWithFormat:@"%d", (i - 1)]];
                }
                else
                {
                    break;
                }
            }
            
            for(NSString* key in [movedButtons allKeys])
            {
                UIView* btn = [movedButtons valueForKey:key];
                btn.tag = [key integerValue];
            }
            
            button.tag = draggedAt;
        }
        else
        {
            button.tag = draggedAt;
        }
    }
}

#pragma mark - ToolbarSearchDelegate

- (NSInteger)initialItemCount
{
    return self.selectedItems.count;
}

- (NSInteger)maxItemCount
{
    return ButtonsPerView;
}

- (void)commandsAdded:(NSMutableDictionary*) commands
{
    NSInteger buttonIndex = 0;
    
    for (NSString* key in commands)
    {
        ToolbarItem* tbi = [commands objectForKey:key];
        
        if ([self.selectedItems objectForKey:tbi.itemId] == nil)
        {
            // find where the button should be placed
            for(buttonIndex = buttonIndex; buttonIndex <= ButtonsPerView; buttonIndex++)
            {
                UIView* view = [self.view viewWithTag:buttonIndex];
                if (view == nil)
                {
                    tbi.order = buttonIndex;
                    break;
                }
            }
            
            [self.selectedItems setValue:tbi forKey:tbi.itemId];
            [self addButton:tbi];
        }
    }
    
    [self.model saveToolbarLayout:self.selectedItems];
}

#pragma mark - ToolbarModelDelegate

- (void)operationShouldProceed:(NSDictionary*) dict
{
}

- (void)connectionStateChanged:(BOOL) connected
{
    // toggle the enabled state of the ui
    [self updateControlsEnabledState:connected && self.connection.activeInstance != nil];

    // update the button title
    if (connected)
    {
        AppDelegate* del = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        NSString* title = del.userSettings.activeConnection.name;
        
        if (title.length > 15)
        {
            title = [title substringToIndex:15];
        }
        
        self.navigationItem.leftBarButtonItem.title = title;
    }
    else
    {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Explorer", @"Explorer");
    }
    
    if (connected)
    {
        [self.model subscribe];
    }
}

- (void)instanceChanged:(InstanceItem *)instance
{
    if (instance != nil)
    {
        [self updateControlsEnabledState:self.connection.connected];
    }
    else
    {
        [self updateControlsEnabledState:NO];
    }
}

#pragma mark - DialogClosedDelegate

- (void)dialogClosed
{
    // resubscribe
    [self.model subscribe];
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Toolbar", @"Toolbar");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.model = [[ToolbarModel alloc] init];
    
    self.connection = [self.appDelegate getConnection];
    
    ExtendedUIBarButtonItem *editButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Edit" target:self action:@selector(toggleEditMode:)];
    ExtendedUIBarButtonItem *addButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Add" target:self action:@selector(showAddDialog:)];
    ExtendedUIBarButtonItem *resetButton = [[ExtendedUIBarButtonItem alloc] initWithMetro:@"Reset" target:self action:@selector(resetClicked:)];
    
    // set the initial enabled state
    addButton.enabled = self.connection.connected && self.connection.activeInstance != nil;
    
    NSArray* rightButtons = [NSArray arrayWithObjects: resetButton, addButton, editButton, nil];
    [self.navigationItem setRightBarButtonItems:rightButtons];

    // check the starup orientation
    BOOL atLeastIOS6 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f;
    BOOL inPortraitMode = NO;
    
    // for some reason this check doesn't work on initial startup on iOS 5.x
    // but must be used after the initial startup or the value is wrong
    if (atLeastIOS6 || self.appDelegate.detailHasLoaded)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        inPortraitMode = UIDeviceOrientationIsPortrait(orientation);
    }
    else
    {
        int orientation = [[UIDevice currentDevice] orientation];
        if (orientation == 1 || orientation == 2)
        {
            inPortraitMode = YES;
        }
    }
    
    self.appDelegate.detailHasLoaded = YES;

    // render the grid
    [self renderGrid:inPortraitMode];
    
    // draw the buttons
    [self configureView];    
}

- (void)configureView
{
    self.selectedItems = [self.model getToolbarLayout];
    
    if (self.selectedItems == nil)
    {
        self.selectedItems = [[NSMutableDictionary alloc] init];
        
        ToolbarItem* item = [[ToolbarItem alloc] initWithValues:@"Debug.Start" name:@"Start" order:1];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Debug.StopDebugging" name:@"Stop Debugging" order:2];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Build.BuildSolution" name:@"Build Solution" order:3];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Build.RebuildSolution" name:@"Rebuild Solution" order:4];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.Copy" name:@"Copy" order:5];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.Paste" name:@"Paste" order:6];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.Undo" name:@"Undo" order:7];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.Redo" name:@"Redo" order:8];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.CommentSelection" name:@"Comment Selection" order:9];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.UncommentSelection" name:@"Uncomment Selection" order:10];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.CollapseAllOutlining" name:@"Collapse All Outlining" order:11];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"Edit.ExpandAllOutlining" name:@"Expand All Outlining" order:12];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"View.PropertiesWindow" name:@"Properties Window" order:13];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"View.TfsSourceControlExplorer" name:@"Tfs Source Control Explorer" order:14];
        [self.selectedItems setValue:item forKey:item.itemId];
        
        item = [[ToolbarItem alloc] initWithValues:@"View.TfsPendingChanges" name:@"Tfs Pending Changes" order:15];
        [self.selectedItems setValue:item forKey:item.itemId];
    }
    
    // render the buttons
    for(NSString* itemId in self.selectedItems.allKeys)
    {
        ToolbarItem* item = [self.selectedItems objectForKey:itemId];
        [self addButton:item];
        //NSLog(@"Item Order: %@ %i", item.itemId, item.order);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.appDelegate = nil;
    self.connection = nil;
    self.model = nil;
    self.buttons = nil;
    self.selectedItems = nil;
    self.draggedView = nil;
    self.overView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.connection subscribe:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.connection unsubscribe:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // if the model is null then the view hasn't loaded
    // if iOS 8 then it is handled by the new method
    if (self.model == nil || self.appDelegate.versionAtLeast8)
    {
        return;
    }
    
    UIInterfaceOrientation fromInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL from = UIInterfaceOrientationIsLandscape(fromInterfaceOrientation);
    BOOL to = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
    if (from != to)
    {
        for(UIView* view in self.view.subviews)
        {
            CGRect orgCoords = view.frame;
            CGRect newCoords;
            
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
            {
                newCoords = CGRectMake(orgCoords.origin.x - OrientationXOffset, orgCoords.origin.y - OrientationYOffset, orgCoords.size.width, orgCoords.size.height);
            }
            else
            {
                newCoords = CGRectMake(orgCoords.origin.x + OrientationXOffset, orgCoords.origin.y + OrientationYOffset, orgCoords.size.width, orgCoords.size.height);
            }

            [UIView animateWithDuration:duration animations:^{
                view.frame = newCoords;
            }];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    // if the model is null then the view hasn't loaded
    // if iOS 7 then it is handled by the old method
    if (self.model == nil || !self.appDelegate.versionAtLeast8)
    {
        return;
    }
    
    UIInterfaceOrientation fromInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL from = UIInterfaceOrientationIsLandscape(fromInterfaceOrientation);
    BOOL to = size.width > size.height;
    
    if (from != to)
    {
        for(UIView* view in self.view.subviews)
        {
            CGRect orgCoords = view.frame;
            CGRect newCoords;
            
            if (to)
            {
                newCoords = CGRectMake(orgCoords.origin.x - OrientationXOffset, orgCoords.origin.y - OrientationYOffset, orgCoords.size.width, orgCoords.size.height);
            }
            else
            {
                newCoords = CGRectMake(orgCoords.origin.x + OrientationXOffset, orgCoords.origin.y + OrientationYOffset, orgCoords.size.width, orgCoords.size.height);
            }
            
            [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                view.frame = newCoords;
            } completion:nil];
        }
    }
}

#pragma mark - Split view

-(void) dismissPopover
{
    if (self.masterPopoverController != nil && self.masterPopoverController.isPopoverVisible)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

-(void) showPopoverButton:(UISplitViewController*) splitController
{
    if (self.masterPopoverBarButtonItem != nil)
    {
        [[[[[splitController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem] setLeftBarButtonItem:self.masterPopoverBarButtonItem animated:NO];
    }
}

-(void) setPopoverButtonTitle:(UISplitViewController*) splitController title:(NSString*)title
{
    if (self.masterPopoverBarButtonItem != nil)
    {
        UIBarButtonItem* barButtonItem = [[[[[splitController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem] leftBarButtonItem];
        if (barButtonItem != nil)
        {
            if (title.length > 15)
            {
                title = [title substringToIndex:15];
            }
            
            barButtonItem.title = title;
        }
    }
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    if (self.connection.connected)
    {
        NSString* title = self.appDelegate.userSettings.activeConnection.name;
        
        if (title.length > 15)
        {
            title = [title substringToIndex:15];
        }

        barButtonItem.title = title;
    }
    else
    {
        barButtonItem.title = NSLocalizedString(@"Explorer", @"Explorer");        
    }
    
    self.masterPopoverController = popoverController;

    
    ExtendedUIBarButtonItem *customButton = [[ExtendedUIBarButtonItem alloc] initWithMetroImage:[UIImage imageNamed:@"home.png"] target:barButtonItem.target action:barButtonItem.action];
        
    [[[[[splitController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem] setLeftBarButtonItem:customButton animated:YES];
    self.masterPopoverBarButtonItem = customButton;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [[[[[splitController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem] setLeftBarButtonItem:nil];
    self.masterPopoverController = nil;
    self.masterPopoverBarButtonItem = nil;
}

@end
