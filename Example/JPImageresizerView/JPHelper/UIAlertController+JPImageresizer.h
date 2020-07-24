//
//  UIAlertController+JPImageresizer.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/1/23.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (JPImageresizer)
+ (void)changeResizeWHScale:(void(^)(CGFloat resizeWHScale))handler isArbitrarily:(BOOL)isArbitrarily isRoundResize:(BOOL)isRoundResize fromVC:(UIViewController *)fromVC;
+ (void)changeBlurEffect:(void(^)(UIBlurEffect *blurEffect))handler fromVC:(UIViewController *)fromVC;
+ (void)replaceObj:(void(^)(UIImage *image, NSData *imageData, NSURL *videoURL))handler fromVC:(UIViewController *)fromVC;
+ (void)openAlbum:(void(^)(UIImage *image, NSData *imageData, NSURL *videoURL))handler fromVC:(UIViewController *)fromVC;
@end
