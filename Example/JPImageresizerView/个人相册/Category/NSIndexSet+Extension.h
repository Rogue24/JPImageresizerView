//
//  NSIndexSet+Extension.h
//  Infinitee2.0-Design
//
//  Created by Jill on 16/8/17.
//  Copyright © 2016年 陈珏洁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSIndexSet (Extension)
- (NSArray *)indexPathsFromIndexesWithSection:(NSUInteger)section;
- (NSArray *)editIndexPathsFromIndexesWithSection:(NSUInteger)section itemParameter:(NSInteger)itemParameter sectionParameter:(NSInteger)sectionParameter;
@end
