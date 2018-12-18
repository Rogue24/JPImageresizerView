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
    configure.viewFrame = [UIScreen mainScreen].bounds;
    configure.maskAlpha = JPNormalMaskType;
    configure.frameType = JPConciseFrameType;
    configure.animationCurve = JPAnimationCurveEaseOut;
    configure.strokeColor = [UIColor whiteColor];
    configure.bgColor = [UIColor blackColor];
    configure.maskAlpha = 0.75;
    configure.verBaseMargin = 10.0;
    configure.horBaseMargin = 10.0;
    configure.resizeWHScale = 0.0;
    configure.edgeLineIsEnabled = YES;
    configure.contentInsets = UIEdgeInsetsZero;
    !make ? : make(configure);
    return configure;
}

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    _frameType = frameType;
}

- (void)setAnimationCurve:(JPAnimationCurve)animationCurve {
    _animationCurve = animationCurve;
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

- (JPImageresizerConfigure *(^)(UIImage *resizeImage))jp_resizeImage {
    return ^(UIImage *resizeImage) {
        self.resizeImage = resizeImage;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGRect viewFrame))jp_viewFrame {
    return ^(CGRect viewFrame) {
        self.viewFrame = viewFrame;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(JPImageresizerMaskType maskType))jp_maskType {
    return ^(JPImageresizerMaskType maskType) {
        self.maskType = maskType;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(JPImageresizerFrameType frameType))jp_frameType {
    return ^(JPImageresizerFrameType frameType) {
        self.frameType = frameType;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(JPAnimationCurve animationCurve))jp_animationCurve {
    return ^(JPAnimationCurve animationCurve) {
        self.animationCurve = animationCurve;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIColor *strokeColor))jp_strokeColor {
    return ^(UIColor *strokeColor) {
        self.strokeColor = strokeColor;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIColor *bgColor))jp_bgColor {
    return ^(UIColor *bgColor) {
        self.bgColor = bgColor;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat maskAlpha))jp_maskAlpha {
    return ^(CGFloat maskAlpha) {
        self.maskAlpha = maskAlpha;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat resizeWHScale))jp_resizeWHScale {
    return ^(CGFloat resizeWHScale) {
        self.resizeWHScale = resizeWHScale;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL edgeLineIsEnabled))jp_edgeLineIsEnabled {
    return ^(BOOL edgeLineIsEnabled) {
        self.edgeLineIsEnabled = edgeLineIsEnabled;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat verBaseMargin))jp_verBaseMargin {
    return ^(CGFloat verBaseMargin) {
        self.verBaseMargin = verBaseMargin;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat horBaseMargin))jp_horBaseMargin {
    return ^(CGFloat horBaseMargin) {
        self.horBaseMargin = horBaseMargin;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIEdgeInsets contentInsets))jp_contentInsets {
    return ^(UIEdgeInsets contentInsets) {
        self.contentInsets = contentInsets;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL isClockwiseRotation))jp_isClockwiseRotation {
    return ^(BOOL isClockwiseRotation) {
        self.isClockwiseRotation = isClockwiseRotation;
        return self;
    };
}

@end
