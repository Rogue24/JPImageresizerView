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
    configure
    .jp_resizeImage(resizeImage)
    .jp_viewFrame([UIScreen mainScreen].bounds)
    .jp_blurEffect(nil)
    .jp_frameType(JPConciseFrameType)
    .jp_animationCurve(JPAnimationCurveEaseOut)
    .jp_strokeColor(UIColor.whiteColor)
    .jp_bgColor(UIColor.blackColor)
    .jp_maskAlpha(0.75)
    .jp_verBaseMargin(10.0)
    .jp_horBaseMargin(10.0)
    .jp_resizeWHScale(0.0)
    .jp_edgeLineIsEnabled(YES)
    .jp_contentInsets(UIEdgeInsetsZero)
    .jp_borderImage(nil)
    .jp_borderImageRectInset(CGPointZero)
    .jp_maximumZoomScale(10.0)
    .jp_isRoundResize(NO)
    .jp_isShowMidDots(YES);
    !make ? : make(configure);
    return configure;
}

+ (instancetype)lightBlurMaskTypeConfigureWithResizeImage:(UIImage *)resizeImage make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [self defaultConfigureWithResizeImage:resizeImage make:^(JPImageresizerConfigure *configure) {
        configure.jp_blurEffect([UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]).jp_bgColor([UIColor whiteColor]).jp_maskAlpha(0.25);
    }];
    !make ? : make(configure);
    return configure;
}

+ (instancetype)darkBlurMaskTypeConfigureWithResizeImage:(UIImage *)resizeImage make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [self defaultConfigureWithResizeImage:resizeImage make:^(JPImageresizerConfigure *configure) {
        configure.jp_blurEffect([UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]).jp_bgColor([UIColor blackColor]).jp_maskAlpha(0.25);
    }];
    !make ? : make(configure);
    return configure;
}

- (JPImageresizerConfigure *(^)(UIImage *))jp_resizeImage {
    return ^(UIImage *resizeImage) {
        self.resizeImage = resizeImage;
        return self;
    };
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

- (JPImageresizerConfigure *(^)(BOOL))jp_edgeLineIsEnabled {
    return ^(BOOL edgeLineIsEnabled) {
        self.edgeLineIsEnabled = edgeLineIsEnabled;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat))jp_verBaseMargin {
    return ^(CGFloat verBaseMargin) {
        self.verBaseMargin = verBaseMargin;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat))jp_horBaseMargin {
    return ^(CGFloat horBaseMargin) {
        self.horBaseMargin = horBaseMargin;
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

@end
