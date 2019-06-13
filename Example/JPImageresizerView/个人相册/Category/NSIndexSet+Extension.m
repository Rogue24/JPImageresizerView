//
//  NSIndexSet+Extension.m
//  Infinitee2.0-Design
//
//  Created by Jill on 16/8/17.
//  Copyright © 2016年 陈珏洁. All rights reserved.
//

#import "NSIndexSet+Extension.h"

@implementation NSIndexSet (Extension)
- (NSArray *)indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:section]];
    }];
    
    return indexPaths;
}

- (NSArray *)editIndexPathsFromIndexesWithSection:(NSUInteger)section itemParameter:(NSInteger)itemParameter sectionParameter:(NSInteger)sectionParameter {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:(index + itemParameter) inSection:(section + sectionParameter)]];
    }];
    
    return indexPaths;
}

@end
