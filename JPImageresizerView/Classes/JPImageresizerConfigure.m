//
//  JPImageresizerConfigure.m
//  JPImageresizerView
//
//  Created by 周健平 on 2018/4/22.
//

#import "JPImageresizerConfigure.h"

@implementation JPImageresizerConfigure

+ (instancetype)defaultConfigureWithResizeImage:(UIImage *)resizeImage make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [[self alloc] init];
    configure.resizeImage = resizeImage;
    [configure __defaultSetup];
    !make ? : make(configure);
    return configure;
}
+ (instancetype)defaultConfigureWithVideoURL:(NSURL *)videoURL make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [[self alloc] init];
    configure.videoURL = videoURL;
    [configure __defaultSetup];
    !make ? : make(configure);
    return configure;
}

+ (instancetype)lightBlurMaskTypeConfigureWithResizeImage:(UIImage *)resizeImage make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [self defaultConfigureWithResizeImage:resizeImage make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_blurEffect([UIBlurEffect effectWithStyle:UIBlurEffectStyleLight])
        .jp_bgColor(UIColor.whiteColor).jp_maskAlpha(0.25)
        .jp_strokeColor([UIColor colorWithRed:(56.0 / 255.0) green:(121.0 / 255.0) blue:(242.0 / 255.0) alpha:1.0]);
    }];
    !make ? : make(configure);
    return configure;
}
+ (instancetype)lightBlurMaskTypeConfigureWithVideoURL:(NSURL *)videoURL make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [self defaultConfigureWithVideoURL:videoURL make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_blurEffect([UIBlurEffect effectWithStyle:UIBlurEffectStyleLight])
        .jp_bgColor(UIColor.whiteColor).jp_maskAlpha(0.25)
        .jp_strokeColor([UIColor colorWithRed:(56.0 / 255.0) green:(121.0 / 255.0) blue:(242.0 / 255.0) alpha:1.0]);
    }];
    !make ? : make(configure);
    return configure;
}

+ (instancetype)darkBlurMaskTypeConfigureWithResizeImage:(UIImage *)resizeImage make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [self defaultConfigureWithResizeImage:resizeImage make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_blurEffect([UIBlurEffect effectWithStyle:UIBlurEffectStyleDark])
        .jp_bgColor(UIColor.blackColor).jp_maskAlpha(0.25);
    }];
    !make ? : make(configure);
    return configure;
}
+ (instancetype)darkBlurMaskTypeConfigureWithVideoURL:(NSURL *)videoURL make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [self defaultConfigureWithVideoURL:videoURL make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_blurEffect([UIBlurEffect effectWithStyle:UIBlurEffectStyleDark])
        .jp_bgColor(UIColor.blackColor).jp_maskAlpha(0.25);
    }];
    !make ? : make(configure);
    return configure;
}

- (void)__defaultSetup {
    self
    .jp_viewFrame([UIScreen mainScreen].bounds)
    .jp_blurEffect(nil)
    .jp_frameType(JPConciseFrameType)
    .jp_animationCurve(JPAnimationCurveEaseOut)
    .jp_strokeColor(UIColor.whiteColor)
    .jp_bgColor(UIColor.blackColor)
    .jp_maskAlpha(0.75)
    .jp_resizeWHScale(0.0)
    .jp_isArbitrarilyInitial(YES)
    .jp_edgeLineIsEnabled(YES)
    .jp_contentInsets(UIEdgeInsetsZero)
    .jp_borderImage(nil)
    .jp_borderImageRectInset(CGPointZero)
    .jp_maximumZoomScale(10.0)
    .jp_isRoundResize(NO)
    .jp_isShowMidDots(YES)
    .jp_isBlurWhenDragging(NO)
    .jp_isShowGridlinesWhenIdle(NO)
    .jp_isShowGridlinesWhenDragging(YES)
    .jp_gridCount(3)
    .jp_maskImage(nil)
    .jp_isArbitrarilyMask(NO);
}

- (void)setResizeImage:(UIImage *)resizeImage {
    _resizeImage = resizeImage;
    if (resizeImage) _videoURL = nil;
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    if (videoURL) _resizeImage = nil;
}

- (JPImageresizerConfigure *(^)(CGRect))jp_viewFrame {
    return ^(CGRect viewFrame) {
        self.viewFrame = viewFrame;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(JPImageresizerFrameType))jp_frameType {
    return ^(JPImageresizerFrameType frameType) {
        self.frameType = frameType;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(JPAnimationCurve))jp_animationCurve {
    return ^(JPAnimationCurve animationCurve) {
        self.animationCurve = animationCurve;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIBlurEffect *))jp_blurEffect {
    return ^(UIBlurEffect *blurEffect) {
        self.blurEffect = blurEffect;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIColor *))jp_bgColor {
    return ^(UIColor *bgColor) {
        self.bgColor = bgColor;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat))jp_maskAlpha {
    return ^(CGFloat maskAlpha) {
        self.maskAlpha = maskAlpha;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIColor *))jp_strokeColor {
    return ^(UIColor *strokeColor) {
        self.strokeColor = strokeColor;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat))jp_resizeWHScale {
    return ^(CGFloat resizeWHScale) {
        self.resizeWHScale = resizeWHScale;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isArbitrarilyInitial {
    return ^(BOOL isArbitrarilyInitial) {
        self.isArbitrarilyInitial = isArbitrarilyInitial;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_edgeLineIsEnabled {
    return ^(BOOL edgeLineIsEnabled) {
        self.edgeLineIsEnabled = edgeLineIsEnabled;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIEdgeInsets))jp_contentInsets {
    return ^(UIEdgeInsets contentInsets) {
        self.contentInsets = contentInsets;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isClockwiseRotation {
    return ^(BOOL isClockwiseRotation) {
        self.isClockwiseRotation = isClockwiseRotation;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIImage *))jp_borderImage {
    return ^(UIImage *borderImage) {
        self.borderImage = borderImage;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGPoint))jp_borderImageRectInset {
    return ^(CGPoint borderImageRectInset) {
        self.borderImageRectInset = borderImageRectInset;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat))jp_maximumZoomScale {
    return ^(CGFloat maximumZoomScale) {
        self.maximumZoomScale = maximumZoomScale;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isRoundResize {
    return ^(BOOL isRoundResize) {
        self.isRoundResize = isRoundResize;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isShowMidDots {
    return ^(BOOL isShowMidDots) {
        self.isShowMidDots = isShowMidDots;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isBlurWhenDragging {
    return ^(BOOL isBlurWhenDragging) {
        self.isBlurWhenDragging = isBlurWhenDragging;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isShowGridlinesWhenIdle {
    return ^(BOOL isShowGridlinesWhenIdle) {
        self.isShowGridlinesWhenIdle = isShowGridlinesWhenIdle;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isShowGridlinesWhenDragging {
    return ^(BOOL isShowGridlinesWhenDragging) {
        self.isShowGridlinesWhenDragging = isShowGridlinesWhenDragging;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(NSUInteger))jp_gridCount {
    return ^(NSUInteger gridCount) {
        self.gridCount = gridCount;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIImage *))jp_maskImage {
    return ^(UIImage *maskImage) {
        self.maskImage = maskImage;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isArbitrarilyMask {
    return ^(BOOL isArbitrarilyMask) {
        self.isArbitrarilyMask = isArbitrarilyMask;
        return self;
    };
}

@end
