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
    .jp_maskType(JPNormalMaskType)
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
    .jp_borderImageRectInset(CGPointZero);
    !make ? : make(configure);
    return configure;
}

+ (instancetype)blurMaskTypeConfigureWithResizeImage:(UIImage *)resizeImage isLight:(BOOL)isLight make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerMaskType maskType = isLight ? JPLightBlurMaskType : JPDarkBlurMaskType;
    JPImageresizerConfigure *configure = [self defaultConfigureWithResizeImage:resizeImage make:^(JPImageresizerConfigure *configure) {
        configure.jp_maskType(maskType).jp_maskAlpha(0.3);
    }];
    !make ? : make(configure);
    return configure;
}

- (void)setMaskType:(JPImageresizerMaskType)maskType {
    _maskType = maskType;
    if (maskType == JPLightBlurMaskType) {
        self.bgColor = [UIColor whiteColor];
    } else if (maskType == JPDarkBlurMaskType) {
        self.bgColor = [UIColor blackColor];
    }
}

- (void)setBgColor:(UIColor *)bgColor {
    if (self.maskType == JPLightBlurMaskType) {
        _bgColor = [UIColor whiteColor];
    } else if (self.maskType == JPDarkBlurMaskType) {
        _bgColor = [UIColor blackColor];
    } else {
        _bgColor = bgColor;
    }
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

- (JPImageresizerConfigure *(^)(JPImageresizerMaskType))jp_maskType {
    return ^(JPImageresizerMaskType maskType) {
        self.maskType = maskType;
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

- (JPImageresizerConfigure *(^)(UIColor *))jp_strokeColor {
    return ^(UIColor *strokeColor) {
        self.strokeColor = strokeColor;
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

@end
