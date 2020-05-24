//
//  JPProgressHUD.h
//  XXXX
//
//  Created by 周健平 on 2018/11/28.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPProgressHUD : NSObject

#pragma mark - 初始化配置

+ (void)setLightStyle;
+ (void)setDarkStyle;
+ (void)setCustomStyle;
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;
+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel;
+ (void)setBackgroundColor:(UIColor *)bgColor;
+ (void)setForegroundColor:(UIColor *)fgColor;
+ (void)setSuccessImage:(UIImage *)successImage;
+ (void)setErrorImage:(UIImage *)errorImage;
+ (void)setInfoImage:(UIImage *)infoImage;

#pragma mark - 使用方法

+ (BOOL)isVisible;

+ (void)show;
+ (void)show:(BOOL)userInteractionEnabled;
+ (void)showWithStatus:(NSString *)status;
+ (void)showWithStatus:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled;

+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress userInteractionEnabled:(BOOL)userInteractionEnabled;
+ (void)showProgress:(float)progress status:(NSString *)status;
+ (void)showProgress:(float)progress status:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled;

+ (void)showInfoWithStatus:(NSString *)status;
+ (void)showInfoWithStatus:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled;

+ (void)showSuccessWithStatus:(NSString*)status;
+ (void)showSuccessWithStatus:(NSString*)status userInteractionEnabled:(BOOL)userInteractionEnabled;

+ (void)showErrorWithStatus:(NSString*)status;
+ (void)showErrorWithStatus:(NSString*)status userInteractionEnabled:(BOOL)userInteractionEnabled;

+ (void)showImage:(UIImage *)image status:(NSString *)status;
+ (void)showImage:(UIImage *)image status:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled;

+ (void)dismiss;
+ (void)dismissWithDelay:(NSTimeInterval)delay;

+ (void)showIntervalInfoWithStatus:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled;
@end
