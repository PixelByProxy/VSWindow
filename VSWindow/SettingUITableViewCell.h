//
//  SettingUITableViewCell.h
//  VSWindow
//
//  Created by Ryan Heideman on 8/5/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "XIBUITableViewCell.h"
#import "SettingChangedDelegate.h"

@interface SettingUITableViewCell : XIBUITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *masterLabel;
@property (nonatomic, weak) IBOutlet UITextField *masterText;
@property (nonatomic, strong) id<SettingChangedDelegate> delegate;

- (void)setCellValue:(NSString *)name withValue:(NSString *)value andPlaceholder:(NSString *)placeholder;

@end
