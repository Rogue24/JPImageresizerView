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
    .jp_frameType(JPConciseFrameType)
    .jp_animationCurve(JPAnimationCurveEaseOut)
//    .jp_mainAppearance(^(JPImageresizerAppearance *appearance) {})
//    .jp_resizeScaledBounds(CGRectZero)
//    .jp_resizeWHScale(0.0)
//    .jp_resizeCornerRadius(0.0)
//    .jp_ignoresCornerRadiusForDisplay(NO)
//    .jp_isRoundResize(NO)
//    .jp_maskImage(nil)
//    .jp_maskImageDisplayHandler(nil)
//    .jp_maskAppearance(nil)
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

#pragma mark - Getter

- (JPImageresizerAppearance *)mainAppearance {
    if (!_mainAppearance) {
        _mainAppearance = [[JPImageresizerAppearance alloc] initWithStrokeColor:UIColor.whiteColor bgEffect:nil bgColor:UIColor.blackColor maskAlpha:0.75];
    }
    return _mainAppearance;
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

- (JPImageresizerConfigure *(^)(JPAppearanceSettingBlock))jp_mainAppearance {
    return ^(JPAppearanceSettingBlock settingBlock) {
        !settingBlock ? : settingBlock(self.mainAppearance);
        return self;
    };
}

- (JPImageresizerConfigure *(^)(CGRect))jp_resizeScaledBounds {
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

- (JPImageresizerConfigure * (^)(JPImageresizerAppearance *))jp_maskAppearance {
    return ^(JPImageresizerAppearance *maskAppearance) {
        self.maskAppearance = maskAppearance;
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
