//
//  CompressedUITableViewCell.m
//  VSWindow
//
//  Created by Ryan Heideman on 12/14/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "CompressedUITableViewCell.h"
#import "AppDelegate.h"

@implementation CompressedUITableViewCell

- (void)layoutSubviews
{
    //have the cell layout normally
    [super layoutSubviews];
    
    // we want to compress the layout when
    // there is an image present so that it
    // isn't so far between the image and text
    if (self.imageView.image != nil)
    {
        CGRect rect = self.textLabel.frame;
        rect.origin.x -= 40;
        self.textLabel.frame = rect;

        CGRect newImageFrame = self.imageView.frame;
        newImageFrame.origin.x -= 20;
        self.imageView.frame = newImageFrame;
    }
}

@end
