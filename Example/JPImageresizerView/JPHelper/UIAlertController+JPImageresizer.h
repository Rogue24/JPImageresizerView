//
//  UIAlertController+JPImageresizer.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/1/23.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (JPImageresizer)

+ (void)showWithPreferredStyle:(UIAlertControllerStyle)preferredStyle
                         title:(NSString *_Nullable)title
                       message:(NSString *_Nullable)message
                       actions:(NSArray<UIAlertAction *> *)actions
            isNeedCancelAction:(BOOL)isNeedCancelAction;

#pragma mark - Alert

+ (void)alertWithTitle:(NSString *_Nullable)title
               message:(NSString *_Nullable)message
               actions:(NSArray<UIAlertAction *> *)actions;
+ (void)alertWithTitle:(NSString *_Nullable)title
               message:(NSString *_Nullable)message
               actions:(NSArray<UIAlertAction *> *)actions
    isNeedCancelAction:(BOOL)isNeedCancelAction;

#pragma mark - Sheet

+ (void)sheetWithActions:(NSArray<UIAlertAction *> *)actions;
+ (void)sheetWithTitle:(NSString *_Nullable)title
               message:(NSString *_Nullable)message
               actions:(NSArray<UIAlertAction *> *)actions;
+ (void)sheetWithTitle:(NSString *_Nullable)title
               message:(NSString *_Nullable)message
               actions:(NSArray<UIAlertAction *> *)actions
    isNeedCancelAction:(BOOL)isNeedCancelAction;

+ (void)changeResizeWHScale:(void(^)(CGFloat resizeWHScale))handler
              isArbitrarily:(BOOL)isArbitrarily
              isRoundResize:(BOOL)isRoundResize;

+ (void)changeBlurEffect:(void(^)(UIBlurEffect *_Nullable blurEffect))handler;

+ (void)replaceObj:(void(^)(UIImage *_Nullable image, NSData *_Nullable imageData, NSURL *_Nullable videoURL))handler;

+ (void)rotation:(void(^)(BOOL isClockwise))handler1
     toDirection:(void(^)(JPImageresizerRotationDirection direction))handler2;

+ (void)changeMaskImage:(void(^)(UIImage *_Nullable maskImage))handler1
      gotoMaskImageList:(void(^)(void))handler2
          isReplaceFace:(BOOL)isReplaceFace
   isCanRemoveMaskImage:(BOOL)isCanRemoveMaskImage;
@end

NS_ASSUME_NONNULL_END
