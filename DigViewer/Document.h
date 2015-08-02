//
//  Document.h
//  DigViewer
//
//  Created by opiopan on 2013/01/04.
//  Copyright (c) 2013 opiopan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PathNode.h"

@interface Document : NSDocument

@property (strong) PathNode* root;
@property (nonatomic, readonly) NSDictionary* documentWindowPreferences;

- (void)loadDocument:(id)sender;
- (void)saveDocumentWindowPreferences:(NSDictionary*)preferences;

@end
