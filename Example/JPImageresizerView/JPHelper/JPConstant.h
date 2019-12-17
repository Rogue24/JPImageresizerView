//
//  JPConstant.h
//  Infinitee2.0
//
//  Created by 周健平 on 2017/9/24.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPConstant;

#pragma mark - Block

typedef UIInterfaceOrientationMask(^JPGetCurrentInterfaceOrientationBlock)(void);

#pragma mark - 常量

/** 字体字号高度的单方向增值（顶部或底部） */
UIKIT_EXTERN CGFloat const JPBasePadding; // 1.5
/** 字体字号高度的垂直方向增值（顶部和底部） */
UIKIT_EXTERN CGFloat const JPBaseVerPadding; // 3.0
// 例如：“xfuay”中的“f”顶部和“y”底部的额外高度增值，各自1.5，总共3.0

#pragma mark - 宏

/** 自定义日志 */
#ifdef DEBUG
#define JPLog(...) printf("%s %s 第%d行: %s\n", [[[JPConstant hhmmssSSFormatter] stringFromDate:[NSDate date]] UTF8String], __FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define JPLog(...)
#endif

#define JPis_iphoneX [JPConstant is_iphoneX]
#define JPis_iOS13 [JPConstant is_iOS13]

#define JPScreenScale [JPConstant screenScale]
#define JPPortraitScreenBounds [JPConstant portraitScreenBounds]
#define JPPortraitScreenSize [JPConstant portraitScreenSize]
#define JPPortraitScreenWidth [JPConstant portraitScreenWidth]
#define JPPortraitScreenHeight [JPConstant portraitScreenHeight]

#define JPBaseTabBarH [JPConstant baseTabBarH]
#define JPTabBarH [JPConstant tabBarH]
#define JPDiffTabBarH [JPConstant diffTabBarH]

#define JPBaseStatusBarH [JPConstant baseStatusBarH]
#define JPStatusBarH [JPConstant statusBarH]
#define JPDiffStatusBarH [JPConstant diffStatusBarH]

#define JPNavBarH [JPConstant navBarH]
#define JPNavTopMargin [JPConstant navTopMargin]

#define JPScale [JPConstant UIBasisWidthScale]
#define JPHScale [JPConstant UIBasisHeightScale]

#define JP5Margin [JPConstant UIBasis5Margin]
#define JP8Margin [JPConstant UIBasis8Margin]
#define JP10Margin [JPConstant UIBasis10Margin]
#define JP12Margin [JPConstant UIBasis12Margin]
#define JP15Margin [JPConstant UIBasis15Margin]
#define JP20Margin [JPConstant UIBasis20Margin]

#define JPSeparateLineThick [JPConstant separateLineThick]

#define JPGreenwichDateFormatter [JPConstant greenwichDateFormatter]

/** 16 : 9 */
#define JPWideVideoWHScale [JPConstant wideVideoWHScale]
/** 9 : 16 */
#define JPWideVideoHWScale [JPConstant wideVideoHWScale]
/** 宽视频在竖屏非全屏时的尺寸 */
#define JPWideVideoPortraitSize [JPConstant wideVideoPortraitSize]
/** 宽视频在横屏且全屏时的尺寸 */
#define JPWideVideoLandscapeSize [JPConstant wideVideoLandscapeSize]
/** 宽视频播放器在竖屏非全屏时的尺寸（视频尺寸+状态栏高度） */
#define JPWideVideoPlayerPortraitSize [JPConstant wideVideoPlayerPortraitSize]

@interface JPConstant : NSObject
+ (NSString *)appName;
+ (NSString *)appVersion;

+ (BOOL)is_iphoneX;
+ (BOOL)is_iOS13;

+ (CGFloat)screenScale;
+ (CGRect)portraitScreenBounds;
+ (CGSize)portraitScreenSize;
+ (CGFloat)portraitScreenWidth;
+ (CGFloat)portraitScreenHeight;

+ (CGFloat)baseTabBarH;
+ (CGFloat)tabBarH;
+ (CGFloat)diffTabBarH;

+ (CGFloat)baseStatusBarH;
+ (CGFloat)statusBarH;
+ (CGFloat)diffStatusBarH;

+ (CGFloat)navBarH;
+ (CGFloat)navTopMargin;

+ (CGFloat)pageSheetPortraitNavBarH;
+ (CGFloat)pageSheetPortraitScreenHeight;

+ (CGFloat)UIBasisWidthScale;
+ (CGFloat)UIBasisHeightScale;

+ (CGFloat)UIBasis5Margin;
+ (CGFloat)UIBasis8Margin;
+ (CGFloat)UIBasis10Margin;
+ (CGFloat)UIBasis12Margin;
+ (CGFloat)UIBasis15Margin;
+ (CGFloat)UIBasis20Margin;

+ (CGFloat)separateLineThick;

+ (NSDateFormatter *)greenwichDateFormatter;
+ (NSDateFormatter *)hhmmssSSFormatter;
+ (NSDateFormatter *)hhmmssFormatter;
+ (NSDateFormatter *)hhmmFormatter;

/** 16 : 9 */
+ (CGFloat)wideVideoWHScale;
/** 9 : 16 */
+ (CGFloat)wideVideoHWScale;
/** 宽视频在竖屏非全屏时的尺寸 */
+ (CGSize)wideVideoPortraitSize;
/** 宽视频在横屏且全屏时的尺寸 */
+ (CGSize)wideVideoLandscapeSize;
/** 宽视频播放器在竖屏非全屏时的尺寸（视频尺寸+状态栏高度） */
+ (CGSize)wideVideoPlayerPortraitSize;
@end
