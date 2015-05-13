//
//  StatefulUIButton.m
//  VSWindow
//
//  Created by Ryan Heideman on 12/14/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "StatefulUIButton.h"

@implementation StatefulUIButton

- (void) setBackgroundColor:(UIColor*)backgroundColor forState:(UIControlState) state
{
    if (backgroundStates == nil)
        backgroundStates = [[NSMutableDictionary alloc] init];
    
    [backgroundStates setObject:backgroundColor forKey:[NSNumber numberWithInt:state]];
    
    if (state == UIControlStateNormal)
    {
        [self setBackgroundColor:backgroundColor];
    
        [self addTarget:self action:@selector(enterDrag) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(exitDrag) forControlEvents:UIControlEventTouchDragExit];
    }
}

- (UIColor*) backgroundColorForState:(UIControlState) _state
{
    return [backgroundStates objectForKey:[NSNumber numberWithInt:_state]];
}

#pragma mark -

- (void)setTitle:(NSString*)title
{
    [self setTitle:title forState:UIControlStateNormal];
}


#pragma mark Touches

- (void) enterDrag
{
    [self setHighlightedColor];
}

- (void) exitDrag
{
    [self setNormalColor];
}

- (void) setNormalColor
{
    if (self.enabled)
    {
        if (self.selected)
        {
            UIColor *selectedColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateHighlighted]];
            if (selectedColor) {
                self.backgroundColor = selectedColor;
                [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // TODO: Don't hardcode this
            }
        }
        else
        {
            UIColor *normalColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateNormal]];
            if (normalColor) {
                [UIView animateWithDuration:0.05 animations:^{
                    self.backgroundColor = normalColor;
                    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // TODO: This either
                }];
            }
        }
    }
}

- (void) setHighlightedColor
{
    if (self.enabled)
    {
        UIColor *selectedColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateHighlighted]];
        if (selectedColor) {
            [UIView animateWithDuration:0.05 animations:^{
                self.backgroundColor = selectedColor;
            }];
        }
    }
}

- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled)
    {
        UIColor *normalColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateNormal]];
        if (normalColor) {
            self.backgroundColor = normalColor;
        }
    }
    else
    {
        UIColor *normalColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateDisabled]];
        if (normalColor) {
            self.backgroundColor = normalColor;
        }
    }
}

- (void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self setNormalColor];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
    
    [self setHighlightedColor];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
    
    [self setNormalColor];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self setNormalColor];
}

@end