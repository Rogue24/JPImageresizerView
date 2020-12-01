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
@property (nonatomic, strong) NSMutableArray<NSNumber *> *allDirections;
@property (nonatomic, assign) NSInteger directionIndex;
@property (nonatomic, strong) JPImageresizerVideoObject *videoObj;
@property (nonatomic, strong) JPPlayerView *playerView;
@property (nonatomic, strong) JPImageresizerSlider *slider;
@property (nonatomic, weak) AVAssetExportSession *exporterSession;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, copy) JPExportVideoProgressBlock progressBlock;
@property (nonatomic, strong) JPImageresizerConfigure *configure;
@end

@implementation JPImageresizerView
{
    UIEdgeInsets _contentInsets;
    UIViewAnimationOptions _animationOption;
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
        
        self.configure = configure;
        
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
        
        _resizeObjWhScale = 1;
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
                    [self __fixOrientationVideo:videoAsset
                                       animated:YES
                                  fixErrorBlock:configure.fixErrorBlock
                                  fixStartBlock:configure.fixStartBlock
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
        
        __weak typeof(self) wSelf = self;
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
                                         isRoundResize:configure.isRoundResize
                                             maskImage:configure.maskImage
                                         isArbitrarily:configure.isArbitrarily
                                            scrollView:_scrollView
                                             imageView:_imageView
                                           borderImage:configure.borderImage
                                  borderImageRectInset:configure.borderImageRectInset
                                         isShowMidDots:configure.isShowMidDots
                                    isBlurWhenDragging:configure.isBlurWhenDragging
                               isShowGridlinesWhenIdle:configure.isShowGridlinesWhenIdle
                           isShowGridlinesWhenDragging:configure.isShowGridlinesWhenDragging
                                             gridCount:configure.gridCount
                             imageresizerIsCanRecovery:imageresizerIsCanRecovery
                          imageresizerIsPrepareToScale:imageresizerIsPrepareToScale
                                   isVerticalityMirror:^BOOL{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return NO;
            return sSelf.verticalityMirror;
        } isHorizontalMirror:^BOOL{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return NO;
            return sSelf.horizontalMirror;
        } resizeObjWhScale:^CGFloat{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return 1;
            return sSelf->_resizeObjWhScale;
        }];
        
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

#pragma mark UI设置
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
    CGFloat imgViewH = imgViewW / _resizeObjWhScale;
    if (imgViewH > maxHeight) {
        imgViewH = maxHeight;
        imgViewW = imgViewH * _resizeObjWhScale;
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

#pragma mark 更换裁剪元素
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
                [_slider setImageresizerFrame:sliderFrame isRoundResize:_frameView.isRoundResize];
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
                [self.slider setImageresizerFrame:sliderFrame isRoundResize:self.frameView.isRoundResize];
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
                    [self.slider setImageresizerFrame:sliderFrame isRoundResize:self.frameView.isRoundResize];
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
    _resizeObjWhScale = videoObj.videoSize.width / videoObj.videoSize.height;
    _isGIF = NO;
    [self __setupSlider:YES];
    [self __updateImageView:YES animated:isAnimated];
}

#pragma mark 修正视频方向
- (void)__fixOrientationVideo:(AVURLAsset *)videoAsset
                     animated:(BOOL)isAnimated
                fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                fixStartBlock:(void(^)(void))fixStartBlock
             fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
             fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    self.userInteractionEnabled = NO;
    self.frameView.isPrepareToScale = YES;
    __weak typeof(self) wSelf = self;
    [JPImageresizerTool fixOrientationVideoWithAsset:videoAsset fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
        if (wSelf) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf __removeProgressTimer];
            sSelf.userInteractionEnabled = YES;
            sSelf.frameView.isPrepareToScale = NO;
        }
        !fixErrorBlock ? : fixErrorBlock(cacheURL, reason);
    } fixStartBlock:^(AVAssetExportSession *exportSession) {
        if (wSelf) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf __addProgressTimer:fixProgressBlock exporterSession:exportSession];
        }
        !fixStartBlock ? : fixStartBlock();
    } fixCompleteBlock:^(NSURL *cacheURL) {
        if (wSelf) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf __removeProgressTimer];
            [sSelf __createVideoObj:[AVURLAsset assetWithURL:cacheURL] isFixedOrientation:YES animated:isAnimated];
            sSelf.userInteractionEnabled = YES;
            sSelf.frameView.isPrepareToScale = NO;
        }
        !fixCompleteBlock ? : fixCompleteBlock(cacheURL);
    }];
}

#pragma mark 监听视频导出进度的定时器
- (void)__addProgressTimer:(JPExportVideoProgressBlock)progressBlock exporterSession:(AVAssetExportSession *)exporterSession {
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

#pragma mark - 裁剪元素相关
- (void)setImage:(UIImage *)image {
    [self setImage:image animated:YES];
}
- (void)setImage:(UIImage *)image animated:(BOOL)isAnimated {
    NSAssert(image != nil, @"image cannot be nil.");
    if (image) {
        _imageData = nil;
        _image = image;
        _resizeObjWhScale = _image.size.width / _image.size.height;
        _isGIF = image.images.count > 1;
        if (_isGIF && !_isLoopPlaybackGIF) [self __setupSlider:NO];
        [self __updateImageView:NO animated:isAnimated];
    }
}

- (void)setImageData:(NSData *)imageData {
    [self setImageData:imageData animated:YES];
}
- (void)setImageData:(NSData *)imageData animated:(BOOL)isAnimated {
    NSAssert(imageData != nil, @"imageData cannot be nil.");
    if (imageData) {
        _imageData = imageData;
        _image = [UIImage imageWithData:imageData];
        _resizeObjWhScale = _image.size.width / _image.size.height;
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
                    sSelf->_resizeObjWhScale = image.size.width / image.size.height;
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
      fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
      fixStartBlock:(void(^)(void))fixStartBlock
   fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
   fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    NSAssert(videoURL != nil, @"videoURL cannot be nil.");
    if (videoURL) {
        [self setVideoAsset:[AVURLAsset assetWithURL:videoURL]
                   animated:isAnimated
              fixErrorBlock:fixErrorBlock
              fixStartBlock:fixStartBlock
           fixProgressBlock:fixProgressBlock
           fixCompleteBlock:fixCompleteBlock];
    }
}
- (NSURL *)videoURL {
    return _videoObj.asset.URL;
}

- (void)setVideoAsset:(AVURLAsset *)videoAsset
             animated:(BOOL)isAnimated
        fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
        fixStartBlock:(void(^)(void))fixStartBlock
     fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
     fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
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
                [self __fixOrientationVideo:videoAsset
                                   animated:isAnimated
                              fixErrorBlock:fixErrorBlock
                              fixStartBlock:fixStartBlock
                           fixProgressBlock:fixProgressBlock
                           fixCompleteBlock:fixCompleteBlock];
            }
        }
    }
}
- (AVURLAsset *)videoAsset {
    return _videoObj.asset;
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
        [self.slider setImageresizerFrame:sliderFrame isRoundResize:_frameView.isRoundResize];
        self.slider.alpha = 0;
        [self addSubview:self.slider];
        [UIView animateWithDuration:0.2 animations:^{
            self.slider.alpha = 1;
        }];
        self.frameView.slider = self.slider;
    }
    [self __updateImageViewImage:NO];
}

#pragma mark - 裁剪宽高比相关
- (void)setInitialResizeWHScale:(CGFloat)initialResizeWHScale {
    self.frameView.initialResizeWHScale = initialResizeWHScale;
}
- (CGFloat)initialResizeWHScale {
    return _frameView.initialResizeWHScale;
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    [self setResizeWHScale:resizeWHScale isToBeArbitrarily:(resizeWHScale <= 0) animated:YES];
}
- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪宽高比暂不可设置，此时应该将设置按钮设为不可点或隐藏");
        return;
    }
    [self.frameView setResizeWHScale:resizeWHScale isToBeArbitrarily:isToBeArbitrarily animated:isAnimated];
}
- (CGFloat)resizeWHScale {
    CGFloat resizeWHScale = _frameView.resizeWHScale;
    if (resizeWHScale > 0) {
        if (_frameView.direction == JPImageresizerHorizontalLeftDirection ||
            _frameView.direction == JPImageresizerHorizontalRightDirection) {
            resizeWHScale = 1.0 / resizeWHScale;
        }
    }
    return resizeWHScale;
}

- (void)setIsRoundResize:(BOOL)isRoundResize {
    [self setIsRoundResize:isRoundResize isToBeArbitrarily:(isRoundResize ? NO : self.isArbitrarily) animated:YES];
}
- (void)setIsRoundResize:(BOOL)isRoundResize isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪宽高比暂不可设置，此时应该将设置按钮设为不可点或隐藏");
        return;
    }
    [self.frameView setIsRoundResize:isRoundResize isToBeArbitrarily:isToBeArbitrarily animated:isAnimated];
}
- (BOOL)isRoundResize {
    return _frameView.isRoundResize;
}

- (void)setMaskImage:(UIImage *)maskImage {
    [self setMaskImage:maskImage isToBeArbitrarily:(maskImage ? NO : YES) animated:YES];
}
- (void)setMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪宽高比暂不可设置，此时应该将设置按钮设为不可点或隐藏");
        return;
    }
    [self.frameView setMaskImage:maskImage isToBeArbitrarily:isToBeArbitrarily animated:isAnimated];
}
- (UIImage *)maskImage {
    return _frameView.maskImage;
}

- (void)setIsArbitrarily:(BOOL)isArbitrarily {
    [self setIsArbitrarily:isArbitrarily animated:YES];
}
- (void)setIsArbitrarily:(BOOL)isArbitrarily animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪宽高比暂不可设置，此时应该将设置按钮设为不可点或隐藏");
        return;
    }
    [self.frameView setIsArbitrarily:isArbitrarily animated:isAnimated];
}
- (BOOL)isArbitrarily {
    return _frameView.isArbitrarily;
}

- (CGFloat)imageresizerWHScale {
    return _frameView.imageresizerWHScale;
}

#pragma mark - 裁剪框样式相关
- (void)setFrameType:(JPImageresizerFrameType)frameType {
    [self.frameView updateFrameType:frameType];
}
- (JPImageresizerFrameType)frameType {
    return _frameView.frameType;
}

- (void)setBorderImage:(UIImage *)borderImage {
    self.frameView.borderImage = borderImage;
}
- (UIImage *)borderImage {
    return _frameView.borderImage;
}

- (void)setBorderImageRectInset:(CGPoint)borderImageRectInset {
    self.frameView.borderImageRectInset = borderImageRectInset;
}
- (CGPoint)borderImageRectInset {
    return _frameView.borderImageRectInset;
}

- (void)setIsShowMidDots:(BOOL)isShowMidDots {
    self.frameView.isShowMidDots = isShowMidDots;
}
- (BOOL)isShowMidDots {
    return _frameView.isShowMidDots;
}

- (void)setIsBlurWhenDragging:(BOOL)isBlurWhenDragging {
    self.frameView.isBlurWhenDragging = isBlurWhenDragging;
}
- (BOOL)isBlurWhenDragging {
    return _frameView.isBlurWhenDragging;
}

- (void)setIsShowGridlinesWhenIdle:(BOOL)isShowGridlinesWhenIdle {
    self.frameView.isShowGridlinesWhenIdle = isShowGridlinesWhenIdle;
}

- (BOOL)isShowGridlinesWhenIdle {
    return _frameView.isShowGridlinesWhenIdle;
}

- (void)setIsShowGridlinesWhenDragging:(BOOL)isShowGridlinesWhenDragging {
    self.frameView.isShowGridlinesWhenDragging = isShowGridlinesWhenDragging;
}
- (BOOL)isShowGridlinesWhenDragging {
    return _frameView.isShowGridlinesWhenDragging;
}

- (void)setGridCount:(NSUInteger)gridCount {
    self.frameView.gridCount = gridCount;
}
- (NSUInteger)gridCount {
    return _frameView.gridCount;
}

- (void)setIsLockResizeFrame:(BOOL)isLockResizeFrame {
    self.frameView.panGR.enabled = !isLockResizeFrame;
}
- (BOOL)isLockResizeFrame {
    return !_frameView.panGR.enabled;
}

- (void)setEdgeLineIsEnabled:(BOOL)edgeLineIsEnabled {
    _edgeLineIsEnabled = edgeLineIsEnabled;
    self.frameView.edgeLineIsEnabled = edgeLineIsEnabled;
}

#pragma mark - 裁剪框、背景、遮罩颜色相关
- (void)setBlurEffect:(UIBlurEffect *)blurEffect {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:blurEffect bgColor:self.bgColor maskAlpha:self.maskAlpha animated:YES];
}
- (UIBlurEffect *)blurEffect {
    return _frameView.blurEffect;
}

- (void)setBgColor:(UIColor *)bgColor {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:self.blurEffect bgColor:bgColor maskAlpha:self.maskAlpha animated:YES];
}
- (UIColor *)bgColor {
    return _frameView.bgColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:self.blurEffect bgColor:self.bgColor maskAlpha:maskAlpha animated:YES];
}
- (CGFloat)maskAlpha {
    return _frameView.maskAlpha;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [self.frameView setupStrokeColor:strokeColor blurEffect:self.blurEffect bgColor:self.bgColor maskAlpha:self.maskAlpha animated:YES];
}
- (UIColor *)strokeColor {
    return _frameView.strokeColor;
}

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

#pragma mark - 旋转、镜像翻转相关
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
            [self.frameView rotatingWithDuration:duration];
        } completion:^(BOOL finished) {
            [self.frameView rotationDone];
        }];
    });
}

#pragma mark 镜像翻转
- (void)setVerticalityMirror:(BOOL)verticalityMirror {
    [self setVerticalityMirror:verticalityMirror animated:YES];
}
- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_verticalityMirror == verticalityMirror) return;
    _verticalityMirror = verticalityMirror;
    [self __changeMirror:NO animated:isAnimated];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror {
    [self setHorizontalMirror:horizontalMirror animated:YES];
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

#pragma mark - 其他
- (CGSize)baseContentMaxSize {
    return _frameView.baseContentMaxSize;
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

#pragma mark 预览
- (void)setIsPreview:(BOOL)isPreview {
    [self setIsPreview:isPreview animated:YES];
}
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated {
    [self.frameView setIsPreview:isPreview animated:isAnimated];
    self.scrollView.userInteractionEnabled = !isPreview;
}
- (BOOL)isPreview {
    return _frameView.isPreview;
}

#pragma mark 更新视图整体Frame，可作用于横竖屏切换
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

#pragma mark - 重置
- (void)recovery {
    [self __recoveryToResizeWHScale:self.resizeWHScale
                    orToRoundResize:self.isRoundResize
                      orToMaskImage:self.maskImage
                  isToBeArbitrarily:self.isArbitrarily];
}

- (void)recoveryByInitialResizeWHScale {
    [self __recoveryToResizeWHScale:self.initialResizeWHScale
                    orToRoundResize:NO
                      orToMaskImage:nil
                  isToBeArbitrarily:self.isArbitrarily];
}
- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily {
    [self __recoveryToResizeWHScale:self.initialResizeWHScale
                    orToRoundResize:NO
                      orToMaskImage:nil
                  isToBeArbitrarily:isToBeArbitrarily];
}
- (void)recoveryByCurrentResizeWHScale {
    [self __recoveryToResizeWHScale:self.resizeWHScale
                    orToRoundResize:NO
                      orToMaskImage:nil
                  isToBeArbitrarily:self.isArbitrarily];
}
- (void)recoveryByCurrentResizeWHScale:(BOOL)isToBeArbitrarily {
    [self __recoveryToResizeWHScale:self.resizeWHScale
                    orToRoundResize:NO
                      orToMaskImage:nil
                  isToBeArbitrarily:isToBeArbitrarily];
}
- (void)recoveryToTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily {
    [self __recoveryToResizeWHScale:targetResizeWHScale
                    orToRoundResize:NO
                      orToMaskImage:nil
                  isToBeArbitrarily:isToBeArbitrarily];
}

- (void)recoveryToRoundResize {
    [self __recoveryToResizeWHScale:1
                    orToRoundResize:YES
                      orToMaskImage:nil
                  isToBeArbitrarily:self.isArbitrarily];
}
- (void)recoveryToRoundResize:(BOOL)isToBeArbitrarily {
    [self __recoveryToResizeWHScale:1
                    orToRoundResize:YES
                      orToMaskImage:nil
                  isToBeArbitrarily:isToBeArbitrarily];
}

- (void)recoveryByCurrentMaskImage {
    [self __recoveryToResizeWHScale:0
                    orToRoundResize:NO
                      orToMaskImage:self.maskImage
                  isToBeArbitrarily:self.isArbitrarily];
}
- (void)recoveryByCurrentMaskImage:(BOOL)isToBeArbitrarily {
    [self __recoveryToResizeWHScale:0
                    orToRoundResize:NO
                      orToMaskImage:self.maskImage
                  isToBeArbitrarily:isToBeArbitrarily];
}
- (void)recoveryToMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily{
    [self __recoveryToResizeWHScale:0
                    orToRoundResize:NO
                      orToMaskImage:maskImage
                  isToBeArbitrarily:isToBeArbitrarily];
}

- (void)__recoveryToResizeWHScale:(CGFloat)resizeWHScale
                  orToRoundResize:(BOOL)isRoundResize
                    orToMaskImage:(UIImage *)maskImage
                isToBeArbitrarily:(BOOL)isToBeArbitrarily {
    BOOL isCanRecovery = (maskImage != nil || self.maskImage != nil) && self.maskImage != maskImage;
    if (!isCanRecovery) isCanRecovery = self.frameView.isCanRecovery;
    if (!isCanRecovery) {
        JPIRLog(@"jp_tip: 已经是初始状态，不需要重置");
        return;
    }
    
    BOOL isUpdateMaskImage = maskImage != nil && self.maskImage != maskImage;

    NSTimeInterval delay = [self.frameView willRecoveryToResizeWHScale:resizeWHScale orToRoundResize:isRoundResize orToMaskImage:maskImage isToBeArbitrarily:isToBeArbitrarily animated:YES];
    
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

#pragma mark - 裁剪

#pragma mark 裁剪图片
// 原图尺寸裁剪图片
- (void)cropPictureWithCacheURL:(NSURL *)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                  completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropPictureWithCompressScale:1
                              cacheURL:cacheURL
                            errorBlock:errorBlock
                         completeBlock:completeBlock];
}

// 自定义压缩比例裁剪图片
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                            cacheURL:(NSURL *)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                               errorBlock:(JPImageresizerErrorBlock)errorBlock
                          completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self cropGIFCurrentIndexWithCompressScale:1
                                      cacheURL:cacheURL
                                    errorBlock:errorBlock
                                 completeBlock:completeBlock];
}

- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                     cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
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
              errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                               errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                         errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                                         errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
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
                   errorBlock:(JPImageresizerErrorBlock)errorBlock
                progressBlock:(JPExportVideoProgressBlock)progressBlock
                completeBlock:(JPExportVideoCompleteBlock)completeBlock {
    [self cropVideoWithPresetName:AVAssetExportPresetHighestQuality
                         cacheURL:cacheURL
                       errorBlock:errorBlock
                    progressBlock:progressBlock
                    completeBlock:completeBlock];
}

// 裁剪整段视频
- (void)cropVideoWithPresetName:(NSString *)presetName
                       cacheURL:(NSURL *)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                 progressBlock:(JPExportVideoProgressBlock)progressBlock
                 completeBlock:(JPExportVideoCompleteBlock)completeBlock {
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
                                errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
        if (wSelf) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf __removeProgressTimer];
        }
        !errorBlock ? : errorBlock(cacheURL, reason);
    } startBlock:^(AVAssetExportSession *exportSession) {
        if (!wSelf) return;
        __strong typeof(wSelf) sSelf = wSelf;
        [sSelf __addProgressTimer:progressBlock exporterSession:exportSession];
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

#pragma mark - 获取当前的配置属性

- (JPImageresizerConfigure *)saveCurrentConfigure {
    JPImageresizerConfigure *configure = [[JPImageresizerConfigure alloc] init];
    configure.viewFrame = self.configure.viewFrame;
    configure.maximumZoomScale = self.configure.maximumZoomScale;
    configure.contentInsets = self.configure.contentInsets;
    configure.fixErrorBlock = self.configure.fixErrorBlock;
    configure.fixStartBlock = self.configure.fixStartBlock;
    configure.fixProgressBlock = self.configure.fixProgressBlock;
    configure.fixCompleteBlock = self.configure.fixCompleteBlock;
    
    configure.image = self.image;
    configure.imageData = self.imageData;
    configure.videoURL = self.videoURL;
    configure.videoAsset = self.videoAsset;
    configure.frameType = self.frameType;
    configure.animationCurve = self.animationCurve;
    configure.blurEffect = self.blurEffect;
    configure.bgColor = self.bgColor;
    configure.maskAlpha = self.maskAlpha;
    configure.strokeColor = self.strokeColor;
    configure.resizeWHScale = self.resizeWHScale;
    configure.isRoundResize = self.isRoundResize;
    configure.maskImage = self.maskImage;
    configure.isArbitrarily = self.isArbitrarily;
    configure.edgeLineIsEnabled = self.edgeLineIsEnabled;
    configure.isClockwiseRotation = self.isClockwiseRotation;
    configure.borderImage = self.borderImage;
    configure.borderImageRectInset = self.borderImageRectInset;
    configure.isShowMidDots = self.isShowMidDots;
    configure.isBlurWhenDragging = self.isBlurWhenDragging;
    configure.isShowGridlinesWhenIdle = self.isShowGridlinesWhenIdle;
    configure.isShowGridlinesWhenDragging = self.isShowGridlinesWhenDragging;
    configure.gridCount = self.gridCount;
    configure.isLoopPlaybackGIF = self.isLoopPlaybackGIF;
    
    configure.history = JPCropHistoryMake(self.frame,
                                          _contentInsets,
                                          self.frameView.direction,
                                          self.frameView.layer.transform,
                                          self.containerView.layer.transform,
                                          self.frameView.imageresizerFrame,
                                          _verticalityMirror,
                                          _horizontalMirror,
                                          self.scrollView.contentInset,
                                          self.scrollView.contentOffset,
                                          self.scrollView.minimumZoomScale,
                                          self.scrollView.zoomScale);
    return configure;
}

#pragma mark - override method

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        JPCropHistory history = self.configure.history;
        // 没有保存过，则按以前的方式初始化
        if (JPCropHistoryIsNull(history)) {
            [self.frameView updateImageOriginFrameWithDuration:-1.0];
        } else {
            JPImageresizerRotationDirection direction = history.direction;
            for (NSInteger i = 0; i < self.allDirections.count; i++) {
                JPImageresizerRotationDirection kDirection = [self.allDirections[i] integerValue];
                if (kDirection == direction) {
                    self.directionIndex = i;
                    break;
                }
            }
            _verticalityMirror = history.isVerMirror;
            _horizontalMirror = history.isHorMirror;
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.containerView.layer.transform = history.containerViewTransform;
            self.scrollView.layer.transform = history.contentViewTransform;
            self.frameView.layer.transform = history.contentViewTransform;
            [CATransaction commit];
            
            self.scrollView.minimumZoomScale = history.scrollViewMinimumZoomScale;
            self.scrollView.zoomScale = history.scrollViewCurrentZoomScale;
            self.scrollView.contentInset = history.scrollViewContentInsets;
            self.scrollView.contentOffset = history.scrollViewContentOffset;
            
            [self.frameView recoveryToSavedHistoryWithDirection:direction
                                              imageresizerFrame:history.imageresizerFrame
                                              isToBeArbitrarily:self.configure.isArbitrarily];
        }
        if (self.configure.isCleanHistoryAfterInitial) [self.configure cleanHistory];
    }
}

@end
