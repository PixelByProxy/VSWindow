//
//  XIBUITableViewCell.m
//  VSWindow
//
//  Created by Ryan Heideman on 8/5/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "XIBUITableViewCell.h"

@implementation XIBUITableViewCell

+ (XIBUITableViewCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    XIBUITableViewCell *xibBasedCell = nil;
    NSObject* nibItem = nil;
    
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[XIBUITableViewCell class]]) {
            xibBasedCell = (XIBUITableViewCell *)nibItem;
            break;
        }
    }
    
    return xibBasedCell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
