//
//  SolutionExplorerItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 12/22/13.
//  Copyright (c) 2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SolutionExplorerItem : NSObject

@property (nonatomic, retain) NSString* itemId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) BOOL saved;
@property (nonatomic, assign) BOOL isFile;

- (id)initFromDictionary:(NSDictionary *)dict;

@end
