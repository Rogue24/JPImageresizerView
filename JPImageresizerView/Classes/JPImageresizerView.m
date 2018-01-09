//
//  JPImageresizerView.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerView.h"
#import "JPImageresizerFrameView.h"

#ifdef DEBUG
#define JPLog(...) printf("%s %s 第%d行: %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define JPLog(...)
#endif

@interface JPImageresizerView () <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) JPImageresizerFrameView *frameView;

@property (nonatomic, strong) NSMutableArray *allDirections;
@property (nonatomic, assign) NSInteger directionIndex;
@end

@implementation JPImageresizerView
{
    UIEdgeInsets _contentInsets;
    CGSize _contentSize;
    UIViewAnimationOptions _animationOption;
}

#pragma mark - setter

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    [self.frameView updateFrameType:frameType];
}

- (void)setBgColor:(UIColor *)bgColor {
    if (bgColor == [UIColor clearColor]) bgColor = [UIColor blackColor];
    self.backgroundColor = bgColor;
    if (_frameView) [_frameView setFillColor:bgColor];
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    if (_frameView) _frameView.maskAlpha = maskAlpha;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.frameView.strokeColor = strokeColor;
}

- (void)setResizeImage:(UIImage *)resizeImage {
    self.imageView.image = resizeImage;
    [self updateSubviewLayouts];
}

- (void)setVerBaseMargin:(CGFloat)verBaseMargin {
    _verBaseMargin = verBaseMargin;
    [self updateSubviewLayouts];
}

- (void)setHorBaseMargin:(CGFloat)horBaseMargin {
    _horBaseMargin = horBaseMargin;
    [self updateSubviewLayouts];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    [self.frameView setResizeWHScale:resizeWHScale animated:NO];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale animated:(BOOL)isAnimated {
    [self.frameView setResizeWHScale:resizeWHScale animated:isAnimated];
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

- (void)setIsRotatedAutoScale:(BOOL)isRotatedAutoScale {
    _isRotatedAutoScale = isRotatedAutoScale;
    self.frameView.isRotatedAutoScale = isRotatedAutoScale;
}

- (void)setVerticalityMirror:(BOOL)verticalityMirror {
    [self setVerticalityMirror:verticalityMirror animated:NO];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror {
    [self setHorizontalMirror:horizontalMirror animated:NO];
}

#pragma mark - getter

- (JPImageresizerMaskType)maskType {
    return self.frameView.maskType;
}

- (JPImageresizerFrameType)frameType {
    return self.frameView.frameType;
}

- (UIColor *)bgColor {
    return self.backgroundColor;
}

- (UIColor *)strokeColor {
    return _frameView.strokeColor;
}

- (UIImage *)resizeImage {
    return _imageView.image;
}

- (CGFloat)resizeWHScale {
    return _frameView.resizeWHScale;
}

- (CGFloat)maskAlpha {
    return _frameView.maskAlpha;
}

- (BOOL)isLockResizeFrame {
    return !self.frameView.panGR.enabled;
}

#pragma mark - init

+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure *)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    return [[self alloc] initWithResizeImage:configure.resizeImage
                                       frame:configure.viewFrame
                                    maskType:configure.maskType
                                   frameType:configure.frameType
                              animationCurve:configure.animationCurve
                                 strokeColor:configure.strokeColor
                                     bgColor:configure.bgColor
                                   maskAlpha:configure.maskAlpha
                               verBaseMargin:configure.verBaseMargin
                               horBaseMargin:configure.horBaseMargin
                               resizeWHScale:configure.resizeWHScale
                               contentInsets:configure.contentInsets
                   imageresizerIsCanRecovery:imageresizerIsCanRecovery
                imageresizerIsPrepareToScale:imageresizerIsPrepareToScale];
}

- (instancetype)initWithResizeImage:(UIImage *)resizeImage
                              frame:(CGRect)frame
                           maskType:(JPImageresizerMaskType)maskType
                          frameType:(JPImageresizerFrameType)frameType
                     animationCurve:(JPAnimationCurve)animationCurve
                        strokeColor:(UIColor *)strokeColor
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha
                      verBaseMargin:(CGFloat)verBaseMargin
                      horBaseMargin:(CGFloat)horBaseMargin
                      resizeWHScale:(CGFloat)resizeWHScale
                      contentInsets:(UIEdgeInsets)contentInsets
          imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
       imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    
    if (self = [super initWithFrame:frame]) {
        _verBaseMargin = verBaseMargin;
        _horBaseMargin = horBaseMargin;
        _contentInsets = contentInsets;
        CGFloat width = (self.bounds.size.width - _contentInsets.left - _contentInsets.right);
        CGFloat height = (self.bounds.size.height - _contentInsets.top - _contentInsets.bottom);
        _contentSize = CGSizeMake(width, height);
        if (maskType == JPLightBlurMaskType) {
            self.bgColor = [UIColor whiteColor];
        } else if (maskType == JPDarkBlurMaskType) {
            self.bgColor = [UIColor blackColor];
        } else {
            self.bgColor = bgColor;
        }
        self.animationCurve = animationCurve;
        [self setupBase];
        [self setupScorllView];
        [self setupImageViewWithImage:resizeImage];
        [self setupFrameViewWithMaskType:maskType
                               frameType:frameType
                          animationCurve:animationCurve
                             strokeColor:strokeColor
                               maskAlpha:maskAlpha
                           resizeWHScale:resizeWHScale
                      isCanRecoveryBlock:imageresizerIsCanRecovery
                   isPrepareToScaleBlock:imageresizerIsPrepareToScale];
        
    }
    return self;
}

- (void)setupBase {
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.allDirections = [@[@(JPImageresizerVerticalUpDirection),
                            @(JPImageresizerHorizontalLeftDirection),
                            @(JPImageresizerVerticalDownDirection),
                            @(JPImageresizerHorizontalRightDirection)] mutableCopy];
}

#pragma mark - setupSubviews

- (void)setupScorllView {
    CGFloat h = _contentSize.height;
    CGFloat w = h * h / _contentSize.width;
    CGFloat x = _contentInsets.left + (self.bounds.size.width - w) * 0.5;
    CGFloat y = _contentInsets.top;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(x, y, w, h);
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 10.0;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.clipsToBounds = NO;
    if (@available(iOS 11.0, *)) scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)setupImageViewWithImage:(UIImage *)image {
    CGFloat width = (self.frame.size.width - _contentInsets.left - _contentInsets.right);
    CGFloat height = (self.frame.size.height - _contentInsets.top - _contentInsets.bottom);
    CGFloat maxW = width - 2 * self.horBaseMargin;
    CGFloat maxH = height - 2 * self.verBaseMargin;
    CGFloat whScale = image.size.width / image.size.height;
    CGFloat w = maxW;
    CGFloat h = w / whScale;
    if (h > maxH) {
        h = maxH;
        w = h * whScale;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, w, h);
    imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imageView];
    self.imageView = imageView;
    
    self.isRotatedAutoScale = h > w;
    
    CGFloat verticalInset = (self.scrollView.bounds.size.height - h) * 0.5;
    CGFloat horizontalInset = (self.scrollView.bounds.size.width - w) * 0.5;
    self.scrollView.contentSize = imageView.bounds.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    self.scrollView.contentOffset = CGPointMake(-horizontalInset, -verticalInset);
}

- (void)setupFrameViewWithMaskType:(JPImageresizerMaskType)maskType
                         frameType:(JPImageresizerFrameType)frameType
                    animationCurve:(JPAnimationCurve)animationCurve
                       strokeColor:(UIColor *)strokeColor
                         maskAlpha:(CGFloat)maskAlpha
                     resizeWHScale:(CGFloat)resizeWHScale
                isCanRecoveryBlock:(JPImageresizerIsCanRecoveryBlock)isCanRecoveryBlock
             isPrepareToScaleBlock:(JPImageresizerIsPrepareToScaleBlock)isPrepareToScaleBlock {
    
    JPImageresizerFrameView *frameView =
        [[JPImageresizerFrameView alloc] initWithFrame:self.scrollView.frame
                                           contentSize:_contentSize 
                                              maskType:maskType
                                             frameType:frameType
                                        animationCurve:animationCurve
                                           strokeColor:strokeColor
                                             fillColor:self.bgColor
                                             maskAlpha:maskAlpha
                                         verBaseMargin:_verBaseMargin
                                         horBaseMargin:_horBaseMargin
                                         resizeWHScale:resizeWHScale
                                            scrollView:self.scrollView
                                             imageView:self.imageView
                             imageresizerIsCanRecovery:isCanRecoveryBlock
                          imageresizerIsPrepareToScale:isPrepareToScaleBlock];
    
    frameView.isRotatedAutoScale = self.isRotatedAutoScale;
    
    __weak typeof(self) wSelf = self;
    
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
    
    [self addSubview:frameView];
    self.frameView = frameView;
}

#pragma mark - private method

- (void)updateSubviewLayouts {
    self.directionIndex = 0;
    
    self.scrollView.layer.transform = CATransform3DIdentity;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    CGFloat maxW = self.frame.size.width - 2 * self.horBaseMargin;
    CGFloat maxH = self.frame.size.height - 2 * self.verBaseMargin;
    CGFloat whScale = self.imageView.image.size.width / self.imageView.image.size.height;
    CGFloat w = maxW;
    CGFloat h = w / whScale;
    if (h > maxH) {
        h = maxH;
        w = h * whScale;
    }
    self.imageView.frame = CGRectMake(0, 0, w, h);
    
    CGFloat verticalInset = (self.scrollView.bounds.size.height - h) * 0.5;
    CGFloat horizontalInset = (self.scrollView.bounds.size.width - w) * 0.5;
    
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    self.scrollView.contentOffset = CGPointMake(-horizontalInset, -verticalInset);
    
    [self.frameView updateImageresizerFrameWithVerBaseMargin:_verBaseMargin horBaseMargin:_horBaseMargin];
}

#pragma mark - puild method

- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_verticalityMirror == verticalityMirror) return;
    _verticalityMirror = verticalityMirror;
    [self setMirror:NO animated:isAnimated];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_horizontalMirror == horizontalMirror) return;
    _horizontalMirror = horizontalMirror;
    [self setMirror:YES animated:isAnimated];
}

- (void)setMirror:(BOOL)isHorizontalMirror animated:(BOOL)isAnimated {
    CATransform3D transform = self.layer.transform;
    BOOL mirror;
    if (isHorizontalMirror) {
        transform = CATransform3DRotate(transform, M_PI, 1, 0, 0);
        mirror = _horizontalMirror;
    } else {
        transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
        mirror = _verticalityMirror;
    }
    
    [self.frameView willMirror:isAnimated];
    
    void (^animateBlock)(CATransform3D aTransform) = ^(CATransform3D aTransform){
        self.layer.transform = aTransform;
        if (isHorizontalMirror) {
            [self.frameView horizontalMirrorWithDiffY:(mirror ? _contentInsets.bottom : _contentInsets.top)];
        } else {
            [self.frameView verticalityMirrorWithDiffX:(mirror ? _contentInsets.right : _contentInsets.left)];
        }
    };
    
    if (isAnimated) {
        // 做3d旋转时会遮盖住上层的控件，设置为-400即可
        self.layer.zPosition = -400;
        transform.m34 = 1.0 / 1500.0;
        if (isHorizontalMirror) {
            transform.m34 *= -1.0;
        }
        if (mirror) {
            transform.m34 *= -1.0;
        }
        [UIView animateWithDuration:0.45 delay:0 options:_animationOption animations:^{
            animateBlock(transform);
        } completion:^(BOOL finished) {
            self.layer.zPosition = 0;
            [self.frameView mirrorDone];
        }];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        animateBlock(transform);
        [CATransaction commit];
        [self.frameView mirrorDone];
    }
}

- (void)updateResizeImage:(UIImage *)resizeImage verBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin {
    self.imageView.image = resizeImage;
    _verBaseMargin = verBaseMargin;
    _horBaseMargin = horBaseMargin;
    [self updateSubviewLayouts];
}

- (void)rotation {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，旋转功能暂不可用，此时应该将旋转按钮设为不可点或隐藏");
        return;
    }
    
    self.directionIndex += 1;
    if (self.directionIndex > self.allDirections.count - 1) self.directionIndex = 0;
    
    JPImageresizerRotationDirection direction = [self.allDirections[self.directionIndex] integerValue];
    
    CGFloat scale = 1;
    if (self.isRotatedAutoScale) {
        if (direction == JPImageresizerHorizontalLeftDirection ||
            direction == JPImageresizerHorizontalRightDirection) {
            scale = self.frame.size.width / self.scrollView.bounds.size.height;
        } else {
            scale = self.scrollView.bounds.size.height / self.frame.size.width;
        }
    }
    
    CGFloat angle = (self.isClockwiseRotation ? 1.0 : -1.0) * M_PI * 0.5;
    
//    BOOL isNormal = (_verticalityMirror && _horizontalMirror) || (!_verticalityMirror && !_horizontalMirror);
//    if (!isNormal) {
//        angle *= -1.0;
//    }
    
    CATransform3D svTransform = self.scrollView.layer.transform;
    svTransform = CATransform3DScale(svTransform, scale, scale, 1);
    svTransform = CATransform3DRotate(svTransform, angle, 0, 0, 1);
    
    CATransform3D fvTransform = self.frameView.layer.transform;
    fvTransform = CATransform3DScale(fvTransform, scale, scale, 1);
    fvTransform = CATransform3DRotate(fvTransform, angle, 0, 0, 1);
    
    NSTimeInterval duration = 0.2;
    
    [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
        self.scrollView.layer.transform = svTransform;
        self.frameView.layer.transform = fvTransform;
        [self.frameView rotationWithDirection:direction rotationDuration:duration];
    } completion:nil];
}

- (void)recovery {
    if (!self.frameView.isCanRecovery) {
        JPLog(@"已经是初始状态，不需要重置");
        return;
    }
    
    [self.frameView willRecovery];

    self.directionIndex = 0;
    
    _horizontalMirror = NO;
    _verticalityMirror = NO;
    
    CGFloat x = (_contentSize.width - self.scrollView.bounds.size.width) * 0.5 + _contentInsets.left;
    CGFloat y = (_contentSize.height - self.scrollView.bounds.size.height) * 0.5 + _contentInsets.top;
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = x;
    frame.origin.y = y;
    
    // 做3d旋转时会遮盖住上层的控件，设置为-400即可
    self.layer.zPosition = -400;
    [UIView animateWithDuration:0.45 animations:^{
        
        self.layer.transform = CATransform3DIdentity;
        self.scrollView.layer.transform = CATransform3DIdentity;
        self.frameView.layer.transform = CATransform3DIdentity;
        
        self.scrollView.frame = frame;
        self.frameView.frame = frame;
        
        [self.frameView recovery];
        
    } completion:^(BOOL finished) {
        [self.frameView recoveryDone];
        self.layer.zPosition = 0;
    }];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !complete ? : complete(nil);
        return;
    }
    [self.frameView imageresizerWithComplete:complete];
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

@implementation JPImageresizerConfigure

+ (instancetype)defaultConfigureWithResizeImage:(UIImage *)resizeImage make:(void (^)(JPImageresizerConfigure *))make {
    JPImageresizerConfigure *configure = [[self alloc] init];
    configure.resizeImage = resizeImage;
    configure.viewFrame = [UIScreen mainScreen].bounds;
    configure.maskAlpha = JPNormalMaskType;
    configure.frameType = JPConciseFrameType;
    configure.animationCurve = JPAnimationCurveEaseInOut;
    configure.strokeColor = [UIColor whiteColor];
    configure.bgColor = [UIColor blackColor];
    configure.maskAlpha = 0.75;
    configure.verBaseMargin = 10.0;
    configure.horBaseMargin = 10.0;
    configure.resizeWHScale = 0.0;
    configure.contentInsets = UIEdgeInsetsZero;
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
