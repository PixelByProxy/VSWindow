//
//  SettingUITableViewCell.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/5/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "SettingUITableViewCell.h"

@implementation SettingUITableViewCell

@synthesize masterLabel = _masterLabel;
@synthesize masterText = _masterText;
@synthesize delegate = _delegate;

#pragma mark - Public Methods

- (void)setCellValue:(NSString *)name withValue:(NSString *)value andPlaceholder:(NSString *)placeholder;
{
    [self.masterLabel setText:name];
    [self.masterText setText:value];
    [self.masterText setPlaceholder:placeholder];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)sender
{
    [sender resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate settingChanged:textField.tag newValue:textField.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate activeTextFieldChanged:textField];
}

#pragma mark - View lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
