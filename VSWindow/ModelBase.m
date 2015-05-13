//
//  ModelBase.m
//  VSWindow
//
//  Created by Ryan Heideman on 9/4/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "ModelBase.h"

@implementation ModelBase

@synthesize appDelegate = _appDelegate;
@synthesize connection = _connection;

#pragma mark - Init

- (id)init {
	self = [super init];
	if (self) {
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.connection = [self.appDelegate getConnection];
	}
	return self;
}

@end
