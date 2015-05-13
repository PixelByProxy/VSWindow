//
//  ExtendedUIBarButtonItem.m
//  VSWindow
//
//  Created by Ryan Heideman on 12/14/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "ExtendedUIBarButtonItem.h"
#import "AppDelegate.h"

@implementation ExtendedUIBarButtonItem

@synthesize metroButton = _metroButton;

#pragma mark - Init

- (UIBarButtonItem*)initWithMetro:(NSString*)text target:(id)target action:(SEL)action
{
    self.metroButton = [StatefulUIButton buttonWithType:UIButtonTypeCustom];
    [self.metroButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.metroButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.metroButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.metroButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.metroButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.metroButton setTitle:text forState:UIControlStateNormal];
    [self.metroButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.metroButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.metroButton sizeToFit];
    
    CGRect frame = self.metroButton.frame;
    frame.size.height = 26.0f;
    
    if (frame.size.width < 60.0f)
    {
        frame.size.width = 60.0f;
    }
    else
    {
        frame.size.width += 4;
    }
    
    [self.metroButton setFrame:frame];
    
    self = [super initWithCustomView:self.metroButton];
    if(!self) return nil;
    
    return self;
}

- (UIBarButtonItem*)initWithMetroImage:(UIImage*)image target:(id)target action:(SEL)action
{
    self.metroButton = [[StatefulUIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [self.metroButton setBackgroundColor:[UIColor clearColor]];
    [self.metroButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.metroButton setBackgroundImage:image forState:UIControlStateNormal];

    self = [super initWithCustomView:self.metroButton];
    if(!self) return nil;
    
    return self;
}


@end
