//
//  JPProgressHUD.m
//  XXXX
//
//  Created by 周健平 on 2018/11/28.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPProgressHUD.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation JPProgressHUD

static SVProgressHUDMaskType defaultMaskType_;

+ (void)initialize {
    defaultMaskType_ = SVProgressHUDMaskTypeClear;
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
}

#pragma mark - 初始化配置

+ (void)setLightStyle {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
}

+ (void)setDarkStyle {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
}

+ (void)setCustomStyle {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
}

+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval {
    [SVProgressHUD setMinimumDismissTimeInterval:interval];
}

+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel {
    [SVProgressHUD setMaxSupportedWindowLevel:windowLevel];
}

+ (void)setBackgroundColor:(UIColor *)bgColor {
    [SVProgressHUD setBackgroundColor:bgColor];
}

+ (void)setForegroundColor:(UIColor *)fgColor {
    [SVProgressHUD setForegroundColor:fgColor];
}

+ (void)setSuccessImage:(UIImage *)successImage {
    [SVProgressHUD setSuccessImage:successImage];
}

+ (void)setErrorImage:(UIImage *)errorImage {
    [SVProgressHUD setErrorImage:errorImage];
}

+ (void)setInfoImage:(UIImage *)infoImage {
    [SVProgressHUD setInfoImage:infoImage];
}

#pragma mark - 使用方法

+ (BOOL)isVisible {
    return [SVProgressHUD isVisible];
}

+ (void)show {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD show];
}

+ (void)show:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD show];
}

+ (void)showWithStatus:(NSString *)status {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD showWithStatus:status];
}

+ (void)showWithStatus:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD showWithStatus:status];
}

+ (void)showProgress:(float)progress {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD showProgress:progress];
}

+ (void)showProgress:(float)progress userInteractionEnabled:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD showProgress:progress];
}

+ (void)showProgress:(float)progress status:(NSString *)status {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD showProgress:progress status:status];
}

+ (void)showProgress:(float)progress status:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD showProgress:progress status:status];
}

+ (void)showInfoWithStatus:(NSString *)status {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD showInfoWithStatus:status];
}

+ (void)showInfoWithStatus:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD showInfoWithStatus:status];
}

+ (void)showSuccessWithStatus:(NSString*)status {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD showSuccessWithStatus:status];
}

+ (void)showSuccessWithStatus:(NSString*)status userInteractionEnabled:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD showSuccessWithStatus:status];
}

+ (void)showErrorWithStatus:(NSString*)status {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD showErrorWithStatus:status];
}

+ (void)showErrorWithStatus:(NSString*)status userInteractionEnabled:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD showErrorWithStatus:status];
}

+ (void)showImage:(UIImage *)image status:(NSString *)status {
    [SVProgressHUD setDefaultMaskType:defaultMaskType_];
    [SVProgressHUD showImage:image status:status];
}

+ (void)showImage:(UIImage *)image status:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled {
    [SVProgressHUD setDefaultMaskType:(userInteractionEnabled ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear)];
    [SVProgressHUD showImage:image status:status];
}

+ (void)dismiss {
    [SVProgressHUD dismiss];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay {
    [SVProgressHUD dismissWithDelay:delay];
}

static BOOL jp_isInterval_ = NO;
+ (void)showIntervalInfoWithStatus:(NSString *)status userInteractionEnabled:(BOOL)userInteractionEnabled {
    if (jp_isInterval_) {
        return;
    }
    jp_isInterval_ = YES;
    [self showInfoWithStatus:status userInteractionEnabled:userInteractionEnabled];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        jp_isInterval_ = NO;
    });
}

@end
