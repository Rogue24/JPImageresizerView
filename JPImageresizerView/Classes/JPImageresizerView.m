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
@end

@implementation JPImageresizerView
{
    UIEdgeInsets _contentInsets;
    UIViewAnimationOptions _animationOption;
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

- (void)setResizeImage:(UIImage *)resizeImage {
    [self setResizeImage:resizeImage animated:YES transition:UIViewAnimationTransitionCurlUp];
}

- (void)setVideoURL:(NSURL *)videoURL {
    [self setVideoURL:videoURL animated:YES transition:UIViewAnimationTransitionNone];
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

- (UIImage *)resizeImage {
    return _imageView.image;
}

- (NSURL *)videoURL {
    return _videoObj.videoURL;
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
    JPImageresizerView *imageresizerView = [[self alloc]
                         initWithResizeImage:configure.resizeImage
                                    videoURL:configure.videoURL
                                       frame:configure.viewFrame
                                   frameType:configure.frameType
                              animationCurve:configure.animationCurve blurEffect:configure.blurEffect
                                     bgColor:configure.bgColor
                                   maskAlpha:configure.maskAlpha
                                 strokeColor:configure.strokeColor
                               resizeWHScale:configure.resizeWHScale
                        isArbitrarilyInitial:configure.isArbitrarilyInitial
                               contentInsets:configure.contentInsets
                         isClockwiseRotation:configure.isClockwiseRotation
                                 borderImage:configure.borderImage
                        borderImageRectInset:configure.borderImageRectInset
                            maximumZoomScale:configure.maximumZoomScale
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
    imageresizerView.edgeLineIsEnabled = configure.edgeLineIsEnabled;
    return imageresizerView;
}

- (instancetype)initWithResizeImage:(UIImage *)resizeImage
                           videoURL:(NSURL *)videoURL
                              frame:(CGRect)frame
                          frameType:(JPImageresizerFrameType)frameType
                     animationCurve:(JPAnimationCurve)animationCurve
                         blurEffect:(UIBlurEffect *)blurEffect
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha
                        strokeColor:(UIColor *)strokeColor
                      resizeWHScale:(CGFloat)resizeWHScale
               isArbitrarilyInitial:(BOOL)isArbitrarilyInitial
                      contentInsets:(UIEdgeInsets)contentInsets
                isClockwiseRotation:(BOOL)isClockwiseRotation
                        borderImage:(UIImage *)borderImage
               borderImageRectInset:(CGPoint)borderImageRectInset
                   maximumZoomScale:(CGFloat)maximumZoomScale
                      isRoundResize:(BOOL)isRoundResize
                      isShowMidDots:(BOOL)isShowMidDots
                 isBlurWhenDragging:(BOOL)isBlurWhenDragging
            isShowGridlinesWhenIdle:(BOOL)isShowGridlinesWhenIdle
        isShowGridlinesWhenDragging:(BOOL)isShowGridlinesWhenDragging
                          gridCount:(NSUInteger)gridCount
                          maskImage:(UIImage *)maskImage
                  isArbitrarilyMask:(BOOL)isArbitrarilyMask
          imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
       imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    
    NSAssert((frame.size.width != 0 && frame.size.height != 0), @"must have width and height.");
    
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = UIColor.clearColor;
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.layer.backgroundColor = bgColor.CGColor;
        [self addSubview:_containerView];
        
        _contentInsets = contentInsets;
        
        CGFloat contentWidth = (self.bounds.size.width - _contentInsets.left - _contentInsets.right);
        CGFloat contentHeight = (self.bounds.size.height - _contentInsets.top - _contentInsets.bottom);
        CGSize baseContentMaxSize = CGSizeMake(contentWidth, contentHeight);
        
        self.allDirections = [@[@(JPImageresizerVerticalUpDirection),
                                @(JPImageresizerHorizontalLeftDirection),
                                @(JPImageresizerVerticalDownDirection),
                                @(JPImageresizerHorizontalRightDirection)] mutableCopy];
        self.isClockwiseRotation = isClockwiseRotation;
        
        self.animationCurve = animationCurve;
        
        if (videoURL) [self setVideoURL:videoURL animated:NO transition:UIViewAnimationTransitionNone];
        
        [self __setupScrollViewWithBaseContentMaxSize:baseContentMaxSize maxZoomScale:maximumZoomScale];
        [self __setupImageViewWithImage:(_videoObj ? nil : resizeImage)];
        [self __updateImageViewFrameWithWhScale:(_videoObj ? (_videoObj.videoSize.width / _videoObj.videoSize.height) : (resizeImage.size.width / resizeImage.size.height))];
        
        JPImageresizerFrameView *frameView =
        [[JPImageresizerFrameView alloc] initWithFrame:self.scrollView.frame
                                    baseContentMaxSize:baseContentMaxSize
                                             frameType:frameType
                                        animationCurve:animationCurve
                                            blurEffect:blurEffect
                                               bgColor:bgColor
                                             maskAlpha:maskAlpha
                                           strokeColor:strokeColor
                                         resizeWHScale:resizeWHScale
                                  isArbitrarilyInitial:isArbitrarilyInitial
                                            scrollView:self.scrollView
                                             imageView:self.imageView
                                           borderImage:borderImage
                                  borderImageRectInset:borderImageRectInset
                                         isRoundResize:isRoundResize
                                         isShowMidDots:isShowMidDots
                                    isBlurWhenDragging:isBlurWhenDragging
                               isShowGridlinesWhenIdle:isShowGridlinesWhenIdle
                           isShowGridlinesWhenDragging:isShowGridlinesWhenDragging
                                             gridCount:gridCount
                                             maskImage:maskImage
                                     isArbitrarilyMask:isArbitrarilyMask
                             imageresizerIsCanRecovery:imageresizerIsCanRecovery
                          imageresizerIsPrepareToScale:imageresizerIsPrepareToScale];
        
        __weak typeof(self) wSelf = self;
        
        frameView.contentWhScale = ^CGFloat{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return 1;
            if (sSelf.videoObj) {
                return sSelf.videoObj.videoSize.width / sSelf.videoObj.videoSize.height;
            } else {
                return sSelf.resizeImage.size.width / sSelf.resizeImage.size.height;
            }
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
        
        if (_videoObj) {
            _playerView.frame = _imageView.bounds;
            [_imageView addSubview:_playerView];
            
            frameView.playerView = _playerView;
            frameView.slider = _slider;
        }
        
        [_containerView addSubview:frameView];
        _frameView = frameView;
    }
    return self;
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

- (void)__setupImageViewWithImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [_scrollView addSubview:imageView];
    _imageView = imageView;
}

- (void)__updateImageViewFrameWithWhScale:(CGFloat)whScale {
    NSAssert(whScale != 0, @"resizeImage or videoURL cannot be nil.");
    CGFloat maxWidth = self.frame.size.width - _contentInsets.left - _contentInsets.right;
    CGFloat maxHeight = self.frame.size.height - _contentInsets.top - _contentInsets.bottom;
    CGFloat imgViewW = maxWidth;
    CGFloat imgViewH = imgViewW / whScale;
    if (imgViewH > maxHeight) {
        imgViewH = maxHeight;
        imgViewW = imgViewH * whScale;
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

- (void)__updateSubviewLayouts:(CGFloat)whScale duration:(NSTimeInterval)duration {
    if (self.horizontalMirror) [self setHorizontalMirror:NO animated:NO];
    if (self.verticalityMirror) [self setVerticalityMirror:NO animated:NO];
    self.directionIndex = 0;
    [self __updateImageViewFrameWithWhScale:whScale];
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

- (void)__setResizeImage:(UIImage *)resizeImage whScale:(CGFloat)whScale animated:(BOOL)isAnimated transition:(UIViewAnimationTransition)transition {
    if (isAnimated) {
        UIViewAnimationOptions options = _animationOption;
        if ((self.imageView.image == nil && resizeImage != nil) ||
            (self.imageView.image != nil && resizeImage == nil)) {
            NSTimeInterval duration = 0.35;
            if (resizeImage == nil) {
                self.playerView.frame = self.imageView.bounds;
                self.playerView.alpha = 0;
                [self.imageView addSubview:self.playerView];
                
                CGRect sliderFrame = [self.frameView convertRect:self.frameView.imageresizerFrame toView:self];
                [self.slider setImageresizerFrame:sliderFrame isRoundResize:self.frameView.isRoundResizing];
                self.slider.alpha = 0;
                [self addSubview:self.slider];
                
                [UIView animateWithDuration:0.25 delay:0 options:options animations:^{
                    self.playerView.alpha = 1;
                    self.slider.alpha = 1;
                } completion:^(BOOL finished) {
                    self.frameView.playerView = self.playerView;
                    self.frameView.slider = self.slider;
                    self.imageView.image = nil;
                    [UIView animateWithDuration:duration delay:0 options:options animations:^{
                        [self __updateSubviewLayouts:whScale duration:duration];
                    } completion:nil];
                }];
            } else {
                self.frameView.playerView = nil;
                self.frameView.slider = nil;
                self.imageView.image = resizeImage;
                [UIView animateWithDuration:0.25 delay:0 options:options animations:^{
                    self.playerView.alpha = 0;
                    self.slider.alpha = 0;
                } completion:^(BOOL finished) {
                    [self __removeVideoObj];
                    [UIView animateWithDuration:duration delay:0 options:options animations:^{
                        [self __updateSubviewLayouts:whScale duration:duration];
                    } completion:nil];
                }];
            }
            return;
        }
        if (transition == UIViewAnimationTransitionNone) {
            NSTimeInterval duration = 0.35;
            if (resizeImage) {
                [UIView transitionWithView:self.imageView duration:duration options:(options | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
                    self.imageView.image = resizeImage;
                } completion:nil];
                [UIView animateWithDuration:duration delay:0 options:options animations:^{
                    [self __updateSubviewLayouts:whScale duration:duration];
                } completion:nil];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:duration delay:0 options:options animations:^{
                        [self __updateSubviewLayouts:whScale duration:duration];
                    } completion:nil];
                });
            }
        } else {
            NSTimeInterval duration = 0.45;
            [UIView animateWithDuration:duration delay:0 options:options animations:^{
                [UIView setAnimationTransition:transition forView:self.imageView cache:YES];
                self.imageView.image = resizeImage;
                [self __updateSubviewLayouts:whScale duration:duration];
            } completion:nil];
        }
    } else {
        if (resizeImage) {
            [self __removeVideoObj];
        } else {
            self.frameView.playerView = self.playerView;
            self.frameView.slider = self.slider;
            [self addSubview:self.slider];
            self.playerView.frame = self.imageView.bounds;
            [self.imageView addSubview:self.playerView];
        }
        self.imageView.image = resizeImage;
        [self __updateSubviewLayouts:whScale duration:0];
    }
}

- (void)__removeVideoObj {
    _videoObj = nil;
    
    _frameView.playerView = nil;
    _frameView.slider = nil;
    
    [_playerView removeFromSuperview];
    _playerView = nil;
    
    [_slider removeFromSuperview];
    _slider = nil;
}

#pragma mark - puild method

- (void)setResizeImage:(UIImage *)resizeImage animated:(BOOL)isAnimated transition:(UIViewAnimationTransition)transition {
    NSAssert(resizeImage != nil, @"resizeImage cannot be nil.");
    if (resizeImage) {
        [self __setResizeImage:resizeImage whScale:(resizeImage.size.width / resizeImage.size.height) animated:isAnimated transition:transition];
    }
}

- (void)setVideoURL:(NSURL *)videoURL animated:(BOOL)isAnimated transition:(UIViewAnimationTransition)transition {
    NSAssert(videoURL != nil, @"videoURL cannot be nil.");
    if (videoURL) {
        JPImageresizerVideoObject *videoObj = [[JPImageresizerVideoObject alloc] initWithVideoURL:videoURL];
        _videoObj = videoObj;
        
        if (_playerView) {
            if (isAnimated) {
                CATransition *transition = [CATransition animation];
                transition.duration = 0.35;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                transition.type = kCATransitionFade;
                [_playerView.playerLayer addAnimation:transition forKey:@"JPFadeAnimation"];
            }
            _playerView.videoObj = videoObj;
        } else {
            _playerView = [[JPPlayerView alloc] initWithVideoObj:videoObj];
        }
        
        if (_slider) {
            [_slider resetSeconds:videoObj.seconds second:0];
        } else {
            _slider = [JPImageresizerSlider imageresizerSlider:videoObj.seconds second:0];
            __weak typeof(self) wSelf = self;
            _slider.sliderDragingBlock = ^(float second) {
                if (!wSelf) return;
                __strong typeof(wSelf) sSelf = wSelf;
                CMTime time = CMTimeMakeWithSeconds(second, sSelf.videoObj.timescale);
                CMTime toleranceTime = sSelf.videoObj.toleranceTime;
                [sSelf.playerView.player seekToTime:time toleranceBefore:toleranceTime toleranceAfter:toleranceTime];
            };
        }
        
        if (self.superview) {
            [self __setResizeImage:nil whScale:(videoObj.videoSize.width / videoObj.videoSize.height) animated:isAnimated transition:transition];
        } else {
            [self addSubview:_slider];
            if (_frameView) {
                _frameView.playerView = _playerView;
                _frameView.slider = _slider;
                CGRect sliderFrame = [_frameView convertRect:_frameView.imageresizerFrame toView:self];
                [_slider setImageresizerFrame:sliderFrame isRoundResize:_frameView.isRoundResizing];
            }
            if (_imageView) {
                _playerView.frame = _imageView.bounds;
                [_imageView addSubview:_playerView];
            }
        }
    }
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

- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated {
    [self.frameView setIsPreview:isPreview animated:isAnimated];
    self.scrollView.userInteractionEnabled = !isPreview;
}

- (void)updateResizeImage:(UIImage *)resizeImage {
    self.imageView.image = resizeImage;
    [self __updateSubviewLayouts:(resizeImage.size.width / resizeImage.size.height) duration:0];
}

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

- (void)originImageresizerWithComplete:(void (^)(UIImage *))complete {
    [self imageresizerWithComplete:complete compressScale:1.0];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete compressScale:(CGFloat)compressScale {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !complete ? : complete(nil);
        return;
    }
    if (compressScale <= 0) {
        JPIRLog(@"jp_tip: 压缩比例不能小于或等于0");
        !complete ? : complete(nil);
        return;
    }
    [self.frameView imageresizerWithComplete:complete compressScale:compressScale];
}

- (void)cropVideoCurrentFrameWithComplete:(void(^)(UIImage *resizeImage))complete {
    [self cropVideoCurrentFrameWithComplete:complete compressScale:1.0];
}

- (void)cropVideoCurrentFrameWithComplete:(void(^)(UIImage *resizeImage))complete compressScale:(CGFloat)compressScale {
    [self cropVideoOneFrameWithSecond:self.slider.second complete:complete compressScale:compressScale];
}

- (void)cropVideoOneFrameWithSecond:(float)second complete:(void(^)(UIImage *resizeImage))complete compressScale:(CGFloat)compressScale {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !complete ? : complete(nil);
        return;
    }
    if (compressScale <= 0) {
        JPIRLog(@"jp_tip: 压缩比例不能小于或等于0");
        !complete ? : complete(nil);
        return;
    }
    if (second < 0) {
        second = 0;
    } else if (second > self.slider.seconds) {
        second = self.slider.seconds;
    }
    JPImageresizerVideoObject *videoObj = _videoObj;
    [self.frameView cropVideoOneFrameWithAsset:videoObj.asset size:videoObj.videoSize time:CMTimeMakeWithSeconds(second, videoObj.timescale) complete:complete compressScale:compressScale];
}

- (void)cropVideoWithCachePath:(NSString *)cachePath
                    errorBlock:(BOOL(^)(NSString *cachePath, JPCropVideoFailureReason reason))errorBlock
                 progressBlock:(void(^)(float progress))progressBlock
                 completeBlock:(void(^)(NSURL *cacheURL))completeBlock {
    [self cropVideoWithCachePath:cachePath presetName:AVAssetExportPresetHighestQuality errorBlock:errorBlock progressBlock:progressBlock completeBlock:completeBlock];
}

- (void)cropVideoWithCachePath:(NSString *)cachePath
                    presetName:(NSString *)presetName
                    errorBlock:(BOOL(^)(NSString *cachePath, JPCropVideoFailureReason reason))errorBlock
                 progressBlock:(void(^)(float progress))progressBlock
                 completeBlock:(void(^)(NSURL *cacheURL))completeBlock {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !completeBlock ? : completeBlock(nil);
        return;
    }
    JPImageresizerVideoObject *videoObj = _videoObj;
    [self.frameView cropVideoWithAsset:videoObj.asset
                             timeRange:videoObj.timeRange
                         frameDuration:videoObj.frameDuration
                             cachePath:cachePath
                            presetName:presetName
                            errorBlock:errorBlock
                         progressBlock:progressBlock
                         completeBlock:completeBlock];
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
