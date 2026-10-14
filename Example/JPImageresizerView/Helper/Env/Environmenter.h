//
//  Environmenter.h
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
