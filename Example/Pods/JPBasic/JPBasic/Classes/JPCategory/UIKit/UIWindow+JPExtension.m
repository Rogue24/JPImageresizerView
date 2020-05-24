//
//  UIWindow+JPExtension.m
//  AFNetworking
//
//  Created by 周健平 on 2020/3/19.
//

#import "UIWindow+JPExtension.h"

@implementation UIWindow (JPExtension)

/** 获取顶层控制器 */
- (UIViewController *)jp_topViewController {
    if (!self.rootViewController) return nil;
    UIViewController *resultVC;
    resultVC = [self __jp_getTopViewController:self.rootViewController];
    while (resultVC.presentedViewController) { // 看看有没有moda出来的
        resultVC = [self __jp_getTopViewController:resultVC.presentedViewController];
    }
    if ([resultVC isKindOfClass:UIAlertController.class]) {
        resultVC = resultVC.presentingViewController; // 从哪里moda的那个才是
        return [self __jp_getTopViewController:resultVC];
    }
    return resultVC;
}

- (UIViewController *)__jp_getTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self __jp_getTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self __jp_getTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
}

+ (UIViewController *)jp_topViewControllerFromKeyWindow {
    return [[UIApplication sharedApplication].keyWindow jp_topViewController];
}

+ (UIViewController *)jp_topViewControllerFromDelegateWindow {
    return [[UIApplication sharedApplication].delegate.window jp_topViewController];
}

@end
