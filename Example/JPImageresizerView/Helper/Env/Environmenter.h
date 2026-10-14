//
//  Environmenter.h
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Notification: 场景发生变化的通知（内外屏切换、内屏旋转、内屏全屏分屏切换、内屏左右分屏切换）
 * object: nil
 * userInfo: @{@"options": 变化的环境变量，如 bounds、safeAreaInsets 等, @"transitionDuration": 建议的转场动画时长，0代表无需动画}
 */
UIKIT_EXTERN NSNotificationName const EnvSceneDidChange;

/**
 * Notification: 铰链状态发生变化的通知
 * object: nil
 * userInfo: @{@"oldStatus": 旧状态, @"nowStatus": 当前状态}
 */
UIKIT_EXTERN NSNotificationName const EnvHingeStatusDidChange;

/// Env变量更新选项
typedef NS_OPTIONS(NSUInteger, EnvUpdateOptions) {
    EnvUpdateOptions_None           = 0,
    EnvUpdateOptions_Bounds         = 1 << 0,
    EnvUpdateOptions_SafeArea       = 1 << 1,
    EnvUpdateOptions_HorSizeClass   = 1 << 2,
    EnvUpdateOptions_VerSizeClass   = 1 << 3,
    EnvUpdateOptions_All = EnvUpdateOptions_Bounds |
                           EnvUpdateOptions_SafeArea |
                           EnvUpdateOptions_HorSizeClass |
                           EnvUpdateOptions_VerSizeClass
};

typedef NS_ENUM(NSInteger, EnvDisplayMode) {
    EnvDisplayMode_OuterPortrait = 0,
    EnvDisplayMode_OuterLandscapeLeft = 1,
    EnvDisplayMode_OuterLandscapeRight = 2,
    EnvDisplayMode_InnerLandscapeFull = 3,
    EnvDisplayMode_InnerPortraitFull = 4,
    EnvDisplayMode_InnerSplitLeft = 5,
    EnvDisplayMode_InnerSplitRight = 6,
};

/// The status of an individual hinge
typedef NS_ENUM(NSInteger, EnvHingeStatus) {
    /// The status of the hinge is unknown
    EnvHingeStatus_Unknown = 0,
    /// The hinge is closed
    EnvHingeStatus_Closed = 1,
    /// The hinge is partially open
    EnvHingeStatus_PartiallyOpen = 2,
    /// The hinge is open as far as the device allows
    EnvHingeStatus_FullyOpen = 3,
};

@interface Environmenter : NSObject

@end

NS_ASSUME_NONNULL_END
