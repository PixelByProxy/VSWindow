//
//  DocumentItem.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentItem : NSObject

@property (nonatomic, retain) NSString* documentId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) BOOL readOnly;
@property (nonatomic, assign) BOOL saved;

- (id)initFromDictionary:(NSDictionary *)dict;

@end
