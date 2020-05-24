//
//  UIWindow+JPExtension.h
//  AFNetworking
//
//  Created by 周健平 on 2020/3/19.
//

#import <UIKit/UIKit.h>

@interface UIWindow (JPExtension)
/** 获取顶层控制器 */
- (UIViewController *)jp_topViewController;
+ (UIViewController *)jp_topViewControllerFromKeyWindow;
+ (UIViewController *)jp_topViewControllerFromDelegateWindow;
@end

