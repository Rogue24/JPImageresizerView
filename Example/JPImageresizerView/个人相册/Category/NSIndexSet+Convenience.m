//
//  NSIndexSet+Convenience.m
//  Infinitee2.0
//
//  Created by guanning on 2017/6/27.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "NSIndexSet+Convenience.h"

@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end
