//
//  UIScrollView+JPExtension.m
//  WoTV
//
//  Created by 周健平 on 2018/12/11.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import "UIScrollView+JPExtension.h"

@implementation UIScrollView (JPExtension)

- (void)jp_contentInsetAdjustmentNever {
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if ([self isKindOfClass:UITableView.class]) {
            UITableView *tableView = (UITableView *)self;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
        }
    }
}

@end
