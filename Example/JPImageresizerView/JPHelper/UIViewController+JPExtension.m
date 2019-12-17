//
//  UIViewController+JPExtension.m
//  Infinitee2.0
//
//  Created by 周健平 on 2017/9/20.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "UIViewController+JPExtension.h"
#import <objc/runtime.h>

@implementation UIViewController (JPExtension)

- (void)jp_contentInsetAdjustmentNever:(UIScrollView *)scrollView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [scrollView jp_contentInsetAdjustmentNever];
}

- (BOOL)jp_isRootViewController {
    if (self.navigationController) {
        return self.navigationController.viewControllers.firstObject == self;
    }
    return NO;
}

- (void)jp_popVC {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"退出不了~");
    }
}

static const char JPIsHideNavigationBarKey = '\0';
- (void)setJp_isHideNavigationBar:(BOOL)jp_isHideNavigationBar {
    objc_setAssociatedObject(self, &JPIsHideNavigationBarKey, @(jp_isHideNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)jp_isHideNavigationBar {
    return [objc_getAssociatedObject(self, &JPIsHideNavigationBarKey) boolValue];
}

static const char JPIsNotAutoSetBackBarButtonItemKey = '\0';
- (void)setJp_isNotAutoSetBackBarButtonItem:(BOOL)jp_isNotAutoSetBackBarButtonItem {
    objc_setAssociatedObject(self, &JPIsNotAutoSetBackBarButtonItemKey, @(jp_isNotAutoSetBackBarButtonItem), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)jp_isNotAutoSetBackBarButtonItem {
    return [objc_getAssociatedObject(self, &JPIsNotAutoSetBackBarButtonItemKey) boolValue];
}

@end
