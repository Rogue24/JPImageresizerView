//
//  JPConstant.m
//  Infinitee2.0
//
//  Created by 周健平 on 2017/9/24.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPConstant.h"
#import <sys/utsname.h>

CGFloat const JPBasePadding = 1.5;
CGFloat const JPBaseVerPadding = 3.0;

@implementation JPConstant

static BOOL is_iphoneX_ = NO;
static BOOL is_iOS13_ = NO;
static BOOL is_iPad_ = NO;

static CGFloat screenScale_ = 1.0;
static CGRect portraitScreenBounds_;
static CGSize portraitScreenSize_;
static CGFloat portraitScreenWidth_ = 0.0;
static CGFloat portraitScreenHeight_ = 0.0;
static CGRect landscapeScreenBounds_;
static CGSize landscapeScreenSize_;
static CGFloat landscapeScreenWidth_ = 0.0;
static CGFloat landscapeScreenHeight_ = 0.0;

static CGFloat baseTabBarH_ = 49.0;
static CGFloat tabBarH_ = 0.0;
static CGFloat diffTabBarH_ = 0.0;

static CGFloat baseStatusBarH_ = 20.0;
static CGFloat statusBarH_ = 0.0;
static CGFloat diffStatusBarH_ = 0.0;

static CGFloat navBarH_ = 44.0;
static CGFloat navTopMargin_ = 0.0;

static CGFloat pageSheetPortraitNavBarH_ = 56.0;
static CGFloat pageSheetPortraitScreenHeight_ = 0.0;

static CGFloat uiBasisWScale_ = 1.0;
static CGFloat uiBasisHScale_ = 1.0;

static CGFloat uiBasis5Margin_ = 5.0;
static CGFloat uiBasis8Margin_ = 8.0;
static CGFloat uiBasis10Margin_ = 10.0;
static CGFloat uiBasis12Margin_ = 12.0;
static CGFloat uiBasis15Margin_ = 15.0;
static CGFloat uiBasis20Margin_ = 20.0;

static CGFloat separateLineThick_ = 0.0;

/** 16 : 9 */
static CGFloat wideVideoWHScale_ = 0.0;
/** 9 : 16 */
static CGFloat wideVideoHWScale_ = 0.0;
/** 宽视频在竖屏非全屏时的尺寸 */
static CGSize wideVideoPortraitSize_;
/** 宽视频在横屏且全屏时的尺寸 */
static CGSize wideVideoLandscapeSize_;
/** 宽视频播放器在竖屏非全屏时的尺寸（视频尺寸+状态栏高度） */
static CGSize wideVideoPlayerPortraitSize_;

+ (void)load {
    screenScale_ = [UIScreen mainScreen].scale;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    portraitScreenBounds_ = CGRectMake(0, 0, MIN(screenW, screenH), MAX(screenW, screenH));
    portraitScreenSize_ = portraitScreenBounds_.size;
    portraitScreenWidth_ = portraitScreenSize_.width;
    portraitScreenHeight_ = portraitScreenSize_.height;
    
    landscapeScreenBounds_ = CGRectMake(0, 0, MAX(screenW, screenH), MIN(screenW, screenH));
    landscapeScreenSize_ = landscapeScreenBounds_.size;
    landscapeScreenWidth_ = landscapeScreenSize_.width;
    landscapeScreenHeight_ = landscapeScreenSize_.height;
    
    is_iPad_ = [[UIDevice currentDevice].model isEqualToString:@"iPad"];
    is_iphoneX_ = is_iPad_ ? NO : (portraitScreenHeight_ > 736.0);
    
    pageSheetPortraitScreenHeight_ = portraitScreenHeight_;
    
    if (@available(iOS 13.0, *)) {
        is_iOS13_ = YES;
        pageSheetPortraitScreenHeight_ -= (is_iphoneX_ ? 54.0 : 40.0);
    }
    
    tabBarH_ = is_iphoneX_ ? 83.0 : baseTabBarH_;
    diffTabBarH_ = tabBarH_ - baseTabBarH_;
    
    statusBarH_ = is_iphoneX_ ? 44.0 : baseStatusBarH_;
    diffStatusBarH_ = statusBarH_ - baseStatusBarH_;
    
    navTopMargin_ = statusBarH_ + navBarH_;
    
    uiBasisWScale_ = portraitScreenWidth_ / (is_iPad_ ? 768.0 : 375.0);
    uiBasisHScale_ = portraitScreenHeight_ / (is_iPad_ ? 1024.0 : 667.0);
    
    uiBasis5Margin_ *= uiBasisWScale_;
    uiBasis8Margin_ *= uiBasisWScale_;
    uiBasis10Margin_ *= uiBasisWScale_;
    uiBasis12Margin_ *= uiBasisWScale_;
    uiBasis15Margin_ *= uiBasisWScale_;
    uiBasis20Margin_ *= uiBasisWScale_;
    
    separateLineThick_ = screenScale_ > 2 ? 0.333 : 0.5;
    
    wideVideoWHScale_ = 16.0 / 9.0;
    wideVideoHWScale_ = 1.0 / wideVideoWHScale_;
    wideVideoPortraitSize_ = CGSizeMake(portraitScreenWidth_, ceil(portraitScreenWidth_ * wideVideoHWScale_));
    wideVideoLandscapeSize_ = CGSizeMake(ceil(portraitScreenWidth_ * wideVideoWHScale_), portraitScreenWidth_);
    wideVideoPlayerPortraitSize_ = CGSizeMake(wideVideoPortraitSize_.width, wideVideoPortraitSize_.height + statusBarH_);
}

+ (NSString *)appName {
    static NSString *appName_ = nil;
    if (!appName_) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        appName_ = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    }
    return appName_;
}

+ (NSString *)appVersion {
    static NSString *appVersion_ = nil;
    if (!appVersion_) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        appVersion_ = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    }
    return appVersion_;
}

+ (BOOL)is_iPad {
    return is_iPad_;
}

+ (BOOL)is_iphoneX {
    return is_iphoneX_;
}

+ (BOOL)is_iOS13 {
    return is_iOS13_;
}

+ (CGFloat)screenScale {
    return screenScale_;
}

+ (CGRect)portraitScreenBounds {
    return portraitScreenBounds_;
}

+ (CGSize)portraitScreenSize {
    return portraitScreenSize_;
}

+ (CGFloat)portraitScreenWidth {
    return portraitScreenWidth_;
}

+ (CGFloat)portraitScreenHeight {
    return portraitScreenHeight_;
}

+ (CGRect)landscapeScreenBounds {
    return landscapeScreenBounds_;
}

+ (CGSize)landscapeScreenSize {
    return landscapeScreenSize_;
}

+ (CGFloat)landscapeScreenWidth {
    return landscapeScreenWidth_;
}

+ (CGFloat)landscapeScreenHeight {
    return landscapeScreenHeight_;
}

+ (CGFloat)baseTabBarH {
    return baseTabBarH_;
}

+ (CGFloat)tabBarH {
    return tabBarH_;
}

+ (CGFloat)diffTabBarH {
    return diffTabBarH_;
}

+ (CGFloat)baseStatusBarH {
    return baseStatusBarH_;
}

+ (CGFloat)statusBarH {
    return statusBarH_;
}

+ (CGFloat)diffStatusBarH {
    return diffStatusBarH_;
}

+ (CGFloat)navBarH {
    return navBarH_;
}

+ (CGFloat)navTopMargin {
    return navTopMargin_;
}

+ (CGFloat)pageSheetPortraitNavBarH {
    return pageSheetPortraitNavBarH_;
}

+ (CGFloat)pageSheetPortraitScreenHeight {
    return pageSheetPortraitScreenHeight_;
}

+ (CGFloat)UIBasisWidthScale {
    return uiBasisWScale_;
}

+ (CGFloat)UIBasisHeightScale {
    return uiBasisHScale_;
}

+ (CGFloat)UIBasis5Margin {
    return uiBasis5Margin_;
}

+ (CGFloat)UIBasis8Margin {
    return uiBasis8Margin_;
}

+ (CGFloat)UIBasis10Margin {
    return uiBasis10Margin_;
}

+ (CGFloat)UIBasis12Margin {
    return uiBasis12Margin_;
}

+ (CGFloat)UIBasis15Margin {
    return uiBasis15Margin_;
}

+ (CGFloat)UIBasis20Margin {
    return uiBasis20Margin_;
}

+ (CGFloat)separateLineThick {
    return separateLineThick_;
}

+ (NSDateFormatter *)greenwichDateFormatter {
    static NSDateFormatter *greenwichDateFormatter_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        greenwichDateFormatter_ = [[NSDateFormatter alloc] init];
        [greenwichDateFormatter_ setDateFormat:@"yyyyMMddHHmmssSSS"];
    });
    return greenwichDateFormatter_;
}

+ (NSDateFormatter *)hhmmssSSFormatter {
    static NSDateFormatter *hhmmssSSFormatter_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hhmmssSSFormatter_ = [[NSDateFormatter alloc] init];
        [hhmmssSSFormatter_ setDateFormat:@"hh:mm:ss:SS"];
    });
    return hhmmssSSFormatter_;
}

+ (NSDateFormatter *)hhmmssFormatter {
    static NSDateFormatter *hhmmssFormatter_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hhmmssFormatter_ = [[NSDateFormatter alloc] init];
        [hhmmssFormatter_ setDateFormat:@"hh:mm:ss"];
    });
    return hhmmssFormatter_;
}

+ (NSDateFormatter *)hhmmFormatter {
    static NSDateFormatter *hhmmFormatter_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hhmmFormatter_ = [[NSDateFormatter alloc] init];
        [hhmmFormatter_ setDateFormat:@"hh:mm"];
    });
    return hhmmFormatter_;
}

/** 16 : 9 */
+ (CGFloat)wideVideoWHScale {
    return wideVideoWHScale_;
}
/** 9 : 16 */
+ (CGFloat)wideVideoHWScale {
    return wideVideoHWScale_;
}
/** 宽视频在竖屏非全屏时的尺寸 */
+ (CGSize)wideVideoPortraitSize {
    return wideVideoPortraitSize_;
}
/** 宽视频在横屏且全屏时的尺寸 */
+ (CGSize)wideVideoLandscapeSize {
    return wideVideoLandscapeSize_;
}
/** 宽视频播放器在竖屏非全屏时的尺寸（视频尺寸+状态栏高度） */
+ (CGSize)wideVideoPlayerPortraitSize {
    return wideVideoPlayerPortraitSize_;
}

@end
