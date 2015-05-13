//
//  ExtendedUIBarButtonItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 12/14/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatefulUIButton.h"

@interface ExtendedUIBarButtonItem : UIBarButtonItem

@property (nonatomic, retain) StatefulUIButton* metroButton;

- (id)initWithMetro:(NSString*)text target:(id)target action:(SEL)action;
- (UIBarButtonItem*)initWithMetroImage:(UIImage*)image target:(id)target action:(SEL)action;

@end
