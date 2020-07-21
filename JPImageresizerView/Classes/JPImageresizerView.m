//
//  JPImageresizerView.m
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerView.h"
#import "JPImageresizerVideoObject.h"
#import "JPImageresizerSlider.h"
#import "JPImageresizerTool.h"

#ifdef DEBUG
#define JPIRLog(...) printf("%s %s 第%d行: %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define JPIRLog(...)
#endif

@interface JPImageresizerView () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *allDirections;
@property (nonatomic, assign) NSInteger directionIndex;
@property (nonatomic, strong) JPImageresizerVideoObject *videoObj;
@property (nonatomic, strong) JPPlayerView *playerView;
@property (nonatomic, strong) JPImageresizerSlider *slider;
@property (nonatomic, weak) AVAssetExportSession *exporterSession;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, copy) JPVideoExportProgressBlock progressBlock;
@end

@implementation JPImageresizerView
{
    UIEdgeInsets _contentInsets;
    UIViewAnimationOptions _animationOption;
    CGFloat _objWhScale;
}

#pragma mark - setter

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    [self.frameView updateFrameType:frameType];
}

- (void)setBlurEffect:(UIBlurEffect *)blurEffect {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:blurEffect bgColor:self.bgColor maskAlpha:self.maskAlpha animated:YES];
}

- (void)setBgColor:(UIColor *)bgColor {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:self.blurEffect bgColor:bgColor maskAlpha:self.maskAlpha animated:YES];
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:self.blurEffect bgColor:self.bgColor maskAlpha:maskAlpha animated:YES];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [self.frameView setupStrokeColor:strokeColor blurEffect:self.blurEffect bgColor:self.bgColor maskAlpha:self.maskAlpha animated:YES];
}

- (void)setImage:(UIImage *)image {
    [self setImage:image animated:YES];
}

- (void)setImageData:(NSData *)imageData {
    [self setImageData:imageData animated:YES];
}

- (void)setIsLoopPlaybackGIF:(BOOL)isLoopPlaybackGIF {
    if (_isLoopPlaybackGIF == isLoopPlaybackGIF) return;
    _isLoopPlaybackGIF = isLoopPlaybackGIF;
    if (!_isGIF) return;
    if (isLoopPlaybackGIF) {
        JPImageresizerSlider *slider = self.slider;
        self.frameView.slider = nil;
        self.slider = nil;
        if (slider) {
            [UIView animateWithDuration:0.2 animations:^{
                slider.alpha = 0;
            } completion:^(BOOL finished) {
                [slider removeFromSuperview];
            }];
        }
    } else {
        [self __setupSlider:NO];
        CGRect sliderFrame = [self.frameView convertRect:self.frameView.imageresizerFrame toView:self];
        [self.slider setImageresizerFrame:sliderFrame isRoundResize:_frameView.isRoundResizing];
        self.slider.alpha = 0;
        [self addSubview:self.slider];
        [UIView animateWithDuration:0.2 animations:^{
            self.slider.alpha = 1;
        }];
        self.frameView.slider = self.slider;
    }
    [self __updateImageViewImage:NO];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    [self.frameView setResizeWHScale:resizeWHScale isToBeArbitrarily:NO animated:YES];
}

- (void)setInitialResizeWHScale:(CGFloat)initialResizeWHScale {
    self.frameView.initialResizeWHScale = initialResizeWHScale;
}

- (void)setEdgeLineIsEnabled:(BOOL)edgeLineIsEnabled {
    _edgeLineIsEnabled = edgeLineIsEnabled;
    self.frameView.edgeLineIsEnabled = edgeLineIsEnabled;
}

- (void)setIsClockwiseRotation:(BOOL)isClockwiseRotation {
    if (_isClockwiseRotation == isClockwiseRotation) return;
    _isClockwiseRotation = isClockwiseRotation;
    [self.allDirections exchangeObjectAtIndex:1 withObjectAtIndex:3];
    if (self.directionIndex == 1) {
        self.directionIndex = 3;
    } else if (self.directionIndex == 3) {
        self.directionIndex = 1;
    }
}

- (void)setDirectionIndex:(NSInteger)directionIndex {
    NSInteger maxIndex = self.allDirections.count - 1;
    NSInteger minIndex = 0;
    if (directionIndex < minIndex) {
        directionIndex = maxIndex;
    } else if (directionIndex > maxIndex) {
        directionIndex = minIndex;
    }
    _directionIndex = directionIndex;
}

- (void)setAnimationCurve:(JPAnimationCurve)animationCurve {
    _animationCurve = animationCurve;
    _frameView.animationCurve = animationCurve;
    switch (animationCurve) {
        case JPAnimationCurveEaseInOut:
            _animationOption = UIViewAnimationOptionCurveEaseInOut;
            break;
        case JPAnimationCurveEaseIn:
            _animationOption = UIViewAnimationOptionCurveEaseIn;
            break;
        case JPAnimationCurveEaseOut:
            _animationOption = UIViewAnimationOptionCurveEaseOut;
            break;
        case JPAnimationCurveLinear:
            _animationOption = UIViewAnimationOptionCurveLinear;
            break;
    }
}

- (void)setIsLockResizeFrame:(BOOL)isLockResizeFrame {
    self.frameView.panGR.enabled = !isLockResizeFrame;
}

- (void)setVerticalityMirror:(BOOL)verticalityMirror {
    [self setVerticalityMirror:verticalityMirror animated:YES];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror {
    [self setHorizontalMirror:horizontalMirror animated:YES];
}

- (void)setIsPreview:(BOOL)isPreview {
    [self setIsPreview:isPreview animated:YES];
}

- (void)setBorderImage:(UIImage *)borderImage {
    self.frameView.borderImage = borderImage;
}

- (void)setBorderImageRectInset:(CGPoint)borderImageRectInset {
    self.frameView.borderImageRectInset = borderImageRectInset;
}

- (void)setIsShowMidDots:(BOOL)isShowMidDots {
    self.frameView.isShowMidDots = isShowMidDots;
}

- (void)setIsBlurWhenDragging:(BOOL)isBlurWhenDragging {
    self.frameView.isBlurWhenDragging = isBlurWhenDragging;
}

- (void)setIsShowGridlinesWhenIdle:(BOOL)isShowGridlinesWhenIdle {
    self.frameView.isShowGridlinesWhenIdle = isShowGridlinesWhenIdle;
}

- (void)setIsShowGridlinesWhenDragging:(BOOL)isShowGridlinesWhenDragging {
    self.frameView.isShowGridlinesWhenDragging = isShowGridlinesWhenDragging;
}

- (void)setGridCount:(NSUInteger)gridCount {
    self.frameView.gridCount = gridCount;
}

- (void)setMaskImage:(UIImage *)maskImage {
    [self.frameView setMaskImage:maskImage animated:YES];
}

- (void)setIsArbitrarilyMask:(BOOL)isArbitrarilyMask {
    [self.frameView setIsArbitrarilyMask:isArbitrarilyMask animated:YES];
}

#pragma mark - getter

- (JPImageresizerFrameType)frameType {
    return _frameView.frameType;
}

- (CGSize)baseContentMaxSize {
    return _frameView.baseContentMaxSize;
}

- (UIBlurEffect *)blurEffect {
    return _frameView.blurEffect;
}

- (UIColor *)bgColor {
    return _frameView.bgColor;
}

- (CGFloat)maskAlpha {
    return _frameView.maskAlpha;
}

- (UIColor *)strokeColor {
    return _frameView.strokeColor;
}

- (NSURL *)videoURL {
    return _videoObj.asset.URL;
}

- (AVURLAsset *)videoAsset {
    return _videoObj.asset;
}

- (CGFloat)resizeWHScale {
    return _frameView.resizeWHScale;
}

- (CGFloat)initialResizeWHScale {
    return _frameView.initialResizeWHScale;
}

- (CGFloat)imageresizeWHScale {
    CGFloat w = _frameView.imageresizerFrame.size.width;
    CGFloat h = _frameView.imageresizerFrame.size.height;
    if (w > 0.0 && h > 0.0) {
        return (w / h);
    }
    return 0.0;
}

- (BOOL)isLockResizeFrame {
    return !_frameView.panGR.enabled;
}

- (BOOL)isPreview {
    return _frameView.isPreview;
}

- (UIImage *)borderImage {
    return _frameView.borderImage;
}

- (CGPoint)borderImageRectInset {
    return _frameView.borderImageRectInset;
}

- (BOOL)isShowMidDots {
    return _frameView.isShowMidDots;
}

- (BOOL)isBlurWhenDragging {
    return _frameView.isBlurWhenDragging;
}

- (BOOL)isShowGridlinesWhenIdle {
    return _frameView.isShowGridlinesWhenIdle;
}

- (BOOL)isShowGridlinesWhenDragging {
    return _frameView.isShowGridlinesWhenDragging;
}

- (NSUInteger)gridCount {
    return _frameView.gridCount;
}

- (UIImage *)maskImage {
    return _frameView.maskImage;
}

- (BOOL)isArbitrarilyMask {
    return _frameView.isArbitrarilyMask;
}

#pragma mark - init

+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure *)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    return [[self alloc] initWithConfigure:configure imageresizerIsCanRecovery:imageresizerIsCanRecovery imageresizerIsPrepareToScale:imageresizerIsPrepareToScale];
}

- (instancetype)initWithConfigure:(JPImageresizerConfigure *)configure
        imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
     imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    
    CGRect frame = configure.viewFrame;
    NSAssert((frame.size.width != 0 && frame.size.height != 0), @"must have width and height.");
    
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = UIColor.clearColor;
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.layer.backgroundColor = configure.bgColor.CGColor;
        [self addSubview:_containerView];
        
        _contentInsets = configure.contentInsets;
        
        CGFloat contentWidth = (self.bounds.size.width - _contentInsets.left - _contentInsets.right);
        CGFloat contentHeight = (self.bounds.size.height - _contentInsets.top - _contentInsets.bottom);
        CGSize baseContentMaxSize = CGSizeMake(contentWidth, contentHeight);
        
        self.allDirections = [@[@(JPImageresizerVerticalUpDirection),
                                @(JPImageresizerHorizontalLeftDirection),
                                @(JPImageresizerVerticalDownDirection),
                                @(JPImageresizerHorizontalRightDirection)] mutableCopy];
        self.isClockwiseRotation = configure.isClockwiseRotation;
        
        self.animationCurve = configure.animationCurve;
        
        _objWhScale = 1;
        _isLoopPlaybackGIF = configure.isLoopPlaybackGIF;
        
        BOOL isVideo = NO;
        if (configure.image) {
            [self setImage:configure.image animated:NO];
        } else if (configure.imageData) {
            [self setImageData:configure.imageData animated:NO];
        } else {
            isVideo = YES;
            
            AVURLAsset *videoAsset;
            if (configure.videoURL) {
                videoAsset = [AVURLAsset assetWithURL:configure.videoURL];
            } else if (configure.videoAsset) {
                videoAsset = configure.videoAsset;
            }
            
            NSAssert(videoAsset != nil, @"resizeObj cannot be nil.");
            
            if ([videoAsset statusOfValueForKey:@"duration" error:nil] != AVKeyValueStatusLoaded ||
                [videoAsset statusOfValueForKey:@"tracks" error:nil] != AVKeyValueStatusLoaded) {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            
            AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (videoTrack) {
                if (CGAffineTransformEqualToTransform(videoTrack.preferredTransform, CGAffineTransformIdentity)) {
                    [self __createVideoObj:videoAsset isFixedOrientation:NO animated:NO];
                } else {
                    [self __exportFixOrientationVideo:videoAsset
                                             animated:YES
                                        startFixBlock:configure.startFixBlock
                                     fixProgressBlock:configure.fixProgressBlock
                                     fixCompleteBlock:configure.fixCompleteBlock];
                }
            }
        }
        
        [self __setupScrollViewWithBaseContentMaxSize:baseContentMaxSize maxZoomScale:configure.maximumZoomScale];
        [self __setupImageView];
        [self __updateImageViewFrame];
        [self __updateImageViewImage:isVideo];
        
        if (_playerView) {
            _playerView.frame = _imageView.bounds;
            [_imageView addSubview:_playerView];
        }
        
        JPImageresizerFrameView *frameView =
        [[JPImageresizerFrameView alloc] initWithFrame:_scrollView.frame
                                    baseContentMaxSize:baseContentMaxSize
                                             frameType:configure.frameType
                                        animationCurve:configure.animationCurve
                                            blurEffect:configure.blurEffect
                                               bgColor:configure.bgColor
                                             maskAlpha:configure.maskAlpha
                                           strokeColor:configure.strokeColor
                                         resizeWHScale:configure.resizeWHScale
                                  isArbitrarilyInitial:configure.isArbitrarilyInitial
                                            scrollView:_scrollView
                                             imageView:_imageView
                                           borderImage:configure.borderImage
                                  borderImageRectInset:configure.borderImageRectInset
                                         isRoundResize:configure.isRoundResize
                                         isShowMidDots:configure.isShowMidDots
                                    isBlurWhenDragging:configure.isBlurWhenDragging
                               isShowGridlinesWhenIdle:configure.isShowGridlinesWhenIdle
                           isShowGridlinesWhenDragging:configure.isShowGridlinesWhenDragging
                                             gridCount:configure.gridCount
                                             maskImage:configure.maskImage
                                     isArbitrarilyMask:configure.isArbitrarilyMask
                             imageresizerIsCanRecovery:imageresizerIsCanRecovery
                          imageresizerIsPrepareToScale:imageresizerIsPrepareToScale];
        
        __weak typeof(self) wSelf = self;
        
        frameView.contentWhScale = ^CGFloat{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return 1;
            return sSelf->_objWhScale;
        };
        
        frameView.isVerticalityMirror = ^BOOL{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return NO;
            return sSelf.verticalityMirror;
        };
        
        frameView.isHorizontalMirror = ^BOOL{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return NO;
            return sSelf.horizontalMirror;
        };
        
        frameView.slider = _slider;
        frameView.playerView = _playerView;
        
        [_containerView addSubview:frameView];
        _frameView = frameView;
        
        self.edgeLineIsEnabled = configure.edgeLineIsEnabled;
    }
    return self;
}

- (void)dealloc {
    [self __removeProgressTimer];
}

#pragma mark - override method

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _containerView.frame = (CGRect){CGPointZero, frame.size};
}

#pragma mark - private method

- (void)__setupScrollViewWithBaseContentMaxSize:(CGSize)baseContentMaxSize maxZoomScale:(CGFloat)maxZoomScale {
    CGFloat w; // = hypot(self.bounds.size.width, self.bounds.size.height);
    CGFloat h;
    if (self.bounds.size.height > self.bounds.size.width) {
        h = self.bounds.size.height * 2;
        w = h;
    } else {
        w = self.bounds.size.width * 2;
        h = w;
    }
    CGFloat x = (baseContentMaxSize.width - w) * 0.5 + _contentInsets.left;
    CGFloat y = (baseContentMaxSize.height - h) * 0.5 + _contentInsets.top;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(x, y, w, h);
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = maxZoomScale > 1.0 ? maxZoomScale : 1.0;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.clipsToBounds = NO;
    scrollView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [_containerView addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)__setupImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [_scrollView addSubview:imageView];
    _imageView = imageView;
}

- (void)__updateImageViewFrame {
    CGFloat maxWidth = self.frame.size.width - _contentInsets.left - _contentInsets.right;
    CGFloat maxHeight = self.frame.size.height - _contentInsets.top - _contentInsets.bottom;
    CGFloat imgViewW = maxWidth;
    CGFloat imgViewH = imgViewW / _objWhScale;
    if (imgViewH > maxHeight) {
        imgViewH = maxHeight;
        imgViewW = imgViewH * _objWhScale;
    }
    CGRect imageViewBounds = CGRectMake(0, 0, imgViewW, imgViewH);
    self.imageView.bounds = imageViewBounds;
    self.playerView.frame = imageViewBounds;
    
    self.scrollView.layer.transform = CATransform3DIdentity;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    self.imageView.frame = imageViewBounds;
    self.scrollView.contentSize = imageViewBounds.size;
    
    CGFloat horInset = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5;
    CGFloat verInset = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5;
    self.scrollView.contentInset = UIEdgeInsetsMake(verInset, horInset, verInset, horInset);
    self.scrollView.contentOffset = CGPointMake(-horInset, -verInset);
}

- (void)__updateSubviewLayouts:(NSTimeInterval)duration {
    if (self.horizontalMirror) [self setHorizontalMirror:NO animated:NO];
    if (self.verticalityMirror) [self setVerticalityMirror:NO animated:NO];
    self.directionIndex = 0;
    [self __updateImageViewFrame];
    [self.frameView updateImageOriginFrameWithDuration:duration];
}

- (void)__changeMirror:(BOOL)isHorizontalMirror animated:(BOOL)isAnimated {
    CATransform3D transform = self.containerView.layer.transform;
    CGFloat diffValue;
    if (isHorizontalMirror) {
        transform = CATransform3DRotate(transform, (_horizontalMirror ? -M_PI : M_PI), 1, 0, 0);
        diffValue = _horizontalMirror ? _contentInsets.bottom : _contentInsets.top;
    } else {
        transform = CATransform3DRotate(transform, (_verticalityMirror ? -M_PI : M_PI), 0, 1, 0);
        diffValue = _verticalityMirror ? _contentInsets.right : _contentInsets.left;
    }
    if (isAnimated) transform.m34 = 1.0 / 1200.0;
    
    CGRect afterFrame;
    NSTimeInterval delay = [self.frameView willMirror:isHorizontalMirror diffValue:diffValue afterFrame:&afterFrame animated:isAnimated];
    
    __weak typeof(self) wSelf = self;
    void (^animateBlock)(void) = ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        sSelf.containerView.layer.transform = transform;
        sSelf.scrollView.frame = sSelf.frameView.frame = afterFrame;
    };
    
    if (isAnimated) {
        // 做3d旋转时会遮盖住上层的控件，设置为-500即可
        self.containerView.layer.zPosition = -500;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.45 delay:0 options:self->_animationOption animations:animateBlock completion:^(BOOL finished) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                self.containerView.layer.zPosition = 0;
                CATransform3D transform = self.containerView.layer.transform;
                transform.m34 = 0;
                self.containerView.layer.transform = transform;
                [CATransaction commit];
                [self.frameView mirrorDone];
            }];
        });
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        animateBlock();
        [CATransaction commit];
        [self.frameView mirrorDone];
    }
}

- (void)__recovery:(NSTimeInterval)delay isUpdateMaskImage:(BOOL)isUpdateMaskImage {
    self.directionIndex = 0;
    
    _horizontalMirror = NO;
    _verticalityMirror = NO;
    
    CGFloat x = (self.baseContentMaxSize.width - self.scrollView.bounds.size.width) * 0.5 + _contentInsets.left;
    CGFloat y = (self.baseContentMaxSize.height - self.scrollView.bounds.size.height) * 0.5 + _contentInsets.top;
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = x;
    frame.origin.y = y;
    
    // 做3d旋转时会遮盖住上层的控件，设置为-500即可
    self.containerView.layer.zPosition = -500;
    NSTimeInterval duration = 0.45;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration delay:0 options:self->_animationOption animations:^{
            
            self.containerView.layer.transform = CATransform3DIdentity;
            self.scrollView.layer.transform = CATransform3DIdentity;
            self.frameView.layer.transform = CATransform3DIdentity;
            
            self.scrollView.frame = frame;
            self.frameView.frame = frame;
            
            [self.frameView recoveryWithDuration:duration];
            
        } completion:^(BOOL finished) {
            [self.frameView recoveryDone:isUpdateMaskImage];
            self.containerView.layer.zPosition = 0;
        }];
    });
}

- (void)__updateImageViewImage:(BOOL)isVideo {
    if (isVideo) {
        _imageView.image = nil;
    } else {
        if (_isGIF && !_isLoopPlaybackGIF && _image.images) {
            _imageView.image = nil;
            _imageView.image = _image.images.firstObject;
        } else {
            _imageView.image = _image;
        }
    }
}

- (void)__updateImageView:(BOOL)isVideo animated:(BOOL)isAnimated {
    if (!self.superview) {
        if (isVideo) {
            [_playerView removeFromSuperview];
            _playerView = [[JPPlayerView alloc] initWithVideoObj:_videoObj];
            if (_imageView) {
                _playerView.frame = _imageView.bounds;
                [_imageView addSubview:_playerView];
            }
            if (_frameView) _frameView.playerView = _playerView;
            [self __removeImage];
        } else {
            if (_imageView) [self __updateImageViewImage:NO];
            [self __removeVideoObj];
        }
        if (_slider) {
            _slider.alpha = 1;
            [self addSubview:_slider];
            if (_frameView) {
                CGRect sliderFrame = [_frameView convertRect:_frameView.imageresizerFrame toView:self];
                [_slider setImageresizerFrame:sliderFrame isRoundResize:_frameView.isRoundResizing];
                _frameView.slider = _slider;
            }
        }
        return;
    }
    
    BOOL isGIF = _isGIF;
    BOOL isLoopPlaybackGIF = _isLoopPlaybackGIF;
    if (isAnimated) {
        self.userInteractionEnabled = NO;
        NSTimeInterval duration1 = 0.18;
        NSTimeInterval duration2 = 0.35;
        UIViewAnimationOptions options = _animationOption;
        if ((isVideo && _image != nil) ||
            (!isVideo && _videoObj != nil)) {
            
            if (self.slider && !self.slider.superview) {
                CGRect sliderFrame = [self.frameView convertRect:self.frameView.imageresizerFrame toView:self];
                [self.slider setImageresizerFrame:sliderFrame isRoundResize:self.frameView.isRoundResizing];
                self.slider.alpha = 0;
                [self addSubview:self.slider];
            }
            
            if (isVideo) {
                [self.playerView removeFromSuperview];
                JPPlayerView *playerView = [[JPPlayerView alloc] initWithVideoObj:_videoObj];
                playerView.frame = self.imageView.bounds;
                playerView.alpha = 0;
                [self.imageView addSubview:playerView];
                self.playerView = playerView;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:duration1 delay:0 options:options animations:^{
                        self.playerView.alpha = 1;
                        self.slider.alpha = 1;
                    } completion:^(BOOL finished) {
                        [self __removeImage];
                        self.frameView.playerView = self.playerView;
                        self.frameView.slider = self.slider;
                        [UIView animateWithDuration:duration2 delay:0 options:options animations:^{
                            [self __updateSubviewLayouts:duration2];
                        } completion:^(BOOL finished) {
                            self.userInteractionEnabled = YES;
                        }];
                    }];
                });
            } else {
                self.frameView.playerView = nil;
                self.frameView.slider = (isGIF && !isLoopPlaybackGIF) ? self.slider : nil;
                [self __updateImageViewImage:NO];
                [UIView animateWithDuration:duration1 delay:0 options:options animations:^{
                    self.playerView.alpha = 0;
                    self.slider.alpha = (isGIF && !isLoopPlaybackGIF) ? 1 : 0;
                } completion:^(BOOL finished) {
                    [self __removeVideoObj];
                    [UIView animateWithDuration:duration2 delay:0 options:options animations:^{
                        [self __updateSubviewLayouts:duration2];
                    } completion:^(BOOL finished) {
                        self.userInteractionEnabled = YES;
                    }];
                }];
            }
            return;
        }
        
        if (!isVideo) {
            if (isGIF && !isLoopPlaybackGIF) {
                if (self.slider && !self.slider.superview) {
                    CGRect sliderFrame = [self.frameView convertRect:self.frameView.imageresizerFrame toView:self];
                    [self.slider setImageresizerFrame:sliderFrame isRoundResize:self.frameView.isRoundResizing];
                    self.slider.alpha = 0;
                    [self addSubview:self.slider];
                }
                self.frameView.slider = self.slider;
            } else {
                self.frameView.slider = nil;
            }
            [UIView transitionWithView:self.imageView duration:duration1 options:(options | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
                [self __updateImageViewImage:NO];
                self.slider.alpha = (isGIF && !isLoopPlaybackGIF) ? 1 : 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration2 delay:0 options:self->_animationOption animations:^{
                    [self __updateSubviewLayouts:duration2];
                } completion:^(BOOL finished) {
                    [self __removeVideoObj];
                    self.userInteractionEnabled = YES;
                }];
            }];
        } else {
            JPPlayerView *playerView = [[JPPlayerView alloc] initWithVideoObj:_videoObj];
            playerView.frame = self.imageView.bounds;
            playerView.alpha = 0;
            [self.imageView addSubview:playerView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:duration1 delay:0 options:options animations:^{
                    playerView.alpha = 1;
                } completion:^(BOOL finished) {
                    [self.playerView removeFromSuperview];
                    self.playerView = playerView;
                    self.frameView.playerView = playerView;
                    [UIView animateWithDuration:duration2 delay:0 options:options animations:^{
                        [self __updateSubviewLayouts:duration2];
                    } completion:^(BOOL finished) {
                        [self __removeImage];
                        self.userInteractionEnabled = YES;
                    }];
                }];
            });
        }
    } else {
        if (!isVideo) {
            [self __removeVideoObj];
            [self __updateImageViewImage:NO];
        } else {
            [self __removeImage];
            
            [self.playerView removeFromSuperview];
            JPPlayerView *playerView = [[JPPlayerView alloc] initWithVideoObj:_videoObj];
            playerView.frame = self.imageView.bounds;
            [self.imageView addSubview:playerView];
            self.playerView = playerView;
            self.frameView.playerView = playerView;
        }
        if (_slider) {
            self.frameView.slider = self.slider;
            self.slider.alpha = 1;
            [self addSubview:self.slider];
        }
        [self __updateSubviewLayouts:0];
    }
}

- (void)__removeImage {
    _image = nil;
    _imageData = nil;
    _imageView.image = nil;
    _isGIF = NO;
}

- (void)__removeVideoObj {
    _videoObj = nil;
    
    _frameView.playerView = nil;
    [_playerView removeFromSuperview];
    _playerView = nil;
    
    if (!_isGIF || _isLoopPlaybackGIF) {
        _frameView.slider = nil;
        [_slider removeFromSuperview];
        _slider = nil;
    }
}

- (void)__setupSlider:(BOOL)isVideo {
    float seconds = isVideo ? _videoObj.seconds : _image.duration;
    if (_slider) {
        [_slider resetSeconds:seconds second:0];
    } else {
        _slider = [JPImageresizerSlider imageresizerSlider:seconds second:0];
    }
    __weak typeof(self) wSelf = self;
    if (isVideo) {
        _slider.sliderDragingBlock = ^(float second, float totalSecond) {
            if (!wSelf) return;
            __strong typeof(wSelf) sSelf = wSelf;
            CMTime time = CMTimeMakeWithSeconds(second, sSelf.videoObj.timescale);
            CMTime toleranceTime = sSelf.videoObj.toleranceTime;
            [sSelf.playerView.player seekToTime:time toleranceBefore:toleranceTime toleranceAfter:toleranceTime];
        };
    } else {
        _slider.sliderDragingBlock = ^(float second, float totalSecond) {
            if (!wSelf) return;
            __strong typeof(wSelf) sSelf = wSelf;
            NSInteger maxIndex = sSelf.image.images.count - 1;
            CGFloat floatIndex = (CGFloat)maxIndex * (second / totalSecond);
            NSInteger index = (NSInteger)(floatIndex + 0.5);
            if (index < 0) index = 0;
            if (index > maxIndex) index = maxIndex;
            sSelf.imageView.image = sSelf.image.images[index];
        };
    }
}

- (void)__createVideoObj:(AVURLAsset *)asset isFixedOrientation:(BOOL)isFixedOrientation animated:(BOOL)isAnimated {
    JPImageresizerVideoObject *videoObj = [[JPImageresizerVideoObject alloc] initWithAsset:asset isFixedOrientation:isFixedOrientation];
    _videoObj = videoObj;
    _objWhScale = videoObj.videoSize.width / videoObj.videoSize.height;
    _isGIF = NO;
    [self __setupSlider:YES];
    [self __updateImageView:YES animated:isAnimated];
}

- (void)__exportFixOrientationVideo:(AVURLAsset *)videoAsset
                           animated:(BOOL)isAnimated
                      startFixBlock:(void(^)(void))startFixBlock
                   fixProgressBlock:(JPVideoExportProgressBlock)fixProgressBlock
                   fixCompleteBlock:(JPVideoFixOrientationCompleteBlock)fixCompleteBlock {
    !startFixBlock ? : startFixBlock();
    self.userInteractionEnabled = NO;
    self.frameView.isPrepareToScale = YES;
    __weak typeof(self) wSelf = self;
    [JPImageresizerTool exportFixOrientationVideoWithAsset:videoAsset exportSessionBlock:^(AVAssetExportSession *exportSession) {
        if (!wSelf) return;
        __strong typeof(wSelf) sSelf = wSelf;
        [sSelf __addProgressTimer:fixProgressBlock exporterSession:exportSession];
    } errorBlock:^(NSURL *cacheURL, JPCropErrorReason reason) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        sSelf.userInteractionEnabled = YES;
        sSelf.frameView.isPrepareToScale = NO;
        !fixCompleteBlock ? : fixCompleteBlock(nil, reason == JPCEReason_VideoExportCancelled);
    } completeBlock:^(NSURL *cacheURL) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf __createVideoObj:[AVURLAsset assetWithURL:cacheURL] isFixedOrientation:YES animated:isAnimated];
        sSelf.userInteractionEnabled = YES;
        sSelf.frameView.isPrepareToScale = NO;
        !fixCompleteBlock ? : fixCompleteBlock(cacheURL, NO);
    }];
}

#pragma mark 监听视频导出进度的定时器

- (void)__addProgressTimer:(JPVideoExportProgressBlock)progressBlock exporterSession:(AVAssetExportSession *)exporterSession {
    [self __removeProgressTimer];
    if (progressBlock == nil || exporterSession == nil) return;
    self.exporterSession = exporterSession;
    self.progressBlock = progressBlock;
    self.progressTimer = [NSTimer timerWithTimeInterval:0.02 target:[JPImageresizerProxy proxyWithTarget:self] selector:@selector(__progressTimerHandle) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)__removeProgressTimer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    self.progressBlock = nil;
    self.exporterSession = nil;
}

- (void)__progressTimerHandle {
    if (self.progressBlock && self.exporterSession) self.progressBlock(self.exporterSession.progress);
}

#pragma mark - puild method

#pragma mark 更换裁剪元素
- (void)setImage:(UIImage *)image animated:(BOOL)isAnimated {
    NSAssert(image != nil, @"image cannot be nil.");
    if (image) {
        _imageData = nil;
        _image = image;
        _objWhScale = _image.size.width / _image.size.height;
        _isGIF = image.images.count > 1;
        if (_isGIF && !_isLoopPlaybackGIF) [self __setupSlider:NO];
        [self __updateImageView:NO animated:isAnimated];
    }
}

- (void)setImageData:(NSData *)imageData animated:(BOOL)isAnimated {
    NSAssert(imageData != nil, @"imageData cannot be nil.");
    if (imageData) {
        _imageData = imageData;
        _image = [UIImage imageWithData:imageData];
        _objWhScale = _image.size.width / _image.size.height;
        _isGIF = [JPImageresizerTool isGIFData:imageData];
        if (_isGIF) {
            if (!_isLoopPlaybackGIF) {
                [self __setupSlider:NO];
                self.slider.userInteractionEnabled = NO;
            }
            __weak typeof(self) wSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [JPImageresizerTool decodeGIFData:imageData];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    __strong typeof(wSelf) sSelf = wSelf;
                    if (!sSelf || sSelf->_imageData != imageData) {
                        sSelf.slider.userInteractionEnabled = YES;
                        return;
                    }
                    sSelf->_image = image;
                    sSelf->_objWhScale = image.size.width / image.size.height;
                    [sSelf __updateImageViewImage:NO];
                    if (sSelf.slider) {
                        [sSelf.slider resetSeconds:image.duration second:0];
                        sSelf.slider.userInteractionEnabled = YES;
                    }
                });
            });
        }
        [self __updateImageView:NO animated:isAnimated];
    }
}

- (void)setVideoURL:(NSURL *)videoURL
           animated:(BOOL)isAnimated
      startFixBlock:(void(^)(void))startFixBlock
   fixProgressBlock:(JPVideoExportProgressBlock)fixProgressBlock
   fixCompleteBlock:(JPVideoFixOrientationCompleteBlock)fixCompleteBlock {
    NSAssert(videoURL != nil, @"videoURL cannot be nil.");
    if (videoURL) {
        [self setVideoAsset:[AVURLAsset assetWithURL:videoURL]
                   animated:isAnimated
              startFixBlock:startFixBlock
           fixProgressBlock:fixProgressBlock
           fixCompleteBlock:fixCompleteBlock];
    }
}

- (void)setVideoAsset:(AVURLAsset *)videoAsset
             animated:(BOOL)isAnimated
        startFixBlock:(void(^)(void))startFixBlock
     fixProgressBlock:(JPVideoExportProgressBlock)fixProgressBlock
     fixCompleteBlock:(JPVideoFixOrientationCompleteBlock)fixCompleteBlock {
    NSAssert(videoAsset != nil, @"videoAsset cannot be nil.");
    if (videoAsset) {
        if ([videoAsset statusOfValueForKey:@"duration" error:nil] != AVKeyValueStatusLoaded ||
            [videoAsset statusOfValueForKey:@"tracks" error:nil] != AVKeyValueStatusLoaded) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        if (videoTrack) {
            if (CGAffineTransformEqualToTransform(videoTrack.preferredTransform, CGAffineTransformIdentity)) {
                [self __createVideoObj:videoAsset isFixedOrientation:NO animated:isAnimated];
            } else {
                [self __exportFixOrientationVideo:videoAsset
                                         animated:isAnimated
                                    startFixBlock:startFixBlock
                                 fixProgressBlock:fixProgressBlock
                                 fixCompleteBlock:fixCompleteBlock];
            }
        }
    }
}

#pragma mark 设置颜色
- (void)setupStrokeColor:(UIColor *)strokeColor
              blurEffect:(UIBlurEffect *)blurEffect
                 bgColor:(UIColor *)bgColor
               maskAlpha:(CGFloat)maskAlpha
                animated:(BOOL)isAnimated {
    [self.frameView setupStrokeColor:strokeColor
                          blurEffect:blurEffect
                             bgColor:bgColor
                           maskAlpha:maskAlpha
                            animated:isAnimated];
}

#pragma mark 设置裁剪宽高比
- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪宽高比暂不可设置，此时应该将设置按钮设为不可点或隐藏");
        return;
    }
    [self.frameView setResizeWHScale:resizeWHScale isToBeArbitrarily:isToBeArbitrarily animated:isAnimated];
}

- (void)roundResize:(BOOL)isAnimated {
    [self.frameView roundResize:isAnimated];
}

- (BOOL)isRoundResizing {
    return self.frameView.isRoundResizing;
}

#pragma mark 镜像翻转
- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_verticalityMirror == verticalityMirror) return;
    _verticalityMirror = verticalityMirror;
    [self __changeMirror:NO animated:isAnimated];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_horizontalMirror == horizontalMirror) return;
    _horizontalMirror = horizontalMirror;
    [self __changeMirror:YES animated:isAnimated];
}

#pragma mark 预览
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated {
    [self.frameView setIsPreview:isPreview animated:isAnimated];
    self.scrollView.userInteractionEnabled = !isPreview;
}

#pragma mark 旋转
- (void)rotation {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，旋转功能暂不可用，此时应该将旋转按钮设为不可点或隐藏");
        return;
    }
    
    BOOL isNormal = _verticalityMirror == _horizontalMirror;
    
    CGFloat angle = (self.isClockwiseRotation ? 1.0 : -1.0) * (isNormal ? 1.0 : -1.0) * M_PI_2;
    CATransform3D svTransform = CATransform3DRotate(self.scrollView.layer.transform, angle, 0, 0, 1);
    CATransform3D fvTransform = CATransform3DRotate(self.frameView.layer.transform, angle, 0, 0, 1);
    
    self.directionIndex += (isNormal ? 1 : -1);
    JPImageresizerRotationDirection direction = [self.allDirections[self.directionIndex] integerValue];
    
    NSTimeInterval delay = [self.frameView willRotationWithDirection:direction];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSTimeInterval duration = 0.3;
        [UIView animateWithDuration:duration delay:0 options:self->_animationOption animations:^{
            self.scrollView.layer.transform = svTransform;
            self.frameView.layer.transform = fvTransform;
            [self.frameView rotating:angle duration:duration];
        } completion:^(BOOL finished) {
            [self.frameView rotationDone];
        }];
    });
    
}

#pragma mark 重置
- (void)recoveryToRoundResize {
    if (!self.frameView.isCanRecovery) {
        JPIRLog(@"jp_tip: 已经是初始状态，不需要重置");
        return;
    }
    NSTimeInterval delay = [self.frameView willRecoveryToRoundResize:YES];
    [self __recovery:delay isUpdateMaskImage:NO];
}

- (void)recoveryByCurrentMaskImage {
    [self recoveryToMaskImage:self.maskImage];
}

- (void)recoveryToMaskImage:(UIImage *)maskImage {
    NSTimeInterval delay;
    BOOL isUpdateMaskImage = NO;
    if (maskImage == nil) {
        delay = [self.frameView willRecoveryToResizeWHScale:self.initialResizeWHScale isToBeArbitrarily:NO animated:YES];
    } else {
        isUpdateMaskImage = self.maskImage != maskImage;
        delay = [self.frameView willRecoveryToMaskImage:maskImage animated:YES];
    }
    [self __recovery:delay isUpdateMaskImage:isUpdateMaskImage];
}

- (void)recoveryByCurrentResizeWHScale {
    [self recoveryByCurrentResizeWHScale:NO];
}

- (void)recoveryByCurrentResizeWHScale:(BOOL)isToBeArbitrarily {
    if (!self.frameView.isCanRecovery) {
        JPIRLog(@"jp_tip: 已经是初始状态，不需要重置");
        return;
    }
    NSTimeInterval delay = [self.frameView willRecoveryToResizeWHScale:self.resizeWHScale isToBeArbitrarily:isToBeArbitrarily animated:YES];
    [self __recovery:delay isUpdateMaskImage:NO];
}

- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily {
    if (!self.frameView.isCanRecovery) {
        JPIRLog(@"jp_tip: 已经是初始状态，不需要重置");
        return;
    }
    NSTimeInterval delay = [self.frameView willRecoveryToResizeWHScale:self.initialResizeWHScale isToBeArbitrarily:isToBeArbitrarily animated:YES];
    [self __recovery:delay isUpdateMaskImage:NO];
}

- (void)recoveryToTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily {
    if (!self.frameView.isCanRecovery) {
        JPIRLog(@"jp_tip: 已经是初始状态，不需要重置");
        return;
    }
    NSTimeInterval delay = [self.frameView willRecoveryToResizeWHScale:targetResizeWHScale isToBeArbitrarily:isToBeArbitrarily animated:YES];
    [self __recovery:delay isUpdateMaskImage:NO];
}

- (void)updateFrame:(CGRect)frame contentInsets:(UIEdgeInsets)contentInsets duration:(NSTimeInterval)duration {
    if (CGSizeEqualToSize(self.bounds.size, frame.size)) {
        if (UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
            self.frame = frame;
            return;
        }
    }
    _contentInsets = contentInsets;
    [self.frameView superViewUpdateFrame:frame contentInsets:contentInsets duration:duration];
}

#pragma mark - 裁剪

#pragma mark 裁剪图片
// 原图尺寸裁剪图片
- (void)cropPictureWithCacheURL:(NSURL *)cacheURL
                     errorBlock:(JPCropErrorBlock)errorBlock
                  completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropPictureWithCompressScale:1
                              cacheURL:cacheURL
                            errorBlock:errorBlock
                         completeBlock:completeBlock];
}

// 自定义压缩比例裁剪图片
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                            cacheURL:(NSURL *)cacheURL
                     errorBlock:(JPCropErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (compressScale <= 0) {
        JPIRLog(@"jp_tip: 压缩比例不能小于或等于0");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (self.videoObj || self.isGIF) {
        JPIRLog(@"jp_tip: 当前裁剪元素非图片");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (self.imageData) {
        [JPImageresizerTool cropPictureWithImageData:self.imageData maskImage:self.frameView.maskImage configure:self.frameView.currentCropConfigure compressScale:compressScale cacheURL:cacheURL errorBlock:errorBlock completeBlock:completeBlock];
    } else {
        [JPImageresizerTool cropPictureWithImage:self.image maskImage:self.frameView.maskImage configure:self.frameView.currentCropConfigure compressScale:compressScale cacheURL:cacheURL errorBlock:errorBlock completeBlock:completeBlock];
    }
}

#pragma mark 裁剪GIF
- (void)cropGIFWithCacheURL:(NSURL *)cacheURL
                     errorBlock:(JPCropErrorBlock)errorBlock
              completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropGIFWithCompressScale:1
                    isReverseOrder:NO
                              rate:1
                          cacheURL:cacheURL
                        errorBlock:errorBlock
                     completeBlock:completeBlock];
}

- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPCropErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropGIFWithCompressScale:compressScale
                    isReverseOrder:NO
                              rate:1
                          cacheURL:cacheURL
                        errorBlock:errorBlock
                     completeBlock:completeBlock];
}

- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                  isReverseOrder:(BOOL)isReverseOrder
                            rate:(float)rate
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPCropErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (compressScale <= 0) {
        JPIRLog(@"jp_tip: 压缩比例不能小于或等于0");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (self.videoObj || !self.isGIF) {
        JPIRLog(@"jp_tip: 当前裁剪元素非GIF");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (self.imageData) {
        [JPImageresizerTool cropGIFWithGifData:self.imageData
                                isReverseOrder:isReverseOrder
                                          rate:rate
                                     maskImage:self.frameView.maskImage
                                     configure:self.frameView.currentCropConfigure
                                 compressScale:compressScale
                                      cacheURL:cacheURL
                                    errorBlock:errorBlock
                                 completeBlock:completeBlock];
    } else {
        [JPImageresizerTool cropGIFWithGifImage:self.image
                                 isReverseOrder:isReverseOrder
                                           rate:rate
                                      maskImage:self.frameView.maskImage
                                      configure:self.frameView.currentCropConfigure
                                  compressScale:compressScale
                                       cacheURL:cacheURL
                                     errorBlock:errorBlock
                                  completeBlock:completeBlock];
    }
}

- (void)cropGIFCurrentIndexWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPCropErrorBlock)errorBlock
                          completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropGIFCurrentIndexWithCompressScale:1
                                      cacheURL:cacheURL
                                    errorBlock:errorBlock
                                 completeBlock:completeBlock];
}

- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                     cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPCropErrorBlock)errorBlock
                               completeBlock:(JPCropPictureDoneBlock)completeBlock {
    NSUInteger index = 0;
    if (self.isLoopPlaybackGIF == NO) {
        NSInteger maxIndex = self.image.images.count - 1;
        CGFloat floatIndex = (CGFloat)maxIndex * (self.slider.second / self.slider.seconds);
        index = (NSInteger)(floatIndex + 0.5);
        if (index < 0) index = 0;
        if (index > maxIndex) index = maxIndex;
    }
    [self cropGIFWithIndex:index
             compressScale:compressScale
                  cacheURL:cacheURL
                errorBlock:errorBlock
             completeBlock:completeBlock];
}

- (void)cropGIFWithIndex:(NSUInteger)index
            compressScale:(CGFloat)compressScale
                cacheURL:(NSURL *)cacheURL
              errorBlock:(JPCropErrorBlock)errorBlock
           completeBlock:(JPCropPictureDoneBlock)completeBlock {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (compressScale <= 0) {
        JPIRLog(@"jp_tip: 压缩比例不能小于或等于0");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (self.videoObj || !self.isGIF) {
        JPIRLog(@"jp_tip: 当前裁剪元素非GIF");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (self.imageData) {
        [JPImageresizerTool cropGIFWithGifData:self.imageData
                                         index:index
                                     maskImage:self.frameView.maskImage
                                     configure:self.frameView.currentCropConfigure
                                 compressScale:compressScale
                                      cacheURL:cacheURL
                                    errorBlock:errorBlock
                                 completeBlock:completeBlock];
    } else {
        [JPImageresizerTool cropGIFWithGifImage:self.image
                                          index:index maskImage:self.frameView.maskImage
                                      configure:self.frameView.currentCropConfigure
                                  compressScale:compressScale
                                       cacheURL:cacheURL
                                     errorBlock:errorBlock
                                  completeBlock:completeBlock];
    }
}

#pragma mark 裁剪视频
// 原图尺寸裁剪视频当前帧画面
- (void)cropVideoCurrentFrameWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPCropErrorBlock)errorBlock
                             completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropVideoOneFrameWithSecond:self.slider.second
                        compressScale:1
                             cacheURL:cacheURL
                           errorBlock:errorBlock
                        completeBlock:completeBlock];
}

// 自定义压缩比例裁剪视频当前帧画面
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                     cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPCropErrorBlock)errorBlock
                                 completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropVideoOneFrameWithSecond:self.slider.second
                        compressScale:compressScale
                             cacheURL:cacheURL
                           errorBlock:errorBlock
                        completeBlock:completeBlock];
}

// 自定义压缩比例裁剪视频指定帧画面
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                           cacheURL:(NSURL *)cacheURL
                         errorBlock:(JPCropErrorBlock)errorBlock
                      completeBlock:(JPCropPictureDoneBlock)completeBlock {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (compressScale <= 0) {
        JPIRLog(@"jp_tip: 压缩比例不能小于或等于0");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (!self.videoObj) {
        JPIRLog(@"jp_tip: 当前裁剪元素非视频");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (second < 0) {
        second = 0;
    } else if (second > self.slider.seconds) {
        second = self.slider.seconds;
    }
    [JPImageresizerTool cropVideoWithAsset:self.videoObj.asset
                                      time:CMTimeMakeWithSeconds(second, self.videoObj.timescale)
                               maximumSize:self.videoObj.videoSize
                                 maskImage:self.frameView.maskImage
                                 configure:self.frameView.currentCropConfigure
                             compressScale:compressScale
                                  cacheURL:cacheURL
                                errorBlock:errorBlock
                             completeBlock:completeBlock];
}

- (void)cropVideoToGIFFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                           cacheURL:(NSURL *)cacheURL
                                         errorBlock:(JPCropErrorBlock)errorBlock
                                      completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropVideoToGIFFromStartSecond:self.slider.second
                               duration:duration
                                    fps:10
                                   rate:1
                            maximumSize:CGSizeMake(500, 500)
                               cacheURL:cacheURL
                             errorBlock:errorBlock
                          completeBlock:completeBlock];
}
- (void)cropVideoToGIFFromStartSecond:(NSTimeInterval)startSecond
                             duration:(NSTimeInterval)duration
                                  fps:(float)fps
                                 rate:(float)rate
                          maximumSize:(CGSize)maximumSize
                             cacheURL:(NSURL *)cacheURL
                           errorBlock:(JPCropErrorBlock)errorBlock
                        completeBlock:(JPCropPictureDoneBlock)completeBlock {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (!self.videoObj) {
        JPIRLog(@"jp_tip: 当前裁剪元素非视频");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    if (startSecond < 0) {
        startSecond = 0;
    } else if (startSecond > self.slider.seconds) {
        JPIRLog(@"jp_tip: 请设置正确的初始时间");
        !completeBlock ? : completeBlock(nil, nil, NO);
        return;
    }
    [JPImageresizerTool cropVideoToGIFWithAsset:self.videoObj.asset
                                    startSecond:startSecond
                                       duration:duration
                                            fps:fps
                                           rate:rate
                                    maximumSize:maximumSize
                                      maskImage:self.frameView.maskImage
                                      configure:self.frameView.currentCropConfigure
                                       cacheURL:cacheURL
                                     errorBlock:errorBlock
                                  completeBlock:completeBlock];
}

// 裁剪整段视频
- (void)cropVideoWithCacheURL:(NSURL *)cacheURL
                progressBlock:(JPVideoExportProgressBlock)progressBlock
                   errorBlock:(JPCropErrorBlock)errorBlock
                completeBlock:(JPCropVideoCompleteBlock)completeBlock {
    [self cropVideoWithPresetName:AVAssetExportPresetHighestQuality
                         cacheURL:cacheURL
                    progressBlock:progressBlock
                       errorBlock:errorBlock
                    completeBlock:completeBlock];
}

// 裁剪整段视频
- (void)cropVideoWithPresetName:(NSString *)presetName
                       cacheURL:(NSURL *)cacheURL
                 progressBlock:(JPVideoExportProgressBlock)progressBlock
                    errorBlock:(JPCropErrorBlock)errorBlock
                 completeBlock:(JPCropVideoCompleteBlock)completeBlock {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !completeBlock ? : completeBlock(nil);
        return;
    }
    if (!self.videoObj) {
        JPIRLog(@"jp_tip: 当前裁剪内容非视频");
        !completeBlock ? : completeBlock(nil);
        return;
    }
    __weak typeof(self) wSelf = self;
    [JPImageresizerTool cropVideoWithAsset:self.videoObj.asset
                                 timeRange:self.videoObj.timeRange
                             frameDuration:self.videoObj.frameDuration
                                presetName:presetName
                                 configure:self.frameView.currentCropConfigure
                                  cacheURL:cacheURL
                        exportSessionBlock:^(AVAssetExportSession *exportSession) {
        if (!wSelf) return;
        __strong typeof(wSelf) sSelf = wSelf;
        [sSelf __addProgressTimer:progressBlock exporterSession:exportSession];
    } errorBlock:^(NSURL *cacheURL, JPCropErrorReason reason) {
        if (wSelf) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf __removeProgressTimer];
        }
        !errorBlock ? : errorBlock(cacheURL, reason);
    } completeBlock:^(NSURL *cacheURL) {
        if (wSelf) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf __removeProgressTimer];
        }
        !completeBlock ? : completeBlock(cacheURL);
    }];
}

// 取消视频导出
- (void)videoCancelExport {
    [self.exporterSession cancelExport];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.frameView endedImageresizer];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self.frameView endedImageresizer];
}

@end
