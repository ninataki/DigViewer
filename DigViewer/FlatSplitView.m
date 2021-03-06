//
//  FlatSplitView.m
//  DigViewer
//
//  Created by opiopan on 2014/03/23.
//  Copyright (c) 2014年 opiopan. All rights reserved.
//

#import "FlatSplitView.h"

@implementation FlatSplitView

- (CGFloat)dividerThickness
{
    return 1.5;
}

- (NSColor *)dividerColor
{
    return [NSColor lightGrayColor];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)cancelOperation:(id)sender
{
    if (self.delegate && _cancelOperationSelector){
        [self.delegate performSelector:_cancelOperationSelector withObject:sender];
    }
}
#pragma clang diagnostic pop

@end
