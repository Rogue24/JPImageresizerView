//
//  JPImageresizerFrameView.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/11.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerFrameView.h"
#import "UIImage+JPExtension.h"
#import "CALayer+JPExtension.h"

/** keypath */
#define aKeyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))

struct JPRGBAColor {
    CGFloat jp_r;
    CGFloat jp_g;
    CGFloat jp_b;
    CGFloat jp_a;
};

typedef NS_ENUM(NSUInteger, JPRectHorn) {
    JPCenter,
    JPLeftTop,
    JPLeftMid,
    JPLeftBottom,
    
    JPRightTop,
    JPRightMid,
    JPRightBottom,
    
    JPTopMid,
    JPBottomMid
};

typedef NS_ENUM(NSUInteger, JPLinePosition) {
    JPHorizontalTop,
    JPHorizontalBottom,
    JPVerticalLeft,
    JPVerticalRight
};

@interface JPImageresizerFrameView ()
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIView *blurContentView;
@property (nonatomic, weak) UIVisualEffectView *blurEffectView;
@property (nonatomic, weak) UIImageView *borderImageView;
- (CGRect)borderImageViewFrame;

// 背景
@property (nonatomic, weak) CAShapeLayer *bgLayer;
// 线框
@property (nonatomic, weak) CAShapeLayer *frameLayer;
// 左上中下点
@property (nonatomic, weak) CAShapeLayer *leftTopDot;
@property (nonatomic, weak) CAShapeLayer *leftMidDot;
@property (nonatomic, weak) CAShapeLayer *leftBottomDot;
// 右上中下点
@property (nonatomic, weak) CAShapeLayer *rightTopDot;
@property (nonatomic, weak) CAShapeLayer *rightMidDot;
@property (nonatomic, weak) CAShapeLayer *rightBottomDot;
// 上中点
@property (nonatomic, weak) CAShapeLayer *topMidDot;
// 下中点
@property (nonatomic, weak) CAShapeLayer *bottomMidDot;
// 网格线
@property (nonatomic, weak) CAShapeLayer *horTopLine;
@property (nonatomic, weak) CAShapeLayer *horBottomLine;
@property (nonatomic, weak) CAShapeLayer *verLeftLine;
@property (nonatomic, weak) CAShapeLayer *verRightLine;
// 是否显示边线的中点
@property (nonatomic, assign) BOOL isShowMidDot;

@property (nonatomic, assign) CGRect originImageFrame;
@property (nonatomic, assign) CGRect maxResizeFrame;
- (CGFloat)maxResizeX;
- (CGFloat)maxResizeY;
- (CGFloat)maxResizeW;
- (CGFloat)maxResizeH;

@property (nonatomic) CGFloat imageresizeX;
@property (nonatomic) CGFloat imageresizeY;
@property (nonatomic) CGFloat imageresizeW;
@property (nonatomic) CGFloat imageresizeH;
- (CGSize)imageresizerSize;
- (CGSize)imageViewSzie;
@end

@implementation JPImageresizerFrameView
{
    CGFloat _dotWH;
    CGFloat _arrLineW;
    CGFloat _arrLength;
    CGFloat _scopeWH;
    CGFloat _minImageWH;
    CGFloat _baseImageW;
    CGFloat _baseImageH;
    CGFloat _startResizeW;
    CGFloat _startResizeH;
    CGFloat _originWHScale;
    CGFloat _verBaseMargin;
    CGFloat _horBaseMargin;
    CGFloat _diffHalfW;
    CGFloat _diffRotLength;
    CGRect _bgFrame; // 扩大旋转时的区域（防止旋转时有空白区域）
    CGSize _contentSize;
    
    BOOL _isHideBlurEffect;
    BOOL _isHideFrameLine;
    BOOL _isArbitrarily;
    BOOL _isToBeArbitrarily;
    
    NSString *_kCAMediaTimingFunction;
    UIViewAnimationOptions _animationOption;
    NSTimeInterval _defaultDuration;
    
    struct JPRGBAColor _fillRgba;
    
    JPRectHorn _currHorn;
    CGPoint _diagonal;
}

#pragma mark - setter

- (void)setOriginImageFrame:(CGRect)originImageFrame {
    _originImageFrame = originImageFrame;
    _originWHScale = originImageFrame.size.width / originImageFrame.size.height;
}

- (void)setFillColor:(UIColor *)fillColor {
    if (self.maskType == JPLightBlurMaskType) {
        fillColor = [UIColor whiteColor];
    } else if (self.maskType == JPDarkBlurMaskType) {
        fillColor = [UIColor blackColor];
    }
    _fillRgba = [self createRgbaWithColor:fillColor];
    _fillColor = [UIColor colorWithRed:_fillRgba.jp_r green:_fillRgba.jp_g blue:_fillRgba.jp_b alpha:_fillRgba.jp_a * (_isPreview ? 1 : _maskAlpha)];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.blurContentView) {
        self.blurContentView.layer.backgroundColor = _fillColor.CGColor;
    } else {
        self.bgLayer.fillColor = _fillColor.CGColor;
    }
    [CATransaction commit];
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    if (maskAlpha < 0) maskAlpha = 0;
    if (maskAlpha > 1) maskAlpha = 1;
    _maskAlpha = maskAlpha;
    _fillColor = [UIColor colorWithRed:_fillRgba.jp_r green:_fillRgba.jp_g blue:_fillRgba.jp_b alpha:_fillRgba.jp_a * (_isPreview ? 1 : maskAlpha)];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.blurContentView) {
        self.blurContentView.layer.backgroundColor = _fillColor.CGColor;
    } else {
        self.bgLayer.fillColor = _fillColor.CGColor;
    }
    [CATransaction commit];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self updateShapeLayersStrokeColor];
}

- (void)setImageresizerFrame:(CGRect)imageresizerFrame {
    [self updateImageresizerFrame:imageresizerFrame animateDuration:-1.0];
}

- (void)setImageresizeX:(CGFloat)imageresizeX {
    _imageresizerFrame.origin.x = imageresizeX;
}

- (void)setImageresizeY:(CGFloat)imageresizeY {
    _imageresizerFrame.origin.y = imageresizeY;
}

- (void)setImageresizeW:(CGFloat)imageresizeW {
    _imageresizerFrame.size.width = imageresizeW;
}

- (void)setImageresizeH:(CGFloat)imageresizeH {
    _imageresizerFrame.size.height = imageresizeH;
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    [self setResizeWHScale:resizeWHScale isToBeArbitrarily:NO animated:NO];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated {
    if (resizeWHScale > 0 && [self isHorizontalDirection:_rotationDirection]) resizeWHScale = 1.0 / resizeWHScale;
    if (_resizeWHScale == resizeWHScale && !isToBeArbitrarily) return;
    _resizeWHScale = resizeWHScale;
    _isArbitrarily = resizeWHScale <= 0;
    _isToBeArbitrarily = isToBeArbitrarily;
    self.isShowMidDot = isToBeArbitrarily ? YES : _isArbitrarily;
    if (self.superview) {
        CGRect adjustResizeFrame = [self adjustResizeFrame];
        NSTimeInterval duration = isAnimated ? _defaultDuration : -1.0;
        [self updateImageresizerFrame:adjustResizeFrame animateDuration:duration];
        [self adjustImageresizerFrame:adjustResizeFrame isAdvanceUpdateOffset:NO animateDuration:duration];
    }
}

- (void)setIsPreview:(BOOL)isPreview {
    [self setIsPreview:isPreview animated:NO];
}

- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated {
    _isPreview = isPreview;
    self.userInteractionEnabled = !isPreview;
    
    CGFloat opacity = isPreview ? 0.0 : 1.0;
    id toOpacity = @(opacity);
    _fillColor = [UIColor colorWithRed:_fillRgba.jp_r green:_fillRgba.jp_g blue:_fillRgba.jp_b alpha:_fillRgba.jp_a * (isPreview ? 1 : _maskAlpha)];
    
    if (isAnimated) {
        NSTimeInterval duration = _defaultDuration;
        CAMediaTimingFunctionName timingFunctionName = _kCAMediaTimingFunction;
        if (_borderImage) {
            [UIView animateWithDuration:_defaultDuration delay:0 options:_animationOption animations:^{
                self.borderImageView.alpha = opacity;
            } completion:nil];
        } else {
            id toMidDotOpacity = @(_isArbitrarily ? opacity : 0.0);
            NSString *opacityKeyPath = aKeyPath(_frameLayer, opacity);
            __weak typeof(self) wSelf = self;
            void (^layerOpacityAnimate)(CALayer *layer, id toValue) = ^(CALayer *layer, id toValue) {
                __strong typeof(wSelf) sSelf = wSelf;
                if (!sSelf || !layer) return;
                [layer jp_addBackwardsAnimationWithKeyPath:opacityKeyPath fromValue:@(layer.opacity) toValue:toValue timingFunctionName:timingFunctionName duration:duration];
            };
            layerOpacityAnimate(_frameLayer, toOpacity);
            layerOpacityAnimate(_horTopLine, toOpacity);
            layerOpacityAnimate(_horBottomLine, toOpacity);
            layerOpacityAnimate(_verLeftLine, toOpacity);
            layerOpacityAnimate(_verRightLine, toOpacity);
            layerOpacityAnimate(_leftTopDot, toOpacity);
            layerOpacityAnimate(_leftBottomDot, toOpacity);
            layerOpacityAnimate(_rightTopDot, toOpacity);
            layerOpacityAnimate(_rightBottomDot, toOpacity);
            layerOpacityAnimate(_leftMidDot, toMidDotOpacity);
            layerOpacityAnimate(_rightMidDot, toMidDotOpacity);
            layerOpacityAnimate(_topMidDot, toMidDotOpacity);
            layerOpacityAnimate(_bottomMidDot, toMidDotOpacity);
        }
        if (self.blurContentView) {
            [self.blurContentView.layer jp_addBackwardsAnimationWithKeyPath:aKeyPath(self.blurContentView.layer, backgroundColor) fromValue:((id)self.blurContentView.layer.backgroundColor) toValue:_fillColor timingFunctionName:timingFunctionName duration:duration];
        } else {
            [self.bgLayer jp_addBackwardsAnimationWithKeyPath:aKeyPath(self.bgLayer, fillColor) fromValue:((id)self.bgLayer.fillColor) toValue:_fillColor timingFunctionName:timingFunctionName duration:duration];
        }
    } else {
        _borderImageView.alpha = opacity;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self updateShapeLayersOpacity:opacity];
    if (self.blurContentView) {
        self.blurContentView.layer.backgroundColor = _fillColor.CGColor;
    } else {
        self.bgLayer.fillColor = _fillColor.CGColor;
    }
    [CATransaction commit];
}

- (void)setBorderImage:(UIImage *)borderImage {
    _borderImage = borderImage;
    if (borderImage) {
        self.borderImageView.image = borderImage;
        _borderImageView.alpha = _isPreview ? 0.0 : 1.0;
    } else {
        [_borderImageView removeFromSuperview];
    }
    [self setFrameType:_frameType];
}

- (void)setBorderImageRectInset:(CGPoint)borderImageRectInset {
    _borderImageRectInset = borderImageRectInset;
    _borderImageView.frame = self.borderImageViewFrame;
}

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    _frameType = frameType;
    
    if (_borderImage) {
        [_frameLayer removeFromSuperlayer];
        [_horTopLine removeFromSuperlayer];
        [_horBottomLine removeFromSuperlayer];
        [_verLeftLine removeFromSuperlayer];
        [_verRightLine removeFromSuperlayer];
        [_leftMidDot removeFromSuperlayer];
        [_rightMidDot removeFromSuperlayer];
        [_topMidDot removeFromSuperlayer];
        [_bottomMidDot removeFromSuperlayer];
        [_leftTopDot removeFromSuperlayer];
        [_leftBottomDot removeFromSuperlayer];
        [_rightTopDot removeFromSuperlayer];
        [_rightBottomDot removeFromSuperlayer];
        return;
    }
    
    [self frameLayer];
    CGFloat lineW = 0;
    if (frameType == JPConciseFrameType ||
        frameType == JPConciseWithoutOtherDotFrameType) {
        if (frameType == JPConciseFrameType) {
            [self leftMidDot];
            [self rightMidDot];
            [self topMidDot];
            [self bottomMidDot];
        } else {
            [_leftMidDot removeFromSuperlayer];
            [_rightMidDot removeFromSuperlayer];
            [_topMidDot removeFromSuperlayer];
            [_bottomMidDot removeFromSuperlayer];
        }
        [_horTopLine removeFromSuperlayer];
        [_horBottomLine removeFromSuperlayer];
        [_verLeftLine removeFromSuperlayer];
        [_verRightLine removeFromSuperlayer];
        _isHideFrameLine = NO;
    } else {
        [self horTopLine];
        [self horBottomLine];
        [self verLeftLine];
        [self verRightLine];
        [_leftMidDot removeFromSuperlayer];
        [_rightMidDot removeFromSuperlayer];
        [_topMidDot removeFromSuperlayer];
        [_bottomMidDot removeFromSuperlayer];
        lineW = _arrLineW;
    }
    self.leftTopDot.lineWidth = lineW;
    self.leftBottomDot.lineWidth = lineW;
    self.rightTopDot.lineWidth = lineW;
    self.rightBottomDot.lineWidth = lineW;
    
    [self updateShapeLayersStrokeColor];
    [self updateShapeLayersOpacity:(_isPreview ? 0.0 : 1.0)];
    if (!CGRectIsEmpty(_imageresizerFrame)) {
        [self updateImageresizerFrame:_imageresizerFrame animateDuration:0];
    }
}

- (void)setAnimationCurve:(JPAnimationCurve)animationCurve {
    _animationCurve = animationCurve;
    switch (animationCurve) {
        case JPAnimationCurveEaseInOut:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionEaseInEaseOut;
            _animationOption = UIViewAnimationOptionCurveEaseInOut;
            break;
        case JPAnimationCurveEaseIn:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionEaseIn;
            _animationOption = UIViewAnimationOptionCurveEaseIn;
            break;
        case JPAnimationCurveEaseOut:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionEaseOut;
            _animationOption = UIViewAnimationOptionCurveEaseOut;
            break;
        case JPAnimationCurveLinear:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionLinear;
            _animationOption = UIViewAnimationOptionCurveLinear;
            break;
    }
}

- (void)setIsCanRecovery:(BOOL)isCanRecovery {
    _isCanRecovery = isCanRecovery;
    !self.imageresizerIsCanRecovery ? : self.imageresizerIsCanRecovery(isCanRecovery);
}

- (void)setIsPrepareToScale:(BOOL)isPrepareToScale {
    _isPrepareToScale = isPrepareToScale;
    !self.imageresizerIsPrepareToScale ? : self.imageresizerIsPrepareToScale(isPrepareToScale);
}

- (void)setIsShowMidDot:(BOOL)isShowMidDot {
    if (_frameType != JPConciseFrameType || _borderImage || _isPreview) {
        isShowMidDot = NO;
    }
    if (_isShowMidDot == isShowMidDot) {
        return;
    }
    _isShowMidDot = isShowMidDot;
    CGFloat midDotOpacity = isShowMidDot ? 1.0 : 0.0;
    _leftMidDot.opacity = midDotOpacity;
    _rightMidDot.opacity = midDotOpacity;
    _topMidDot.opacity = midDotOpacity;
    _bottomMidDot.opacity = midDotOpacity;
}

- (void)setInitialResizeWHScale:(CGFloat)initialResizeWHScale {
    if (initialResizeWHScale < 0.0) initialResizeWHScale = 0.0;
    _initialResizeWHScale = initialResizeWHScale;
    [self checkIsCanRecovery];
}

#pragma mark - getter

- (CGFloat)maxResizeX {
    return self.maxResizeFrame.origin.x;
}

- (CGFloat)maxResizeY {
    return self.maxResizeFrame.origin.y;
}

- (CGFloat)maxResizeW {
    return self.maxResizeFrame.size.width;
}

- (CGFloat)maxResizeH {
    return self.maxResizeFrame.size.height;
}

- (CGFloat)imageresizeX {
    return _imageresizerFrame.origin.x;
}

- (CGFloat)imageresizeY {
    return _imageresizerFrame.origin.y;
}

- (CGFloat)imageresizeW {
    return _imageresizerFrame.size.width;
}

- (CGFloat)imageresizeH {
    return _imageresizerFrame.size.height;
}

- (CGSize)imageresizerSize {
    CGFloat w = ((NSInteger)(self.imageresizerFrame.size.width)) * 1.0;
    CGFloat h = ((NSInteger)(self.imageresizerFrame.size.height)) * 1.0;
    return CGSizeMake(w, h);
}

- (CGSize)imageViewSzie {
    CGFloat w = ((NSInteger)(self.imageView.frame.size.width)) * 1.0;
    CGFloat h = ((NSInteger)(self.imageView.frame.size.height)) * 1.0;
    return [self isHorizontalDirection:_rotationDirection] ? CGSizeMake(h, w) : CGSizeMake(w, h);
}

- (CAShapeLayer *)frameLayer {
    if (!_frameLayer) {
        _frameLayer = [self createShapeLayer:1.0];
        _frameLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _frameLayer;
}

- (CAShapeLayer *)leftTopDot {
    if (!_leftTopDot) _leftTopDot = [self createShapeLayer:0];
    return _leftTopDot;
}

- (CAShapeLayer *)leftMidDot {
    if (!_leftMidDot) _leftMidDot = [self createShapeLayer:0];
    return _leftMidDot;
}

- (CAShapeLayer *)leftBottomDot {
    if (!_leftBottomDot) _leftBottomDot = [self createShapeLayer:0];
    return _leftBottomDot;
}

- (CAShapeLayer *)rightTopDot {
    if (!_rightTopDot) _rightTopDot = [self createShapeLayer:0];
    return _rightTopDot;
}

- (CAShapeLayer *)rightMidDot {
    if (!_rightMidDot) _rightMidDot = [self createShapeLayer:0];
    return _rightMidDot;
}

- (CAShapeLayer *)rightBottomDot {
    if (!_rightBottomDot) _rightBottomDot = [self createShapeLayer:0];
    return _rightBottomDot;
}

- (CAShapeLayer *)topMidDot {
    if (!_topMidDot) _topMidDot = [self createShapeLayer:0];
    return _topMidDot;
}

- (CAShapeLayer *)bottomMidDot {
    if (!_bottomMidDot) _bottomMidDot = [self createShapeLayer:0];
    return _bottomMidDot;
}

- (CAShapeLayer *)horTopLine {
    if (!_horTopLine) _horTopLine = [self createShapeLayer:0.5];
    return _horTopLine;
}

- (CAShapeLayer *)horBottomLine {
    if (!_horBottomLine) _horBottomLine = [self createShapeLayer:0.5];
    return _horBottomLine;
}

- (CAShapeLayer *)verLeftLine {
    if (!_verLeftLine) _verLeftLine = [self createShapeLayer:0.5];
    return _verLeftLine;
}

- (CAShapeLayer *)verRightLine {
    if (!_verRightLine) _verRightLine = [self createShapeLayer:0.5];
    return _verRightLine;
}

- (BOOL)edgeLineIsEnabled {
    if (_isArbitrarily) {
        return _edgeLineIsEnabled;
    } else {
        return NO;
    }
}

- (UIImageView *)borderImageView {
    if (!_borderImageView) {
        UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:self.borderImageViewFrame];
        [self addSubview:borderImageView];
        _borderImageView = borderImageView;
    }
    return _borderImageView;
}

- (CGRect)borderImageViewFrame {
    if (!CGRectIsEmpty(_imageresizerFrame)) {
        return CGRectInset(_imageresizerFrame, _borderImageRectInset.x, _borderImageRectInset.y);
    }
    return CGRectZero;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
                  contentSize:(CGSize)contentSize
                     maskType:(JPImageresizerMaskType)maskType
                    frameType:(JPImageresizerFrameType)frameType
               animationCurve:(JPAnimationCurve)animationCurve
                  strokeColor:(UIColor *)strokeColor
                    fillColor:(UIColor *)fillColor
                    maskAlpha:(CGFloat)maskAlpha
                verBaseMargin:(CGFloat)verBaseMargin
                horBaseMargin:(CGFloat)horBaseMargin
                resizeWHScale:(CGFloat)resizeWHScale
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView
                  borderImage:(UIImage *)borderImage
         borderImageRectInset:(CGPoint)borderImageRectInset
    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        _edgeLineIsEnabled = YES;
        _defaultDuration = 0.27;
        _dotWH = 10.0;
        _arrLineW = 2.5;
        _arrLength = 20.0;
        _scopeWH = 50.0;
        _minImageWH = 70.0;
        _rotationDirection = JPImageresizerVerticalUpDirection;
        _contentSize = contentSize;
        _maskType = maskType;
        _horBaseMargin = horBaseMargin;
        _verBaseMargin = verBaseMargin;
        _imageresizerIsCanRecovery = [imageresizerIsCanRecovery copy];
        _imageresizerIsPrepareToScale = [imageresizerIsPrepareToScale copy];
        _diffRotLength = 1000;
        
        _bgFrame = CGRectMake(self.bounds.origin.x - _diffRotLength,
                              self.bounds.origin.y - _diffRotLength,
                              self.bounds.size.width + _diffRotLength * 2,
                              self.bounds.size.height + _diffRotLength * 2);
        if (maskType != JPNormalMaskType) {
            UIView *blurContentView = [[UIView alloc] initWithFrame:_bgFrame];
            [self addSubview:blurContentView];
            self.blurContentView = blurContentView;
            
            UIBlurEffect *blurEffect;
            if (maskType == JPLightBlurMaskType) {
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            } else {
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            }
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = blurContentView.bounds;
            [blurContentView addSubview:blurEffectView];
            self.blurEffectView = blurEffectView;
            
            CAShapeLayer *bgLayer = [CAShapeLayer layer];
            bgLayer.frame = blurContentView.bounds;
            bgLayer.fillColor = [UIColor blackColor].CGColor;
            blurContentView.layer.mask = bgLayer;
            self.bgLayer = bgLayer;
        } else {
            self.bgLayer = [self createShapeLayer:0];
            
        }
        self.bgLayer.fillRule = kCAFillRuleEvenOdd;
        
        _maskAlpha = maskAlpha;
        _strokeColor = strokeColor;
        self.fillColor = fillColor;
        
        _borderImageRectInset = borderImageRectInset;
        if (borderImage) {
            _frameType = frameType;
            self.borderImage = borderImage;
        } else {
            self.frameType = frameType;
        }
        
        self.animationCurve = animationCurve;
        self.scrollView = scrollView;
        self.imageView = imageView;
        
        if (resizeWHScale == _resizeWHScale) _resizeWHScale = resizeWHScale - 1.0;
        self.resizeWHScale = resizeWHScale;
        self.initialResizeWHScale = resizeWHScale;
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        [self addGestureRecognizer:panGR];
        _panGR = panGR;
    }
    return self;
}

#pragma mark - life cycle

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) [self updateImageOriginFrameWithDirection:_rotationDirection];
}

- (void)dealloc {
    [self willDie];
}

#pragma mark - timer

- (BOOL)addTimer {
    BOOL isHasTimer = [self removeTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.65 target:self selector:@selector(timerHandle) userInfo:nil repeats:NO]; // default 0.65
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    return isHasTimer;
}

- (BOOL)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        return YES;
    }
    return NO;
}

- (void)timerHandle {
    [self removeTimer];
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:_defaultDuration];
}

#pragma mark - assist method

- (void)willDie {
    self.window.userInteractionEnabled = YES;
    [self removeTimer];
}

- (struct JPRGBAColor)createRgbaWithColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    struct JPRGBAColor rgba;
    rgba.jp_r = r;
    rgba.jp_g = g;
    rgba.jp_b = b;
    rgba.jp_a = a;
    return rgba;
}

- (CAShapeLayer *)createShapeLayer:(CGFloat)lineWidth {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.lineWidth = lineWidth;
    [self.layer addSublayer:shapeLayer];
    return shapeLayer;
}

- (BOOL)isHorizontalDirection:(JPImageresizerRotationDirection)direction {
    return (direction == JPImageresizerHorizontalLeftDirection ||
            direction == JPImageresizerHorizontalRightDirection);
}

- (UIBezierPath *)dotPathWithPosition:(CGPoint)position {
    CGFloat dotWH = _dotWH;
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(position.x - dotWH * 0.5, position.y - dotWH * 0.5, dotWH, dotWH)];
    return dotPath;
}

- (UIBezierPath *)arrPathWithPosition:(CGPoint)position rectHorn:(JPRectHorn)horn {
    CGFloat arrLineW = _arrLineW;
    CGFloat arrLength = _arrLength;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat halfArrLineW = arrLineW * 0.5;
    CGPoint firstPoint = CGPointZero;
    CGPoint secondPoint = CGPointZero;
    CGPoint thirdPoint = CGPointZero;
    switch (horn) {
        case JPLeftTop:
        {
            position.x -= halfArrLineW;
            position.y -= halfArrLineW;
            firstPoint = CGPointMake(position.x, position.y + arrLength);
            thirdPoint = CGPointMake(position.x + arrLength, position.y);
            break;
        }
            
        case JPLeftBottom:
        {
            position.x -= halfArrLineW;
            position.y += halfArrLineW;
            firstPoint = CGPointMake(position.x, position.y - arrLength);
            thirdPoint = CGPointMake(position.x + arrLength, position.y);
            break;
        }
            
        case JPRightTop:
        {
            position.x += halfArrLineW;
            position.y -= halfArrLineW;
            firstPoint = CGPointMake(position.x - arrLength, position.y);
            thirdPoint = CGPointMake(position.x, position.y + arrLength);
            break;
        }
            
        case JPRightBottom:
        {
            position.x += halfArrLineW;
            position.y += halfArrLineW;
            firstPoint = CGPointMake(position.x - arrLength, position.y);
            thirdPoint = CGPointMake(position.x, position.y - arrLength);
            break;
        }
            
        default:
        {
            firstPoint = position;
            thirdPoint = position;
            break;
        }
    }
    secondPoint = position;
    [path moveToPoint:firstPoint];
    [path addLineToPoint:secondPoint];
    [path addLineToPoint:thirdPoint];
    return path;
}

- (UIBezierPath *)linePathWithLinePosition:(JPLinePosition)linePosition location:(CGPoint)location length:(CGFloat)length {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    switch (linePosition) {
        case JPHorizontalTop:
        case JPHorizontalBottom:
        {
            point = CGPointMake(location.x + length, location.y);
            break;
        }
        case JPVerticalLeft:
        case JPVerticalRight:
        {
            point = CGPointMake(location.x, location.y + length);
            break;
        }
    }
    [path moveToPoint:location];
    [path addLineToPoint:point];
    return path;
}

- (BOOL)imageresizerFrameIsEqualImageViewFrame {
    CGSize imageresizerSize = self.imageresizerSize;
    CGSize imageViewSzie = self.imageViewSzie;
    CGFloat resizeWHScale = [self isHorizontalDirection:_rotationDirection] ? (1.0 / _resizeWHScale) : _resizeWHScale;
    if (_isArbitrarily || (resizeWHScale == _originWHScale)) {
        return (fabs(imageresizerSize.width - imageViewSzie.width) <= 1 &&
                fabs(imageresizerSize.height - imageViewSzie.height) <= 1);
    } else {
        return (fabs(imageresizerSize.width - imageViewSzie.width) <= 1 ||
                fabs(imageresizerSize.height - imageViewSzie.height) <= 1);
    }
}

- (CGRect)baseImageresizerFrame {
    if (_isArbitrarily) {
        return self.originImageFrame;
    } else {
        CGFloat w = 0;
        CGFloat h = 0;
        if ([self isHorizontalDirection:_rotationDirection]) {
            h = _baseImageW;
            w = h * _resizeWHScale;
            if (w > self.maxResizeW) {
                w = self.maxResizeW;
                h = w / _resizeWHScale;
            }
        } else {
            w = _baseImageW;
            h = w / _resizeWHScale;
            if (h > self.maxResizeH) {
                h = self.maxResizeH;
                w = h * _resizeWHScale;
            }
        }
        CGFloat x = self.maxResizeX + (self.maxResizeW - w) * 0.5;
        CGFloat y = self.maxResizeY + (self.maxResizeH - h) * 0.5;
        return CGRectMake(x, y, w, h);
    }
}

- (CGRect)adjustResizeFrame {
    CGFloat resizeWHScale = _isArbitrarily ? (self.imageresizeW / self.imageresizeH) : _resizeWHScale;
    CGFloat adjustResizeW = 0;
    CGFloat adjustResizeH = 0;
    if (resizeWHScale >= 1) {
        adjustResizeW = self.maxResizeW;
        adjustResizeH = adjustResizeW / resizeWHScale;
        if (adjustResizeH > self.maxResizeH) {
            adjustResizeH = self.maxResizeH;
            adjustResizeW = self.maxResizeH * resizeWHScale;
        }
    } else {
        adjustResizeH = self.maxResizeH;
        adjustResizeW = adjustResizeH * resizeWHScale;
        if (adjustResizeW > self.maxResizeW) {
            adjustResizeW = self.maxResizeW;
            adjustResizeH = adjustResizeW / resizeWHScale;
        }
    }
    CGFloat adjustResizeX = self.maxResizeX + (self.maxResizeW - adjustResizeW) * 0.5;
    CGFloat adjustResizeY = self.maxResizeY + (self.maxResizeH - adjustResizeH) * 0.5;
    return CGRectMake(adjustResizeX, adjustResizeY, adjustResizeW, adjustResizeH);
}

#pragma mark - private method

- (void)updateShapeLayersStrokeColor {
    if (_borderImage) return;
    CGColorRef strokeCGColor = _strokeColor.CGColor;
    CGColorRef clearCGColor = [UIColor clearColor].CGColor;
    _frameLayer.strokeColor = strokeCGColor;
    if (_frameType == JPConciseFrameType ||
        _frameType == JPConciseWithoutOtherDotFrameType) {
        _leftTopDot.fillColor = strokeCGColor;
        _leftBottomDot.fillColor = strokeCGColor;
        _rightTopDot.fillColor = strokeCGColor;
        _rightBottomDot.fillColor = strokeCGColor;
        
        _leftTopDot.strokeColor = clearCGColor;
        _leftBottomDot.strokeColor = clearCGColor;
        _rightTopDot.strokeColor = clearCGColor;
        _rightBottomDot.strokeColor = clearCGColor;
        
        _leftMidDot.fillColor = strokeCGColor;
        _rightMidDot.fillColor = strokeCGColor;
        _topMidDot.fillColor = strokeCGColor;
        _bottomMidDot.fillColor = strokeCGColor;
    } else {
        _leftTopDot.strokeColor = strokeCGColor;
        _leftBottomDot.strokeColor = strokeCGColor;
        _rightTopDot.strokeColor = strokeCGColor;
        _rightBottomDot.strokeColor = strokeCGColor;
        
        _leftTopDot.fillColor = clearCGColor;
        _leftBottomDot.fillColor = clearCGColor;
        _rightTopDot.fillColor = clearCGColor;
        _rightBottomDot.fillColor = clearCGColor;
        
        _horTopLine.strokeColor = strokeCGColor;
        _horBottomLine.strokeColor = strokeCGColor;
        _verLeftLine.strokeColor = strokeCGColor;
        _verRightLine.strokeColor = strokeCGColor;
    }
}

- (void)updateShapeLayersOpacity:(CGFloat)opacity {
    if (_borderImage) return;
    _frameLayer.opacity = opacity;
    _horTopLine.opacity = opacity;
    _horBottomLine.opacity = opacity;
    _verLeftLine.opacity = opacity;
    _verRightLine.opacity = opacity;
    _leftTopDot.opacity = opacity;
    _leftBottomDot.opacity = opacity;
    _rightTopDot.opacity = opacity;
    _rightBottomDot.opacity = opacity;
    if (_frameType == JPConciseFrameType) {
        CGFloat midDotOpacity = _isArbitrarily ? opacity : 0.0;
        _leftMidDot.opacity = midDotOpacity;
        _rightMidDot.opacity = midDotOpacity;
        _topMidDot.opacity = midDotOpacity;
        _bottomMidDot.opacity = midDotOpacity;
    }
}

- (void)hideOrShowBlurEffect:(BOOL)isHide animateDuration:(NSTimeInterval)duration {
    if (self.maskType == JPNormalMaskType) return;
    if (_isHideBlurEffect == isHide) return;
    _isHideBlurEffect = isHide;
    CGFloat toAlpha = isHide ? 0 : 1;
    if (duration > 0) {
        [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
            self.blurEffectView.alpha = toAlpha;
        } completion:nil];
    } else {
        self.blurEffectView.alpha = toAlpha;
    }
}

- (void)hideOrShowFrameLine:(BOOL)isHide animateDuration:(NSTimeInterval)duration {
    if (_borderImage) return;
    if (self.frameType != JPClassicFrameType) return;
    if (_isHideFrameLine == isHide) return;
    _isHideFrameLine = isHide;
    CGFloat toOpacity = isHide ? 0 : 1;
    if (duration > 0) {
        CGFloat fromOpacity = isHide ? 1 : 0;
        NSString *keyPath = aKeyPath(_horTopLine, opacity);
        CABasicAnimation *anim = [CABasicAnimation jp_backwardsAnimationWithKeyPath:keyPath fromValue:@(fromOpacity) toValue:@(toOpacity) timingFunctionName:_kCAMediaTimingFunction duration:duration];
        [_horTopLine addAnimation:anim forKey:keyPath];
        [_horBottomLine addAnimation:anim forKey:keyPath];
        [_verLeftLine addAnimation:anim forKey:keyPath];
        [_verRightLine addAnimation:anim forKey:keyPath];
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _horTopLine.opacity = toOpacity;
    _horBottomLine.opacity = toOpacity;
    _verLeftLine.opacity = toOpacity;
    _verRightLine.opacity = toOpacity;
    [CATransaction commit];
}

- (void)updateImageresizerFrame:(CGRect)imageresizerFrame animateDuration:(NSTimeInterval)duration {
    _imageresizerFrame = imageresizerFrame;
    
    UIBezierPath *bgPath;
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRect:imageresizerFrame];
    if (self.blurContentView) {
        bgPath = [UIBezierPath bezierPathWithRect:self.blurContentView.bounds];
        CGRect frame = imageresizerFrame;
        frame.origin.x += _diffRotLength;
        frame.origin.y += _diffRotLength;
        [bgPath appendPath:[UIBezierPath bezierPathWithRect:frame]];
    } else {
        bgPath = [UIBezierPath bezierPathWithRect:_bgFrame];
        [bgPath appendPath:framePath];
    }
    
    if (_borderImage) {
        CGRect borderImageViewFrame = self.borderImageViewFrame;
        if (duration > 0) {
            [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
                self.borderImageView.frame = borderImageViewFrame;
            } completion:nil];
            [self.bgLayer jp_addBackwardsAnimationWithKeyPath:aKeyPath(self.bgLayer, path) fromValue:[UIBezierPath bezierPathWithCGPath:self.bgLayer.path] toValue:bgPath timingFunctionName:_kCAMediaTimingFunction duration:duration];
        } else {
            _borderImageView.frame = borderImageViewFrame;
        }
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.bgLayer.path = bgPath.CGPath;
        [CATransaction commit];
        return;
    }
    
    CGFloat imageresizerX = imageresizerFrame.origin.x;
    CGFloat imageresizerY = imageresizerFrame.origin.y;
    CGFloat imageresizerMidX = CGRectGetMidX(imageresizerFrame);
    CGFloat imageresizerMidY = CGRectGetMidY(imageresizerFrame);
    CGFloat imageresizerMaxX = CGRectGetMaxX(imageresizerFrame);
    CGFloat imageresizerMaxY = CGRectGetMaxY(imageresizerFrame);
    
    UIBezierPath *leftTopDotPath;
    UIBezierPath *leftBottomDotPath;
    UIBezierPath *rightTopDotPath;
    UIBezierPath *rightBottomDotPath;
    
    UIBezierPath *leftMidDotPath;
    UIBezierPath *rightMidDotPath;
    UIBezierPath *topMidDotPath;
    UIBezierPath *bottomMidDotPath;
    
    UIBezierPath *horTopLinePath;
    UIBezierPath *horBottomLinePath;
    UIBezierPath *verLeftLinePath;
    UIBezierPath *verRightLinePath;
    
    if (_frameType == JPConciseFrameType || _frameType == JPConciseWithoutOtherDotFrameType) {
        leftTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerY)];
        leftBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMaxY)];
        rightTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerY)];
        rightBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMaxY)];
        
        if (_frameType == JPConciseFrameType) {
            leftMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMidY)];
            rightMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMidY)];
            topMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerY)];
            bottomMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerMaxY)];
        }
    } else {
        leftTopDotPath = [self arrPathWithPosition:CGPointMake(imageresizerX, imageresizerY) rectHorn:JPLeftTop];
        leftBottomDotPath = [self arrPathWithPosition:CGPointMake(imageresizerX, imageresizerMaxY) rectHorn:JPLeftBottom];
        rightTopDotPath = [self arrPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerY) rectHorn:JPRightTop];
        rightBottomDotPath = [self arrPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMaxY) rectHorn:JPRightBottom];
        
        CGFloat imageresizerW = imageresizerFrame.size.width;
        CGFloat imageresizerH = imageresizerFrame.size.height;
        CGFloat oneThirdW = imageresizerW / 3.0;
        CGFloat oneThirdH = imageresizerH / 3.0;
        
        horTopLinePath = [self linePathWithLinePosition:JPHorizontalTop location:CGPointMake(imageresizerX, imageresizerY + oneThirdH) length:imageresizerW];
        horBottomLinePath = [self linePathWithLinePosition:JPHorizontalBottom location:CGPointMake(imageresizerX, imageresizerY + oneThirdH * 2) length:imageresizerW];
        verLeftLinePath = [self linePathWithLinePosition:JPVerticalLeft location:CGPointMake(imageresizerX + oneThirdW, imageresizerY) length:imageresizerH];
        verRightLinePath = [self linePathWithLinePosition:JPVerticalRight location:CGPointMake(imageresizerX + oneThirdW * 2, imageresizerY) length:imageresizerH];
    }
    
    if (duration > 0) {
        NSString *keyPath = aKeyPath(self.bgLayer, path);
        CAMediaTimingFunctionName timingFunctionName = _kCAMediaTimingFunction;
        
        __weak typeof(self) wSelf = self;
        void (^layerPathAnimate)(CAShapeLayer *layer, UIBezierPath *path) = ^(CAShapeLayer *layer, UIBezierPath *path) {
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf || !layer) return;
            [layer jp_addBackwardsAnimationWithKeyPath:keyPath
                                             fromValue:[UIBezierPath bezierPathWithCGPath:layer.path]
                                               toValue:path
                                    timingFunctionName:timingFunctionName
                                              duration:duration];
        };
        layerPathAnimate(_leftTopDot, leftTopDotPath);
        layerPathAnimate(_leftBottomDot, leftBottomDotPath);
        layerPathAnimate(_rightTopDot, rightTopDotPath);
        layerPathAnimate(_rightBottomDot, rightBottomDotPath);
        if (_frameType == JPConciseFrameType) {
            layerPathAnimate(_leftMidDot, leftMidDotPath);
            layerPathAnimate(_rightMidDot, rightMidDotPath);
            layerPathAnimate(_topMidDot, topMidDotPath);
            layerPathAnimate(_bottomMidDot, bottomMidDotPath);
        } else if (_frameType == JPClassicFrameType) {
            layerPathAnimate(_horTopLine, horTopLinePath);
            layerPathAnimate(_horBottomLine, horBottomLinePath);
            layerPathAnimate(_verLeftLine, verLeftLinePath);
            layerPathAnimate(_verRightLine, verRightLinePath);
        }
        layerPathAnimate(_bgLayer, bgPath);
        layerPathAnimate(_frameLayer, framePath);
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _leftTopDot.path = leftTopDotPath.CGPath;
    _leftBottomDot.path = leftBottomDotPath.CGPath;
    _rightTopDot.path = rightTopDotPath.CGPath;
    _rightBottomDot.path = rightBottomDotPath.CGPath;
    if (_frameType == JPConciseFrameType) {
        _leftMidDot.path = leftMidDotPath.CGPath;
        _rightMidDot.path = rightMidDotPath.CGPath;
        _topMidDot.path = topMidDotPath.CGPath;
        _bottomMidDot.path = bottomMidDotPath.CGPath;
    } else if (_frameType == JPClassicFrameType) {
        _horTopLine.path = horTopLinePath.CGPath;
        _horBottomLine.path = horBottomLinePath.CGPath;
        _verLeftLine.path = verLeftLinePath.CGPath;
        _verRightLine.path = verRightLinePath.CGPath;
    }
    _bgLayer.path = bgPath.CGPath;
    _frameLayer.path = framePath.CGPath;
    [CATransaction commit];
}

- (void)updateImageOriginFrameWithDirection:(JPImageresizerRotationDirection)rotationDirection {
    [self removeTimer];
    _baseImageW = self.imageView.bounds.size.width;
    _baseImageH = self.imageView.bounds.size.height;
    _diffHalfW = (self.bounds.size.width - _contentSize.width) * 0.5;
    CGFloat x = (self.bounds.size.width - _baseImageW) * 0.5;
    CGFloat y = (self.bounds.size.height - _baseImageH) * 0.5;
    self.originImageFrame = CGRectMake(x, y, _baseImageW, _baseImageH);
    [self updateRotationDirection:rotationDirection];
    [self updateImageresizerFrame:[self baseImageresizerFrame] animateDuration:-1.0];
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:-1.0];
}

- (void)updateRotationDirection:(JPImageresizerRotationDirection)rotationDirection {
    [self updateMaxResizeFrameWithDirection:rotationDirection];
    if (!_isArbitrarily) {
        BOOL isSwitchVerHor = [self isHorizontalDirection:_rotationDirection] != [self isHorizontalDirection:rotationDirection];
        if (isSwitchVerHor) _resizeWHScale = 1.0 / _resizeWHScale;
    }
    _rotationDirection = rotationDirection;
}

- (void)updateMaxResizeFrameWithDirection:(JPImageresizerRotationDirection)direction {
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    if ([self isHorizontalDirection:direction]) {
        x = (w - _contentSize.height) * 0.5 +  _verBaseMargin;
        y = (h - _contentSize.width) * 0.5 + _horBaseMargin;
    } else {
        x = _diffHalfW + _horBaseMargin;
        y = _verBaseMargin;
    }
    w -= 2 * x;
    h -= 2 * y;
    self.maxResizeFrame = CGRectMake(x, y, w, h);
    
    _frameLayer.lineWidth = 1.0;
    CGFloat lineW = 0;
    if (_frameType == JPClassicFrameType) lineW = _arrLineW;
    _leftTopDot.lineWidth = lineW;
    _leftBottomDot.lineWidth = lineW;
    _rightTopDot.lineWidth = lineW;
    _rightBottomDot.lineWidth = lineW;
    
    lineW = 0.5;
    _horTopLine.lineWidth = lineW;
    _horBottomLine.lineWidth = lineW;
    _verLeftLine.lineWidth = lineW;
    _verRightLine.lineWidth = lineW;
}

- (void)adjustImageresizerFrame:(CGRect)adjustResizeFrame
          isAdvanceUpdateOffset:(BOOL)isAdvanceUpdateOffset
                animateDuration:(NSTimeInterval)duration {
    CGRect imageresizerFrame = self.imageresizerFrame;
    UIScrollView *scrollView = self.scrollView;
    UIImageView *imageView = self.imageView;
    
    // zoomFrame
    // 根据裁剪的区域，因为需要有间距，所以拼接成self的尺寸获取缩放的区域zoomFrame
    // 宽高比不变，所以宽度高度的比例是一样，这里就用宽度比例吧
    CGFloat convertScale = imageresizerFrame.size.width / adjustResizeFrame.size.width;
    CGFloat dx = -adjustResizeFrame.origin.x * convertScale;
    CGFloat dy = -adjustResizeFrame.origin.y * convertScale;
    CGRect convertZoomFrame = CGRectInset(imageresizerFrame, dx, dy);
    // 边沿检测，到顶就往外取值，防止有空隙
    CGRect convertImageresizerFrame = [self convertRect:imageresizerFrame toView:scrollView];
    BOOL isTheTop = fabs(convertImageresizerFrame.origin.y - imageView.frame.origin.y) < 1.0;
    BOOL isTheLead = fabs(convertImageresizerFrame.origin.x - imageView.frame.origin.x) < 1.0;
    BOOL isTheBottom = fabs(CGRectGetMaxY(convertImageresizerFrame) - CGRectGetMaxY(imageView.frame)) < 1.0;
    BOOL isTheTrail = fabs(CGRectGetMaxX(convertImageresizerFrame) - CGRectGetMaxX(imageView.frame)) < 1.0;
    if (isTheTop) convertZoomFrame.origin.y -= 1.0;
    if (isTheLead) convertZoomFrame.origin.x -= 1.0;
    if (isTheBottom) convertZoomFrame.size.height += 1.0;
    if (isTheTrail) convertZoomFrame.size.width += 1.0;
    CGRect zoomFrame = [self convertRect:convertZoomFrame toView:imageView];
    
    // contentInset
    UIEdgeInsets contentInset = [self scrollViewContentInsetWithAdjustResizeFrame:adjustResizeFrame];
    
    // contentOffset
    __block CGPoint contentOffset;
    if (isAdvanceUpdateOffset) {
        contentOffset = [self convertPoint:imageresizerFrame.origin toView:imageView];
        contentOffset.x = -contentInset.left + contentOffset.x * scrollView.zoomScale;
        contentOffset.y = -contentInset.top + contentOffset.y * scrollView.zoomScale;
    }
    
    // minimumZoomScale
    scrollView.minimumZoomScale = [self scrollViewMinZoomScaleWithResizeSize:adjustResizeFrame.size];
    
    __weak typeof(self) wSelf = self;
    void (^zoomBlock)(void) = ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [scrollView setContentInset:contentInset];
        if (isAdvanceUpdateOffset) {
            [scrollView setContentOffset:contentOffset animated:NO];
        }
        [scrollView zoomToRect:zoomFrame animated:NO];
        if (!isAdvanceUpdateOffset) {
            contentOffset = [sSelf convertPoint:sSelf.imageresizerFrame.origin toView:imageView];
            contentOffset.x = -contentInset.left + contentOffset.x * scrollView.zoomScale;
            contentOffset.y = -contentInset.top + contentOffset.y * scrollView.zoomScale;
            [scrollView setContentOffset:contentOffset animated:NO];
        }
    };
    void (^completeBlock)(void) = ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        sSelf.superview.userInteractionEnabled = YES;
        if (sSelf->_isToBeArbitrarily) {
            sSelf->_isToBeArbitrarily = NO;
            sSelf->_resizeWHScale = 0;
            sSelf->_isArbitrarily = YES;
        }
        [sSelf checkIsCanRecovery];
        sSelf.isPrepareToScale = NO;
    };
    
    self.superview.userInteractionEnabled = NO;
    [self hideOrShowBlurEffect:NO animateDuration:duration];
    [self hideOrShowFrameLine:NO animateDuration:duration];
    [self updateImageresizerFrame:adjustResizeFrame animateDuration:duration];
    if (duration > 0) {
        [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
            zoomBlock();
        } completion:^(BOOL finished) {
            completeBlock();
        }];
    } else {
        zoomBlock();
        completeBlock();
    }
}

- (UIEdgeInsets)scrollViewContentInsetWithAdjustResizeFrame:(CGRect)adjustResizeFrame {
    // scrollView宽高跟self一样，上下左右不需要额外添加Space
    CGFloat top = adjustResizeFrame.origin.y; // + veSpace?
    CGFloat bottom = self.bounds.size.height - CGRectGetMaxY(adjustResizeFrame); // + veSpace?
    CGFloat left = adjustResizeFrame.origin.x; // + hoSpace?
    CGFloat right = self.bounds.size.width - CGRectGetMaxX(adjustResizeFrame); // + hoSpace?
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (CGFloat)scrollViewMinZoomScaleWithResizeSize:(CGSize)size {
    CGFloat length;
    CGFloat baseLength;
    CGFloat width;
    CGFloat baseWidth;
    if (size.width >= size.height) {
        length = size.width;
        baseLength = _baseImageW;
        width = size.height;
        baseWidth = _baseImageH;
    } else {
        length = size.height;
        baseLength = _baseImageH;
        width = size.width;
        baseWidth = _baseImageW;
    }
    CGFloat minZoomScale = length / baseLength;
    CGFloat scaleWidth = baseWidth * minZoomScale;
    if (scaleWidth < width) {
        minZoomScale *= (width / scaleWidth);
    }
    return minZoomScale;
}

- (void)checkIsCanRecovery {
    if (self.resizeWHScale != self.initialResizeWHScale) {
        self.isCanRecovery = YES;
        return;
    }
    
    BOOL isVerticalityMirror = self.isVerticalityMirror ? self.isVerticalityMirror() : NO;
    BOOL isHorizontalMirror = self.isHorizontalMirror ? self.isHorizontalMirror() : NO;
    if (isVerticalityMirror || isHorizontalMirror) {
        self.isCanRecovery = YES;
        return;
    }
    
    CGPoint convertCenter = [self convertPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) toView:self.imageView];
    CGPoint imageViewCenter = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
    BOOL isSameCenter = labs((NSInteger)convertCenter.x - (NSInteger)imageViewCenter.x) <= 1 && labs((NSInteger)convertCenter.y - (NSInteger)imageViewCenter.y) <= 1;
    BOOL isOriginFrame = self.rotationDirection == JPImageresizerVerticalUpDirection && [self imageresizerFrameIsEqualImageViewFrame];
    self.isCanRecovery = !isOriginFrame || !isSameCenter;
}

#pragma mark - puild method

- (void)updateFrameType:(JPImageresizerFrameType)frameType {
    if (self.frameType == frameType) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.frameType = frameType;
    [CATransaction commit];
}

- (void)updateImageresizerFrameWithVerBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin {
    _verBaseMargin = verBaseMargin;
    _horBaseMargin = horBaseMargin;
    self.layer.transform = CATransform3DIdentity;
    [self updateImageOriginFrameWithDirection:JPImageresizerVerticalUpDirection];
}

- (void)startImageresizer {
    self.isPrepareToScale = YES;
    [self removeTimer];
    [self hideOrShowBlurEffect:YES animateDuration:_defaultDuration];
    [self hideOrShowFrameLine:YES animateDuration:_defaultDuration];
}

- (void)endedImageresizer {
    UIEdgeInsets contentInset = [self scrollViewContentInsetWithAdjustResizeFrame:self.imageresizerFrame];
    self.scrollView.contentInset = contentInset;
    [self addTimer];
}

- (void)rotationWithDirection:(JPImageresizerRotationDirection)direction rotationDuration:(NSTimeInterval)rotationDuration {
    [self removeTimer];
    [self updateRotationDirection:direction];
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:rotationDuration];
}

- (void)willMirror:(BOOL)animated {
    self.window.userInteractionEnabled = NO;
    if (animated) [self hideOrShowBlurEffect:YES animateDuration:-1.0];
}

- (void)verticalityMirrorWithDiffX:(CGFloat)diffX {
    CGFloat w = [self isHorizontalDirection:_rotationDirection] ? self.bounds.size.height : self.bounds.size.width;
    CGFloat x = (_contentSize.width - w) * 0.5 + diffX;
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.scrollView.frame = frame;
    self.frame = frame;
}

- (void)horizontalMirrorWithDiffY:(CGFloat)diffY {
    CGFloat h = [self isHorizontalDirection:_rotationDirection] ? self.bounds.size.width : self.bounds.size.height;
    CGFloat y = (_contentSize.height - h) * 0.5 + diffY;
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.scrollView.frame = frame;
    self.frame = frame;
}

- (void)mirrorDone {
    [self hideOrShowBlurEffect:NO animateDuration:_defaultDuration];
    [self checkIsCanRecovery];
    self.window.userInteractionEnabled = YES;
}

- (void)willRecoveryByResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily {
    self.window.userInteractionEnabled = NO;
    [self removeTimer];
    _resizeWHScale = resizeWHScale;
    _isArbitrarily = resizeWHScale <= 0;
    _isToBeArbitrarily = isToBeArbitrarily;
}

- (void)recoveryWithDuration:(NSTimeInterval)duration {
    self.isShowMidDot = _isToBeArbitrarily ? YES : _isArbitrarily;
    
    [self updateRotationDirection:JPImageresizerVerticalUpDirection];
    
    CGRect adjustResizeFrame = _isArbitrarily ? [self baseImageresizerFrame] : [self adjustResizeFrame];
    
    UIEdgeInsets contentInset = [self scrollViewContentInsetWithAdjustResizeFrame:adjustResizeFrame];
    
    CGFloat minZoomScale = [self scrollViewMinZoomScaleWithResizeSize:adjustResizeFrame.size];
    
    CGFloat offsetX = -contentInset.left + (_baseImageW * minZoomScale - adjustResizeFrame.size.width) * 0.5;
    CGFloat offsetY = -contentInset.top + (_baseImageH * minZoomScale - adjustResizeFrame.size.height) * 0.5;
    CGPoint contentOffset = CGPointMake(offsetX, offsetY);
    
    [self updateImageresizerFrame:adjustResizeFrame animateDuration:duration];
    
    self.scrollView.minimumZoomScale = minZoomScale;
    self.scrollView.zoomScale = minZoomScale;
    self.scrollView.contentInset = contentInset;
    self.scrollView.contentOffset = contentOffset;
}

- (void)recoveryDone {
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:-1.0];
    self.window.userInteractionEnabled = YES;
}

- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete scale:(CGFloat)scale {
    if (!complete) return;
    
    if (scale <= 0) {
        complete(nil);
        return;
    }
    
    /**
     * UIImageOrientationUp --------- default orientation
     * UIImageOrientationDown ----- 180 deg rotation
     * UIImageOrientationLeft -------- 90 deg CCW
     * UIImageOrientationRight ------ 90 deg CW
     */
    UIImageOrientation orientation;
    switch (self.rotationDirection) {
        case JPImageresizerHorizontalLeftDirection:
            orientation = UIImageOrientationLeft;
            break;
        case JPImageresizerVerticalDownDirection:
            orientation = UIImageOrientationDown;
            break;
        case JPImageresizerHorizontalRightDirection:
            orientation = UIImageOrientationRight;
            break;
        default:
            orientation = UIImageOrientationUp;
            break;
    }
    
    BOOL isVerticalityMirror = self.isVerticalityMirror ? self.isVerticalityMirror() : NO;
    BOOL isHorizontalMirror = self.isHorizontalMirror ? self.isHorizontalMirror() : NO;
    if ([self isHorizontalDirection:_rotationDirection]) {
        BOOL temp = isVerticalityMirror;
        isVerticalityMirror = isHorizontalMirror;
        isHorizontalMirror = temp;
    }
    
    __block UIImage *image = self.imageView.image;
    
    CGRect imageViewBounds = self.imageView.bounds;
    CGFloat imageViewWidth = imageViewBounds.size.width;
    
    CGRect cropFrame = (self.isCanRecovery || self.resizeWHScale > 0) ? [self convertRect:self.imageresizerFrame toView:self.imageView] : imageViewBounds;
    
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        // 修正图片方向
        image = [image jp_fixOrientation];
        
        // 镜像处理
        if (isVerticalityMirror) image = [image jp_verticalityMirror];
        if (isHorizontalMirror) image = [image jp_horizontalMirror];
        
        // 获取裁剪区域
        CGFloat imageScale = image.scale;
        CGFloat imageWidth = image.size.width * imageScale;
        CGFloat imageHeight = image.size.height * imageScale;
        // 宽高比不变，所以宽度高度的比例是一样
        CGFloat cropScale = imageWidth / imageViewWidth;
        CGFloat cropX = cropFrame.origin.x * cropScale;
        CGFloat cropY = cropFrame.origin.y * cropScale;
        CGFloat cropW = cropFrame.size.width * cropScale;
        CGFloat cropH = cropFrame.size.height * cropScale;
        if (cropX < 0) {
            cropW += -cropX;
            cropX = 0;
        }
        if (cropY < 0) {
            cropH += -cropY;
            cropY = 0;
        }
        CGFloat cropMaxX = cropX + cropW;
        if (cropMaxX > imageWidth) {
            cropW -= (cropMaxX - imageWidth);
            cropMaxX = cropX + cropW;
        }
        CGFloat cropMaxY = cropY + cropH;
        if (cropMaxY > imageHeight) {
            cropH -= (cropMaxY - imageHeight);
            cropMaxY = cropY + cropH;
        }
        if (isVerticalityMirror) cropX = imageWidth - cropMaxX;
        if (isHorizontalMirror) cropY = imageHeight - cropMaxY;
        CGRect cropRect = CGRectMake(cropX, cropY, cropW, cropH);
        
        // 裁剪并旋转图片
        CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
        image = [[UIImage imageWithCGImage:imgRef] jp_rotate:orientation];
        CGImageRelease(imgRef);
        
        // 压缩图片
        if (scale < 1.0) image = [image jp_resizeImageWithScale:scale];
        
        // 输出压缩图片
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(image);
        });
    });
}

#pragma mark - UIPanGestureRecognizer

- (void)panHandle:(UIPanGestureRecognizer *)panGR {
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self startImageresizer];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self panChangedHandleWithTranslation:[panGR translationInView:self]];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self endedImageresizer];
            break;
        }
        default:
            break;
    }
    [panGR setTranslation:CGPointZero inView:self];
}

- (void)panChangedHandleWithTranslation:(CGPoint)translation {
    
    CGFloat x = _imageresizerFrame.origin.x;
    CGFloat y = _imageresizerFrame.origin.y;
    CGFloat w = _imageresizerFrame.size.width;
    CGFloat h = _imageresizerFrame.size.height;
    
    switch (_currHorn) {
            
        case JPLeftTop: {
            if (_isArbitrarily) {
                x += translation.x;
                y += translation.y;
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                
                w = _diagonal.x - x;
                h = _diagonal.y - y;
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                    x = _diagonal.x - w;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                    y = _diagonal.y - h;
                }
            } else {
                x += translation.x;
                w = _diagonal.x - x;
                
                if (translation.x != 0) {
                    CGFloat diff = translation.x / _resizeWHScale;
                    y += diff;
                    h = _diagonal.y - y;
                }
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                    w = _diagonal.x - x;
                    h = w / _resizeWHScale;
                    y = _diagonal.y - h;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                    h = _diagonal.y - y;
                    w = h * _resizeWHScale;
                    x = _diagonal.x - w;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x - w;
                    y = _diagonal.y - h;
                }
            }
            
            break;
        }
            
        case JPLeftBottom: {
            if (_isArbitrarily) {
                x += translation.x;
                h += translation.y;
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                }
                
                w = _diagonal.x - x;
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                    x = _diagonal.x - w;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                }
            } else {
                x += translation.x;
                w = _diagonal.x - x;
                
                if (translation.x != 0) {
                    h = w / _resizeWHScale;
                }
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                    w = _diagonal.x - x;
                    h = w / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                    w = h * _resizeWHScale;
                    x = _diagonal.x - w;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x - w;
                    y = _diagonal.y;
                }
            }
            
            break;
        }
            
        case JPRightTop: {
            if (_isArbitrarily) {
                y += translation.y;
                w += translation.x;
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                }
                
                h = _diagonal.y - y;
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                    y = _diagonal.y - h;
                }
            } else {
                w += translation.x;
                
                if (translation.x != 0) {
                    CGFloat diff = translation.x / _resizeWHScale;
                    y -= diff;
                    h = _diagonal.y - y;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                    h = _diagonal.y - y;
                    w = h * _resizeWHScale;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                    h = w / _resizeWHScale;
                    y = _diagonal.y - h;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x;
                    y = _diagonal.y - h;
                }
            }
            
            break;
        }
            
        case JPRightBottom: {
            if (_isArbitrarily) {
                w += translation.x;
                h += translation.y;
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                }
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                }
            } else {
                w += translation.x;
                
                if (translation.x != 0) {
                    h = w / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                    h = w / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                    w = h * _resizeWHScale;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x;
                    y = _diagonal.y;
                }
            }
            
            break;
        }
            
        case JPLeftMid: {
            x += translation.x;
            
            if (x < self.maxResizeX) {
                x = self.maxResizeX;
            }
            
            w = _diagonal.x - x;
            
            if (w < _minImageWH) {
                w = _minImageWH;
                x = _diagonal.x - w;
            }
            break;
        }
            
        case JPRightMid: {
            w += translation.x;
            
            CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
            if ((x + w) > maxResizeMaxX) {
                w = maxResizeMaxX - _diagonal.x;
            }
            
            if (w < _minImageWH) {
                w = _minImageWH;
            }
            break;
        }
            
        case JPTopMid: {
            y += translation.y;
            
            if (y < self.maxResizeY) {
                y = self.maxResizeY;
            }
            
            h = _diagonal.y - y;
            
            if (h < _minImageWH) {
                h = _minImageWH;
                y = _diagonal.y - h;
            }
            break;
        }
            
        case JPBottomMid: {
            h += translation.y;
            
            CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
            if ((y + h) > maxResizeMaxY) {
                h = maxResizeMaxY - _diagonal.y;
            }
            
            if (h < _minImageWH) {
                h = _minImageWH;
            }
            break;
        }
            
        default:
            break;
    }
    
    CGRect imageresizerFrame = CGRectMake(x, y, w, h);
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat wZoomScale = 0;
    CGFloat hZoomScale = 0;
    if (w > _startResizeW) {
        wZoomScale = w / _baseImageW;
    }
    if (h > _startResizeH) {
        hZoomScale = h / _baseImageH;
    }
    CGFloat maxZoomScale = MAX(wZoomScale, hZoomScale);
    if (maxZoomScale > zoomScale) {
        zoomScale = maxZoomScale;
    }
    if (zoomScale != self.scrollView.zoomScale) {
        [self.scrollView setZoomScale:zoomScale animated:NO];
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGSize contentSize = self.scrollView.contentSize;
    CGRect convertFrame = [self convertRect:imageresizerFrame toView:self.scrollView];
    if (convertFrame.origin.x < 0) {
        contentOffset.x -= convertFrame.origin.x;
    } else if (CGRectGetMaxX(convertFrame) > contentSize.width) {
        contentOffset.x -= CGRectGetMaxX(convertFrame) - contentSize.width;
    }
    if (convertFrame.origin.y < 0) {
        contentOffset.y -= convertFrame.origin.y;
    } else if (CGRectGetMaxY(convertFrame) > contentSize.height) {
        contentOffset.y -= CGRectGetMaxY(convertFrame) - contentSize.height;
    }
    if (!CGPointEqualToPoint(contentOffset, self.scrollView.contentOffset)) {
        [self.scrollView setContentOffset:contentOffset animated:NO];
    }
    
    self.imageresizerFrame = imageresizerFrame;
}

#pragma mark - super method

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.panGR.enabled) {
        _currHorn = JPCenter;
        return NO;
    }
    
    CGRect frame = _imageresizerFrame;
    CGFloat scopeWH = _scopeWH;
    CGFloat halfScopeWH = scopeWH * 0.5;
    
    if (self.edgeLineIsEnabled &&
        (!CGRectContainsPoint(CGRectInset(frame, -halfScopeWH, -halfScopeWH), point) ||
         CGRectContainsPoint(CGRectInset(frame, halfScopeWH, halfScopeWH), point))) {
        _currHorn = JPCenter;
        return NO;
    }
    
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    CGFloat maxX = CGRectGetMaxX(frame);
    CGFloat maxY = CGRectGetMaxY(frame);
    
    CGRect leftTopRect = CGRectMake(x - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect leftBotRect = CGRectMake(x - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    CGRect rightTopRect = CGRectMake(maxX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect rightBotRect = CGRectMake(maxX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    if (CGRectContainsPoint(leftTopRect, point)) {
        _currHorn = JPLeftTop;
        _diagonal = CGPointMake(maxX, maxY);
    } else if (CGRectContainsPoint(leftBotRect, point)) {
        _currHorn = JPLeftBottom;
        _diagonal = CGPointMake(maxX, y);
    } else if (CGRectContainsPoint(rightTopRect, point)) {
        _currHorn = JPRightTop;
        _diagonal = CGPointMake(x, maxY);
    } else if (CGRectContainsPoint(rightBotRect, point)) {
        _currHorn = JPRightBottom;
        _diagonal = CGPointMake(x, y);
    } else if (_isArbitrarily) {
        CGRect leftMidRect = CGRectNull;
        CGRect rightMidRect = CGRectNull;
        CGRect topMidRect = CGRectNull;
        CGRect botMidRect = CGRectNull;
        CGFloat midX = CGRectGetMidX(frame);
        CGFloat midY = CGRectGetMidY(frame);
        if (_edgeLineIsEnabled) {
            leftMidRect = CGRectMake(x - halfScopeWH, y + halfScopeWH, scopeWH, h - scopeWH);
            rightMidRect = CGRectMake(maxX - halfScopeWH, y + halfScopeWH, scopeWH, h - scopeWH);
            topMidRect = CGRectMake(x + halfScopeWH, y - halfScopeWH, w - scopeWH, scopeWH);
            botMidRect = CGRectMake(x + halfScopeWH, maxY - halfScopeWH, w - scopeWH, scopeWH);
        } else if (self.isShowMidDot) {
            leftMidRect = CGRectMake(x - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
            rightMidRect = CGRectMake(maxX - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
            topMidRect = CGRectMake(midX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
            botMidRect = CGRectMake(midX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
        }
        if (CGRectContainsPoint(leftMidRect, point)) {
            _currHorn = JPLeftMid;
            _diagonal = CGPointMake(maxX, midY);
        } else if (CGRectContainsPoint(rightMidRect, point)) {
            _currHorn = JPRightMid;
            _diagonal = CGPointMake(x, midY);
        } else if (CGRectContainsPoint(topMidRect, point)) {
            _currHorn = JPTopMid;
            _diagonal = CGPointMake(midX, maxY);
        } else if (CGRectContainsPoint(botMidRect, point)) {
            _currHorn = JPBottomMid;
            _diagonal = CGPointMake(midX, y);
        } else {
            _currHorn = JPCenter;
            return NO;
        }
    } else {
        _currHorn = JPCenter;
        return NO;
    }
    
    _startResizeW = w;
    _startResizeH = h;
    return YES;
}

@end
