//
//  UIViewController+JPExtension.h
//  Infinitee2.0
//
//  Created by 周健平 on 2017/9/20.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+JPExtension.h"

@interface UIViewController (JPExtension)
- (UIViewController *)jp_topViewController;
- (UINavigationController *)jp_topNavigationController;
- (void)jp_contentInsetAdjustmentNever:(UIScrollView *)scrollView;
- (BOOL)jp_isRootViewController;
- (void)jp_popVC;
@property (nonatomic, assign) BOOL jp_isHideNavigationBar;
@property (nonatomic, assign) BOOL jp_isNotAutoSetBackBarButtonItem;
@end
