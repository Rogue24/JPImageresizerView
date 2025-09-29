//
//  JPImageresizerConfigure.m
//  JPImageresizerView
//
//  Created by 周健平 on 2018/4/22.
//

#import "JPImageresizerConfigure.h"

@implementation JPImageresizerConfigure

#pragma mark - Configure

+ (instancetype)defaultConfigure {
    JPImageresizerConfigure *configure = [[self alloc] init];
    configure
    .jp_viewFrame([UIScreen mainScreen].bounds)
//    .jp_effect(nil)
    .jp_frameType(JPConciseFrameType)
    .jp_animationCurve(JPAnimationCurveEaseOut)
    .jp_strokeColor(UIColor.whiteColor)
    .jp_bgColor(UIColor.blackColor)
    .jp_maskAlpha(0.75)
//    .jp_resizeScaledBounds(CGRectZero)
//    .jp_resizeWHScale(0.0)
//    .jp_resizeCornerRadius(0.0)
//    .jp_ignoresCornerRadiusForDisplay(NO)
//    .jp_isRoundResize(NO)
//    .jp_maskImage(nil)
//    .jp_maskImageDisplayHandler(nil)
//    .jp_ignoresMaskImageForCrop(NO)
    .jp_isArbitrarily(YES)
    .jp_edgeLineIsEnabled(YES)
    .jp_contentInsets(UIEdgeInsetsMake(16, 16, 16, 16))
//    .jp_borderImage(nil)
//    .jp_borderImageRectInset(CGPointZero)
    .jp_maximumZoomScale(10.0)
    .jp_isShowMidDots(YES)
//    .jp_isBlurWhenDragging(NO)
//    .jp_isShowGridlinesWhenIdle(NO)
    .jp_isShowGridlinesWhenDragging(YES)
    .jp_gridCount(3)
//    .jp_isLoopPlaybackGIF(NO)
//    .jp_gifSettings(nil)
    .jp_isCleanHistoryAfterInitial(YES);
    return configure;
}

+ (JPImageresizerConfigure *)lightBlurMaskTypeConfigure {
    JPImageresizerConfigure *configure = [self defaultConfigure];
    configure
        .jp_effect([UIBlurEffect effectWithStyle:UIBlurEffectStyleLight])
        .jp_bgColor(UIColor.whiteColor)
        .jp_maskAlpha(0.25)
        .jp_strokeColor([UIColor colorWithRed:(56.0 / 255.0) green:(121.0 / 255.0) blue:(242.0 / 255.0) alpha:1.0]);
    return configure;
}

+ (JPImageresizerConfigure *)darkBlurMaskTypeConfigure {
    JPImageresizerConfigure *configure = [self defaultConfigure];
    configure
        .jp_effect([UIBlurEffect effectWithStyle:UIBlurEffectStyleDark])
        .jp_bgColor(UIColor.blackColor)
        .jp_maskAlpha(0.25);
    return configure;
}

+ (instancetype)defaultConfigureWithImage:(UIImage *)image make:(JPImageresizerConfigureMakeBlock)make {
    JPImageresizerConfigure *configure = [self defaultConfigure];
    configure.image = image;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)defaultConfigureWithImageData:(NSData *)imageData make:(JPImageresizerConfigureMakeBlock)make {
    JPImageresizerConfigure *configure = [self defaultConfigure];
    configure.imageData = imageData;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)defaultConfigureWithVideoURL:(NSURL *)videoURL
                                        make:(JPImageresizerConfigureMakeBlock)make
                               fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                               fixStartBlock:(JPVoidBlock)fixStartBlock
                            fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                            fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    JPImageresizerConfigure *configure = [self defaultConfigure];
    configure.videoURL = videoURL;
    configure.fixErrorBlock = fixErrorBlock;
    configure.fixStartBlock = fixStartBlock;
    configure.fixProgressBlock = fixProgressBlock;
    configure.fixCompleteBlock = fixCompleteBlock;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)defaultConfigureWithVideoAsset:(AVURLAsset *)videoAsset
                                          make:(JPImageresizerConfigureMakeBlock)make
                                 fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                 fixStartBlock:(JPVoidBlock)fixStartBlock
                              fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                              fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    JPImageresizerConfigure *configure = [self defaultConfigure];
    configure.videoAsset = videoAsset;
    configure.fixErrorBlock = fixErrorBlock;
    configure.fixStartBlock = fixStartBlock;
    configure.fixProgressBlock = fixProgressBlock;
    configure.fixCompleteBlock = fixCompleteBlock;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)lightBlurMaskTypeConfigureWithImage:(UIImage *)image make:(JPImageresizerConfigureMakeBlock)make {
    JPImageresizerConfigure *configure = [self lightBlurMaskTypeConfigure];
    configure.image = image;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)lightBlurMaskTypeConfigureWithImageData:(NSData *)imageData make:(JPImageresizerConfigureMakeBlock)make {
    JPImageresizerConfigure *configure = [self lightBlurMaskTypeConfigure];
    configure.imageData = imageData;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)lightBlurMaskTypeConfigureWithVideoURL:(NSURL *)videoURL
                                                  make:(JPImageresizerConfigureMakeBlock)make
                                         fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                         fixStartBlock:(JPVoidBlock)fixStartBlock
                                      fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                      fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    JPImageresizerConfigure *configure = [self lightBlurMaskTypeConfigure];
    configure.videoURL = videoURL;
    configure.fixErrorBlock = fixErrorBlock;
    configure.fixStartBlock = fixStartBlock;
    configure.fixProgressBlock = fixProgressBlock;
    configure.fixCompleteBlock = fixCompleteBlock;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)lightBlurMaskTypeConfigureWithVideoAsset:(AVURLAsset *)videoAsset
                                                    make:(JPImageresizerConfigureMakeBlock)make
                                           fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                           fixStartBlock:(JPVoidBlock)fixStartBlock
                                        fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                        fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    JPImageresizerConfigure *configure = [self lightBlurMaskTypeConfigure];
    configure.videoAsset = videoAsset;
    configure.fixErrorBlock = fixErrorBlock;
    configure.fixStartBlock = fixStartBlock;
    configure.fixProgressBlock = fixProgressBlock;
    configure.fixCompleteBlock = fixCompleteBlock;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)darkBlurMaskTypeConfigureWithImage:(UIImage *)image make:(JPImageresizerConfigureMakeBlock)make {
    JPImageresizerConfigure *configure = [self darkBlurMaskTypeConfigure];
    configure.image = image;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)darkBlurMaskTypeConfigureWithImageData:(NSData *)imageData make:(JPImageresizerConfigureMakeBlock)make {
    JPImageresizerConfigure *configure = [self darkBlurMaskTypeConfigure];
    configure.imageData = imageData;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)darkBlurMaskTypeConfigureWithVideoURL:(NSURL *)videoURL
                                                 make:(JPImageresizerConfigureMakeBlock)make
                                        fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                        fixStartBlock:(JPVoidBlock)fixStartBlock
                                     fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                     fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    JPImageresizerConfigure *configure = [self darkBlurMaskTypeConfigure];
    configure.videoURL = videoURL;
    configure.fixErrorBlock = fixErrorBlock;
    configure.fixStartBlock = fixStartBlock;
    configure.fixProgressBlock = fixProgressBlock;
    configure.fixCompleteBlock = fixCompleteBlock;
    !make ? : make(configure);
    return configure;
}

+ (instancetype)darkBlurMaskTypeConfigureWithVideoAsset:(AVURLAsset *)videoAsset
                                                   make:(JPImageresizerConfigureMakeBlock)make
                                          fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                          fixStartBlock:(JPVoidBlock)fixStartBlock
                                       fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                       fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    JPImageresizerConfigure *configure = [self darkBlurMaskTypeConfigure];
    configure.videoAsset = videoAsset;
    configure.fixErrorBlock = fixErrorBlock;
    configure.fixStartBlock = fixStartBlock;
    configure.fixProgressBlock = fixProgressBlock;
    configure.fixCompleteBlock = fixCompleteBlock;
    !make ? : make(configure);
    return configure;
}

#pragma mark - History

- (BOOL)isSavedHistory {
    return !JPCropHistoryIsNull(self.history);
}

- (void)cleanHistory {
    JPCropHistory history = self.history;
    if (JPCropHistoryIsNull(history)) return;
    history.viewFrame = CGRectNull;
    self.history = history;
}

#pragma mark - Setter

- (void)setImage:(UIImage *)image {
    _image = image;
    if (image) {
        _imageData = nil;
        _videoURL = nil;
        _videoAsset = nil;
    }
}

- (void)setImageData:(NSData *)imageData {
    _imageData = imageData;
    if (imageData) {
        _image = nil;
        _videoURL = nil;
        _videoAsset = nil;
    }
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    if (videoURL) {
        _image = nil;
        _imageData = nil;
        _videoAsset = nil;
    }
}

- (void)setVideoAsset:(AVURLAsset *)videoAsset {
    _videoAsset = videoAsset;
    if (videoAsset) {
        _image = nil;
        _imageData = nil;
        _videoURL = nil;
    }
}

#pragma mark - Block

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

- (JPImageresizerConfigure *(^)(UIVisualEffect *))jp_effect {
    return ^(UIVisualEffect *effect) {
        self.effect = effect;
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

- (JPImageresizerConfigure * _Nonnull (^)(CGRect))jp_resizeScaledBounds {
    return ^(CGRect resizeScaledBounds) {
        self.resizeScaledBounds = resizeScaledBounds;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat))jp_resizeWHScale {
    return ^(CGFloat resizeWHScale) {
        self.resizeWHScale = resizeWHScale;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGFloat))jp_resizeCornerRadius {
    return ^(CGFloat resizeCornerRadius) {
        self.resizeCornerRadius = resizeCornerRadius;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_ignoresCornerRadiusForDisplay {
    return ^(BOOL ignoresCornerRadiusForDisplay) {
        self.ignoresCornerRadiusForDisplay = ignoresCornerRadiusForDisplay;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isRoundResize {
    return ^(BOOL isRoundResize) {
        self.isRoundResize = isRoundResize;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(UIImage *))jp_maskImage {
    return ^(UIImage *maskImage) {
        self.maskImage = maskImage;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(JPMaskImageDisplayHandler))jp_maskImageDisplayHandler {
    return ^(JPMaskImageDisplayHandler maskImageDisplayHandler) {
        self.maskImageDisplayHandler = maskImageDisplayHandler;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_ignoresMaskImageForCrop {
    return ^(BOOL ignoresMaskImageForCrop) {
        self.ignoresMaskImageForCrop = ignoresMaskImageForCrop;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isArbitrarily {
    return ^(BOOL isArbitrarily) {
        self.isArbitrarily = isArbitrarily;
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

- (JPImageresizerConfigure *(^)(BOOL))jp_isLoopPlaybackGIF {
    return ^(BOOL isLoopPlaybackGIF) {
        self.isLoopPlaybackGIF = isLoopPlaybackGIF;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(JPImageProcessingSettings *))jp_gifSettings {
    return ^(JPImageProcessingSettings *gifSettings) {
        self.gifSettings = gifSettings;
        return self;
    };
}

- (JPImageresizerConfigure *(^)(BOOL))jp_isCleanHistoryAfterInitial {
    return ^(BOOL isCleanHistoryAfterInitial) {
        self.isCleanHistoryAfterInitial = isCleanHistoryAfterInitial;
        return self;
    };
}

@end
