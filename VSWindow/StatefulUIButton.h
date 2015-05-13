//
//  StatefulUIButton.h
//  VSWindow
//
//  Created by Ryan Heideman on 12/14/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface StatefulUIButton : UIButton
{
@private
    NSMutableDictionary *backgroundStates;
@public
}

- (void) setBackgroundColor:(UIColor*)backgroundColor forState:(UIControlState) state;
- (UIColor*) backgroundColorForState:(UIControlState) _state;
- (void)setTitle:(NSString*)title;

@end