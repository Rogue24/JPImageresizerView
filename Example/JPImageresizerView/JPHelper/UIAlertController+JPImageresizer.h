//
//  UIAlertController+JPImageresizer.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/1/23.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (JPImageresizer)
+ (void)changeResizeWHScale:(void(^)(CGFloat resizeWHScale))handler fromVC:(UIViewController *)fromVC;
+ (void)changeBlurEffect:(void(^)(UIBlurEffect *blurEffect))handler fromVC:(UIViewController *)fromVC;
+ (void)replaceImage:(void(^)(UIImage *image))handler fromVC:(UIViewController *)fromVC;
@end
