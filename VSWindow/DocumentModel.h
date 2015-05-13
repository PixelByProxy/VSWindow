//
//  DocumentModel.h
//  VSWindow
//
//  Created by Ryan Heideman on 9/16/12.
//  Copyright (c) 2012-2013 Pixel by Proxy. All rights reserved.
//

#import "ModelBase.h"

@interface DocumentModel : ModelBase

- (void)subscribe;
- (void)navigate:(NSString *)documentId;
- (void)close:(NSString *)documentId;
- (void)closeAll;
- (NSMutableArray*)parseGetOpenDocumentsResponse:(NSDictionary *)response;;

@end
