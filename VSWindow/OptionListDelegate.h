//
//  OptionListDelegate.h
//  VSWindow
//
//  Created by Ryan Heideman on 7/29/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OptionListDelegate <NSObject>

- (NSMutableDictionary*)getItems;
- (id)getDefaultKey;
- (void)optionSelected:(id)selectedOption;

@end
