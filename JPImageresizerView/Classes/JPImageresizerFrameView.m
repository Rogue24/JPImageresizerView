//
//  JPImageresizerFrameView.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/11.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerFrameView.h"
#import "JPImageresizerView.h"

/** keypath */
#define aKeyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))

struct JPRGBAColor {
    CGFloat jp_r;
    CGFloat jp_g;
    CGFloat jp_b;
    CGFloat jp_a;
};

typedef NS_ENUM(NSUInteger, RectHorn) {
    Center,
    LeftTop,
    LeftMid,
    LeftBottom,
    
    RightTop,
    RightMid,
    RightBottom,
    
    TopMid,
    BottomMid
};

@interface JPImageresizerFrameView ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) JPImageMaskView *imageView;

@property (nonatomic, weak) CAShapeLayer *bgLayer;
@property (nonatomic, weak) CAShapeLayer *frameLayer;

@property (nonatomic, weak) CAShapeLayer *leftTopDot;
@property (nonatomic, weak) CAShapeLayer *leftMidDot;
@property (nonatomic, weak) CAShapeLayer *leftBottomDot;

@property (nonatomic, weak) CAShapeLayer *rightTopDot;
@property (nonatomic, weak) CAShapeLayer *rightMidDot;
@property (nonatomic, weak) CAShapeLayer *rightBottomDot;

@property (nonatomic, weak) CAShapeLayer *topMidDot;
@property (nonatomic, weak) CAShapeLayer *bottomMidDot;

@property (nonatomic, assign) CGRect originImageFrame;

@property (nonatomic, assign) RectHorn currHorn;
@property (nonatomic, assign) CGPoint diagonal;

@property (nonatomic, strong) NSTimer *timer;

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
    NSTimeInterval _defaultDuration;
    
    CGFloat _dotWH;
    CGFloat _scopeWH;
    CGFloat _minImageWH;
    
    CGFloat _baseImageW;
    CGFloat _baseImageH;
    
    CGFloat _startResizeW;
    CGFloat _startResizeH;
    
    BOOL _isArbitrarily;
    CGFloat _sizeScale;
    
    UIColor *_clearColor;
    struct JPRGBAColor _fillRgba;
    BOOL _isHasFillColor;
    
    CGFloat _originWHScale;
    
    CGRect _imageMaskFrame;
}

#pragma mark - setter

- (void)setOriginImageFrame:(CGRect)originImageFrame {
    _originImageFrame = originImageFrame;
    _originWHScale = originImageFrame.size.width / originImageFrame.size.height;
}

- (void)setMaxResizeFrame:(CGRect)maxResizeFrame {
    _maxResizeFrame = maxResizeFrame;
    [self updateImageOriginFrame];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillRgba = [self createRgbaWithColor:fillColor];
    _fillColor = [UIColor colorWithRed:_fillRgba.jp_r green:_fillRgba.jp_g blue:_fillRgba.jp_b alpha:_fillRgba.jp_a];
    _clearColor = [UIColor colorWithRed:_fillRgba.jp_r green:_fillRgba.jp_g blue:_fillRgba.jp_b alpha:0];
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    if (_maskAlpha == maskAlpha) return;
    _maskAlpha = maskAlpha;
    if (maskAlpha == 0) {
        _isHasFillColor = NO;
        _fillColor = _clearColor;
    } else {
        _isHasFillColor = YES;
        _fillRgba.jp_a = maskAlpha;
        _fillColor = [UIColor colorWithRed:_fillRgba.jp_r green:_fillRgba.jp_g blue:_fillRgba.jp_b alpha:_fillRgba.jp_a];
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.bgLayer.fillColor = _fillColor.CGColor;
    [CATransaction commit];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.frameLayer.strokeColor = strokeColor.CGColor;
    self.leftTopDot.fillColor = strokeColor.CGColor;
    self.leftMidDot.fillColor = strokeColor.CGColor;
    self.leftBottomDot.fillColor = strokeColor.CGColor;
    self.rightTopDot.fillColor = strokeColor.CGColor;
    self.rightMidDot.fillColor = strokeColor.CGColor;
    self.rightBottomDot.fillColor = strokeColor.CGColor;
    self.topMidDot.fillColor = strokeColor.CGColor;
    self.bottomMidDot.fillColor = strokeColor.CGColor;
    [CATransaction commit];
}

- (void)setImageresizerFrame:(CGRect)imageresizerFrame {
    [self setImageresizerFrame:imageresizerFrame animateDuration:-1.0];
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
    if (_resizeWHScale == resizeWHScale) return;
    _resizeWHScale = resizeWHScale;
    _isArbitrarily = resizeWHScale <= 0;
    
    CGFloat midDotOpacity = 1;
    if (!_isArbitrarily) midDotOpacity = 0;
    self.leftMidDot.opacity = midDotOpacity;
    self.rightMidDot.opacity = midDotOpacity;
    self.topMidDot.opacity = midDotOpacity;
    self.bottomMidDot.opacity = midDotOpacity;
    
    if (self.superview) {
        [self updateImageOriginFrame];
    }
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
    CGFloat w = ((NSInteger)(self.imageView.frame.size.width * _sizeScale)) * 1.0;
    CGFloat h = ((NSInteger)(self.imageView.frame.size.height * _sizeScale)) * 1.0;
    if (self.rotationDirection == JPImageresizerVerticalUpDirection ||
        self.rotationDirection == JPImageresizerVerticalDownDirection) {
        return CGSizeMake(w, h);
    } else {
        return CGSizeMake(h, w);
    }
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
                  strokeColor:(UIColor *)strokeColor
                    fillColor:(UIColor *)fillColor
                    maskAlpha:(CGFloat)maskAlpha
               maxResizeFrame:(CGRect)maxResizeFrame
                resizeWHScale:(CGFloat)resizeWHScale
                   scrollView:(UIScrollView *)scrollView
                    imageView:(JPImageMaskView *)imageView
    imageresizerIsCanRecovery:(void(^)(BOOL isCanRecovery))imageresizerIsCanRecovery {
    
    if (self = [super initWithFrame:frame]) {
        
        _defaultDuration = 0.25;
        _dotWH = 10.0;
        _minImageWH = 70.0;
        _scopeWH = 50.0;
        
        _maskAlpha = maskAlpha;
        _maxResizeFrame = maxResizeFrame;
        _imageresizerIsCanRecovery = [imageresizerIsCanRecovery copy];
        _imageMaskFrame = CGRectNull;
        
        CAShapeLayer * (^createShapeLayer)(void) = ^{
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.frame = self.bounds;
            [self.layer addSublayer:layer];
            return layer;
        };
        
        CAShapeLayer *bgLayer = createShapeLayer();
        bgLayer.lineWidth = 0;
        bgLayer.fillRule = kCAFillRuleEvenOdd;
        self.bgLayer = bgLayer;
        
        CAShapeLayer *frameLayer = createShapeLayer();
        frameLayer.lineWidth = 1.0;
        frameLayer.fillColor = [UIColor clearColor].CGColor;
        self.frameLayer = frameLayer;
        
        self.leftTopDot = createShapeLayer();
        self.leftBottomDot = createShapeLayer();
        
        self.rightTopDot = createShapeLayer();
        self.rightBottomDot = createShapeLayer();
        
        self.leftMidDot = createShapeLayer();
        self.rightMidDot = createShapeLayer();
        self.topMidDot = createShapeLayer();
        self.bottomMidDot = createShapeLayer();
        
        self.scrollView = scrollView;
        self.imageView = imageView;
        
        self.strokeColor = strokeColor;
        self.fillColor = fillColor;
        [self updateRotationDirection:JPImageresizerVerticalUpDirection];
        
        if (resizeWHScale == 0) _resizeWHScale = -1.0;
        self.resizeWHScale = resizeWHScale;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark - life cycle

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self updateImageOriginFrame];
}

- (void)dealloc {
    self.window.userInteractionEnabled = YES;
    [self removeTimer];
}

#pragma mark - timer

- (void)addTimer {
    [self removeTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.65 target:self selector:@selector(timerHandle) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerHandle {
    [self removeTimer];
    [self updateImageresizerFrameWithAnimateDuration:_defaultDuration isAdjustResize:YES];
}

#pragma mark - assist method

- (UIBezierPath *)dotPathWithPosition:(CGPoint)position {
    UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(position.x - _dotWH * 0.5, position.y - _dotWH * 0.5, _dotWH, _dotWH)];
    return dotPath;
}

- (BOOL)imageresizerFrameIsFullImageViewFrame {
    CGSize imageresizerSize = self.imageresizerSize;
    CGSize imageViewSzie = self.imageViewSzie;
    return (fabs(imageresizerSize.width - imageViewSzie.width) <= 1 &&
            fabs(imageresizerSize.height - imageViewSzie.height) <= 1);
}

- (BOOL)imageresizerFrameIsEqualImageViewFrame {
    CGSize imageresizerSize = self.imageresizerSize;
    CGSize imageViewSzie = self.imageViewSzie;
    if (_isArbitrarily || (_resizeWHScale == _originWHScale)) {
        return (fabs(imageresizerSize.width - imageViewSzie.width) <= 1 &&
                fabs(imageresizerSize.height - imageViewSzie.height) <= 1);
    } else {
        return (fabs(imageresizerSize.width - imageViewSzie.width) <= 1 ||
                fabs(imageresizerSize.height - imageViewSzie.height) <= 1);
    }
}

#pragma mark - private method

- (struct JPRGBAColor)createRgbaWithColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    struct JPRGBAColor rgba;
    rgba.jp_r = r;
    rgba.jp_g = g;
    rgba.jp_b = b;
    rgba.jp_a = a * _maskAlpha;
    return rgba;
}

- (void)hideOrShowFillColor:(BOOL)isHide animateDuration:(NSTimeInterval)duration {
    _isHasFillColor = !isHide;
    UIColor *toColor = isHide ? _clearColor : _fillColor;
    if (duration > 0 && ![self imageresizerFrameIsFullImageViewFrame]) {
        UIColor *fromColor = isHide ? _fillColor : _clearColor;
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:aKeyPath(self.bgLayer, fillColor)];
        anim.fillMode = kCAFillModeBackwards;
        anim.fromValue = fromColor;
        anim.toValue = toColor;
        anim.duration = duration;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.bgLayer addAnimation:anim forKey:@"fillColor"];
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.bgLayer.fillColor = toColor.CGColor;
    [CATransaction commit];
}

- (void)setImageresizerFrame:(CGRect)imageresizerFrame animateDuration:(NSTimeInterval)duration {
    _imageresizerFrame = imageresizerFrame;
    
    CGFloat imageresizerX = imageresizerFrame.origin.x;
    CGFloat imageresizerY = imageresizerFrame.origin.y;
    CGFloat imageresizerMidX = CGRectGetMidX(imageresizerFrame);
    CGFloat imageresizerMidY = CGRectGetMidY(imageresizerFrame);
    CGFloat imageresizerMaxX = CGRectGetMaxX(imageresizerFrame);
    CGFloat imageresizerMaxY = CGRectGetMaxY(imageresizerFrame);
    
    UIBezierPath *leftTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerY)];
    UIBezierPath *leftMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMidY)];
    UIBezierPath *leftBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMaxY)];
    
    UIBezierPath *rightTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerY)];
    UIBezierPath *rightMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMidY)];
    UIBezierPath *rightBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMaxY)];
    
    UIBezierPath *topMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerY)];
    UIBezierPath *bottomMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerMaxY)];
    
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRect:imageresizerFrame];
    [bgPath appendPath:framePath];
    
    if (duration > 0) {
        
        void (^layerPathAnimate)(CAShapeLayer *layer, UIBezierPath *path) = ^(CAShapeLayer *layer, UIBezierPath *path) {
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:aKeyPath(layer, path)];
            anim.fillMode = kCAFillModeBackwards;
            anim.fromValue = [UIBezierPath bezierPathWithCGPath:layer.path];
            anim.toValue = path;
            anim.duration = duration;
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [layer addAnimation:anim forKey:@"path"];
        };
        
        layerPathAnimate(self.bgLayer, bgPath);
        layerPathAnimate(self.frameLayer, framePath);
        
        layerPathAnimate(self.leftTopDot, leftTopDotPath);
        layerPathAnimate(self.leftMidDot, leftMidDotPath);
        layerPathAnimate(self.leftBottomDot, leftBottomDotPath);
        
        layerPathAnimate(self.rightTopDot, rightTopDotPath);
        layerPathAnimate(self.rightMidDot, rightMidDotPath);
        layerPathAnimate(self.rightBottomDot, rightBottomDotPath);
        
        layerPathAnimate(self.topMidDot, topMidDotPath);
        layerPathAnimate(self.bottomMidDot, bottomMidDotPath);
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.leftTopDot.path = leftTopDotPath.CGPath;
    self.leftMidDot.path = leftMidDotPath.CGPath;
    self.leftBottomDot.path = leftBottomDotPath.CGPath;
    
    self.rightTopDot.path = rightTopDotPath.CGPath;
    self.rightMidDot.path = rightMidDotPath.CGPath;
    self.rightBottomDot.path = rightBottomDotPath.CGPath;
    
    self.topMidDot.path = topMidDotPath.CGPath;
    self.bottomMidDot.path = bottomMidDotPath.CGPath;
    
    self.bgLayer.path = bgPath.CGPath;
    self.frameLayer.path = framePath.CGPath;
    
    [CATransaction commit];
}

- (void)resetImageresizerFrame {
    if (_isArbitrarily) {
        self.imageresizerFrame = self.originImageFrame;
    } else {
        CGFloat w = self.originImageFrame.size.width;
        CGFloat h = w / _resizeWHScale;
        if (h > self.maxResizeH) {
            h = self.maxResizeH;
            w = h * _resizeWHScale;
        }
        CGFloat x = self.maxResizeX + (self.maxResizeW - w) * 0.5;
        CGFloat y = self.maxResizeY + (self.maxResizeH - h) * 0.5;
        self.imageresizerFrame = CGRectMake(x, y, w, h);
    }
}

- (void)updateImageOriginFrame {
    [self removeTimer];
    self.originImageFrame = [self.imageView convertRect:self.imageView.bounds toView:self];
    [self resetImageresizerFrame];
    [self updateRotationDirection:JPImageresizerVerticalUpDirection];
    [self updateImageresizerFrameWithAnimateDuration:-1.0 isAdjustResize:YES];
}

- (void)updateImageresizerFrameWithAnimateDuration:(NSTimeInterval)duration isAdjustResize:(BOOL)adjustResize {
    if (self.imageresizeX < self.maxResizeX) self.imageresizeX = self.maxResizeX;
    if (self.imageresizeY < self.maxResizeY) self.imageresizeY = self.maxResizeY;
    if (_isArbitrarily) {
        if (self.imageresizeW > self.maxResizeW) self.imageresizeW = self.maxResizeW;
        if (self.imageresizeH > self.maxResizeH) self.imageresizeH = self.maxResizeH;
    } else {
        if (self.imageresizeW > self.maxResizeW) {
            self.imageresizeW = self.maxResizeW;
            self.imageresizeH = self.imageresizeW / _resizeWHScale;
        }
        if (self.imageresizeH > self.maxResizeH) {
            self.imageresizeH = self.maxResizeH;
            self.imageresizeW = self.imageresizeH * _resizeWHScale;
        }
    }
    
    CGFloat adjustResizeW = 0;
    CGFloat adjustResizeH = 0;
    CGFloat adjustResizeX = 0;
    CGFloat adjustResizeY = 0;
    if (adjustResize) {
        CGFloat resizerWHScale = _isArbitrarily ? (self.imageresizeW / self.imageresizeH) : _resizeWHScale;
        adjustResizeW = 0;
        adjustResizeH = 0;
        if (resizerWHScale >= 1) {
            adjustResizeW = self.maxResizeW;
            adjustResizeH = adjustResizeW / resizerWHScale;
            if (adjustResizeH > self.maxResizeH) {
                adjustResizeH = self.maxResizeH;
                adjustResizeW = self.maxResizeH * resizerWHScale;
            }
        } else {
            adjustResizeH = self.maxResizeH;
            adjustResizeW = adjustResizeH * resizerWHScale;
            if (adjustResizeW > self.maxResizeW) {
                adjustResizeW = self.maxResizeW;
                adjustResizeH = adjustResizeW / resizerWHScale;
            }
        }
        adjustResizeX = self.maxResizeX + (self.maxResizeW - adjustResizeW) * 0.5;
        adjustResizeY = self.maxResizeY + (self.maxResizeH - adjustResizeH) * 0.5;
    } else {
        adjustResizeW = self.imageresizerFrame.size.width;
        adjustResizeH = self.imageresizerFrame.size.height;
        adjustResizeX = self.imageresizerFrame.origin.x;
        adjustResizeY = self.imageresizerFrame.origin.y;
    }
    CGRect adjustResizeFrame = CGRectMake(adjustResizeX, adjustResizeY, adjustResizeW, adjustResizeH);
    
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    // contentInset
    CGFloat top = 0;
    CGFloat left = 0;
    CGFloat bottom = 0;
    CGFloat right = 0;
    if (self.rotationDirection == JPImageresizerVerticalUpDirection ||
        self.rotationDirection == JPImageresizerVerticalDownDirection) {
        CGFloat hoSpace = (self.scrollView.bounds.size.width - selfWidth) * 0.5;
        // scrollView高度跟self.height一样，上下不需要额外添加veSpace
        top = adjustResizeY; // + veSpace?
        bottom = selfHeight - CGRectGetMaxY(adjustResizeFrame); // + veSpace?
        left = adjustResizeX + hoSpace;
        right = selfWidth - CGRectGetMaxX(adjustResizeFrame) + hoSpace;
    } else {
        CGFloat veSpace = (self.scrollView.bounds.size.height - selfHeight) * 0.5;
        top = adjustResizeX + veSpace;
        bottom = selfWidth - CGRectGetMaxX(adjustResizeFrame) + veSpace;
        // scrollView翻转后的宽度跟self.height一样，左右不需要额外添加hoSpace
        left = selfHeight - CGRectGetMaxY(adjustResizeFrame);
        right = adjustResizeY;
    }
    // 打横之后，scrollView整体缩小，要除以倍率获取相对于scrollView的真实值
    top /= _sizeScale;
    left /= _sizeScale;
    bottom /= _sizeScale;
    right /= _sizeScale;
    UIEdgeInsets contentInset = UIEdgeInsetsMake(top, left, bottom, right);
    
    // contentOffset
    CGPoint contentOffset = CGPointZero;
    CGPoint origin;
    switch (self.rotationDirection) {
        case JPImageresizerHorizontalLeftDirection:
            origin = CGPointMake(self.imageresizeX, CGRectGetMaxY(self.imageresizerFrame));
            break;
        case JPImageresizerVerticalDownDirection:
            origin = CGPointMake(CGRectGetMaxX(self.imageresizerFrame), CGRectGetMaxY(self.imageresizerFrame));
            break;
        case JPImageresizerHorizontalRightDirection:
            origin = CGPointMake(CGRectGetMaxX(self.imageresizerFrame), self.imageresizeY);
            break;
        default:
            origin = self.imageresizerFrame.origin;
            break;
    }
    CGPoint convertPoint = [self convertPoint:origin toView:self.imageView];
    // 这个convertPoint是相对self.image.bounds上的点，所以要✖️zoomScale拿到相对frame实际显示的大小
    contentOffset.x = -contentInset.left + convertPoint.x * self.scrollView.zoomScale;
    contentOffset.y = -contentInset.top + convertPoint.y * self.scrollView.zoomScale;
    
    // zoomFrame
    // 根据裁剪的区域，因为需要有间距，所以拼接成self的尺寸获取缩放的区域zoomFrame
    // 宽高比不变，所以宽度高度的比例是一样，这里就用宽度比例吧
    CGFloat convertScale = self.imageresizeW / adjustResizeW;
    CGFloat diffXSpace = adjustResizeX * convertScale;
    CGFloat diffYSpace = adjustResizeY * convertScale;
    CGFloat convertW = self.imageresizeW + 2 * diffXSpace;
    CGFloat convertH = self.imageresizeH + 2 * diffYSpace;
    CGFloat convertX = self.imageresizeX - diffXSpace;
    CGFloat convertY = self.imageresizeY - diffYSpace;
    CGRect zoomFrame = [self convertRect:CGRectMake(convertX, convertY, convertW, convertH) toView:self.imageView];
    
    void (^zoomBlock)(void) = ^{
        self.scrollView.contentOffset = contentOffset;
        self.scrollView.contentInset = contentInset;
        [self.scrollView zoomToRect:zoomFrame animated:NO];
    };
    
    void (^completeBlock)(void) = ^{
        self.window.userInteractionEnabled = YES;
        
        CGFloat minZoomScale = 1;
        if (adjustResizeW >= adjustResizeH) {
            minZoomScale = adjustResizeW / _sizeScale / _baseImageW;
            CGFloat imageH = _baseImageH * minZoomScale;
            CGFloat trueImageH = adjustResizeH / _sizeScale;
            if (imageH < trueImageH) {
                minZoomScale *= (trueImageH / imageH);
            }
        } else {
            minZoomScale = adjustResizeH / _sizeScale / _baseImageH;
            CGFloat imageW = _baseImageW * minZoomScale;
            CGFloat trueImageW = adjustResizeW / _sizeScale;
            if (imageW < trueImageW) {
                minZoomScale *= (trueImageW / imageW);
            }
        }
        self.scrollView.minimumZoomScale = minZoomScale;
        
        CGPoint convertCenter = [self convertPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) toView:self.imageView];
        CGPoint imageViewCenter = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
        BOOL isSameCenter = (labs((NSInteger)convertCenter.x - (NSInteger)imageViewCenter.x) <= 1 &&
                             labs((NSInteger)convertCenter.y - (NSInteger)imageViewCenter.y) <= 1);
        BOOL isOriginFrame = (self.rotationDirection == JPImageresizerVerticalUpDirection &&
                              [self imageresizerFrameIsEqualImageViewFrame] &&
                              self.scrollView.zoomScale == 1);
        
        _isCanRecovery = !isOriginFrame || !isSameCenter;
        !self.imageresizerIsCanRecovery ? : self.imageresizerIsCanRecovery(_isCanRecovery);
    };
    
    self.window.userInteractionEnabled = NO;
    [self hideOrShowFillColor:NO animateDuration:duration];
    [self setImageresizerFrame:adjustResizeFrame animateDuration:duration];
    if (duration > 0) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            zoomBlock();
        } completion:^(BOOL finished) {
            completeBlock();
        }];
    } else {
        zoomBlock();
        completeBlock();
    }
}

- (UIImage *)getTargetDirectionImage:(UIImage *)image {
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
    return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:orientation];
}

#pragma mark - puild method

- (void)startImageresizer {
    [self removeTimer];
    [self hideOrShowFillColor:YES animateDuration:0.2];
}

- (void)endedImageresizer {
    [self addTimer];
}

- (void)willRotationWithImageMaskFrame:(CGRect)imageMaskFrame {
    [self removeTimer];
    self.layer.opacity = 0;
    if (_isHasFillColor) {
        UIColor *maskColor = _fillColor;
        self.maskAlpha = 0;
        [self.imageView showMaskWithMaskFrame:imageMaskFrame maskColor:maskColor];
    }
    _imageMaskFrame = imageMaskFrame;
}

- (void)updateRotationDirection:(JPImageresizerRotationDirection)rotationDirection {
    _rotationDirection = rotationDirection;
    if (rotationDirection == JPImageresizerHorizontalLeftDirection ||
        rotationDirection == JPImageresizerHorizontalRightDirection) {
        _sizeScale = (self.superview.bounds.size.width / self.scrollView.bounds.size.height);
        _baseImageW = self.imageView.bounds.size.height;
        _baseImageH = self.imageView.bounds.size.width;
    } else {
        _sizeScale = 1.0;
        _baseImageW = self.imageView.bounds.size.width;
        _baseImageH = self.imageView.bounds.size.height;
    }
    if (!CGRectIsNull(_imageMaskFrame)) {
        self.imageresizerFrame = [self.imageView convertRect:_imageMaskFrame toView:self];
        _imageMaskFrame = CGRectNull;
    }
}

- (void)endedRotation {
    [self.imageView hideMask];
    self.layer.opacity = 1;
    self.maskAlpha = _fillRgba.jp_a;
    BOOL isAdjustResize = ![self imageresizerFrameIsEqualImageViewFrame];
    [self updateImageresizerFrameWithAnimateDuration:0.35 isAdjustResize:isAdjustResize];
}



- (void)willRecovery {
    self.window.userInteractionEnabled = NO;
    [self removeTimer];
}

- (void)recovery {
    [self updateRotationDirection:JPImageresizerVerticalUpDirection];
    [self resetImageresizerFrame];
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.opacity = 1;
        [self updateImageresizerFrameWithAnimateDuration:0 isAdjustResize:YES];
    } completion:^(BOOL finished) {
        self.window.userInteractionEnabled = YES;
    }];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete {
    /**
     * UIImageOrientationUp,            // default orientation
     * UIImageOrientationDown,          // 180 deg rotation
     * UIImageOrientationLeft,          // 90 deg CCW
     * UIImageOrientationRight,         // 90 deg CW
     */
//    self.pictureImage = [self.pictureImage fixOrientation];
    
    UIImage *image = self.imageView.image;
    
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
    
    CGRect cropFrame = [self convertRect:self.imageresizerFrame toView:self.imageView];
    
    // 宽高比不变，所以宽度高度的比例是一样
    CGFloat scale = image.size.width / self.imageView.bounds.size.width;
    CGFloat orgX = cropFrame.origin.x * scale;
    CGFloat orgY = cropFrame.origin.y * scale;
    CGFloat width = cropFrame.size.width * scale;
    CGFloat height = cropFrame.size.height * scale;
    
    CGRect cropRect = CGRectMake(orgX, orgY, width, height);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
        
        
        /**
         * 参考：http://www.jb51.net/article/81318.htm
         * 这里要注意一点CGContextDrawImage这个函数的坐标系和UIKIt的坐标系上下颠倒，需对坐标系处理如下：
            - 1.CGContextTranslateCTM(context, 0, cropFrame.size.height);
            - 2.CGContextScaleCTM(context, 1, -1);
         */
        
        CGFloat deviceScale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(cropFrame.size, 0, deviceScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, cropFrame.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0, cropFrame.size.width, cropFrame.size.height), imgRef);
        
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        newImg = [strongSelf getTargetDirectionImage:newImg];
        
        CGImageRelease(imgRef);
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(newImg);
        });
    });
}

#pragma mark - UIPanGestureRecognizer

- (void)panHandle:(UIPanGestureRecognizer *)panGR {
    
    CGPoint translation = [panGR translationInView:self];
    
    [panGR setTranslation:CGPointZero inView:self];
    
    if (panGR.state == UIGestureRecognizerStateBegan) [self panBeganHandleWithLocation:[panGR locationInView:self]];
    
    if (panGR.state == UIGestureRecognizerStateChanged) [self panChangedHandleWithTranslation:translation];
    
    if (panGR.state == UIGestureRecognizerStateEnded ||
        panGR.state == UIGestureRecognizerStateCancelled ||
        panGR.state == UIGestureRecognizerStateFailed) [self endedImageresizer];
}

- (void)panBeganHandleWithLocation:(CGPoint)location {
    
    [self startImageresizer];
    
    CGFloat x = self.imageresizeX;
    CGFloat y = self.imageresizeY;
    CGFloat width = self.imageresizeW;
    CGFloat height = self.imageresizeH;
    CGFloat midX = CGRectGetMidX(self.imageresizerFrame);
    CGFloat midY = CGRectGetMidY(self.imageresizerFrame);
    CGFloat maxX = CGRectGetMaxX(self.imageresizerFrame);
    CGFloat maxY = CGRectGetMaxY(self.imageresizerFrame);
    
    CGFloat scopeWH = _scopeWH;
    CGFloat halfScopeWH = scopeWH * 0.5;
    
    CGRect leftTopRect = CGRectMake(x - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect leftBotRect = CGRectMake(x - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    CGRect rightTopRect = CGRectMake(maxX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect rightBotRect = CGRectMake(maxX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    CGRect leftMidRect = CGRectMake(x - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
    CGRect rightMidRect = CGRectMake(maxX - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
    CGRect topMidRect = CGRectMake(midX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect botMidRect = CGRectMake(midX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    
    if (CGRectContainsPoint(leftTopRect, location)) {
        self.currHorn = LeftTop;
        self.diagonal = CGPointMake(x + width, y + height);
    } else if (CGRectContainsPoint(leftBotRect, location)) {
        self.currHorn = LeftBottom;
        self.diagonal = CGPointMake(x + width, y);
    } else if (CGRectContainsPoint(rightTopRect, location)) {
        self.currHorn = RightTop;
        self.diagonal = CGPointMake(x, y + height);
    } else if (CGRectContainsPoint(rightBotRect, location)) {
        self.currHorn = RightBottom;
        self.diagonal = CGPointMake(x, y);
    } else if (_isArbitrarily && CGRectContainsPoint(leftMidRect, location)) {
        self.currHorn = LeftMid;
        self.diagonal = CGPointMake(maxX, midY);
    } else if (_isArbitrarily && CGRectContainsPoint(rightMidRect, location)) {
        self.currHorn = RightMid;
        self.diagonal = CGPointMake(x, midY);
    } else if (_isArbitrarily && CGRectContainsPoint(topMidRect, location)) {
        self.currHorn = TopMid;
        self.diagonal = CGPointMake(midX, maxY);
    } else if (_isArbitrarily && CGRectContainsPoint(botMidRect, location)) {
        self.currHorn = BottomMid;
        self.diagonal = CGPointMake(midX, y);
    } else {
        self.currHorn = Center;
    }
    
    _startResizeW = width;
    _startResizeH = height;
}

- (void)panChangedHandleWithTranslation:(CGPoint)translation {
    
    CGFloat x = self.imageresizeX;
    CGFloat y = self.imageresizeY;
    CGFloat width = self.imageresizeW;
    CGFloat height = self.imageresizeH;
    
    switch (self.currHorn) {
            
        case LeftTop: {
            if (_isArbitrarily) {
                x += translation.x;
                y += translation.y;
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                
                width = self.diagonal.x - x;
                height = self.diagonal.y - y;
                
                if (width < _minImageWH) {
                    width = _minImageWH;
                    x = self.diagonal.x - width;
                }
                
                if (height < _minImageWH) {
                    height = _minImageWH;
                    y = self.diagonal.y - height;
                }
            } else {
                x += translation.x;
                width = self.diagonal.x - x;
                
                if (translation.x != 0) {
                    CGFloat diff = translation.x / _resizeWHScale;
                    y += diff;
                    height = self.diagonal.y - y;
                }
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                    width = self.diagonal.x;
                    height = width / _resizeWHScale;
                    y = self.diagonal.y - height;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                    height = self.diagonal.y;
                    width = height * _resizeWHScale;
                    x = self.diagonal.x - width;
                }
                
                if (width < _minImageWH || height < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        width = _minImageWH;
                        height = width / _resizeWHScale;
                    } else {
                        height = _minImageWH;
                        width = height * _resizeWHScale;
                    }
                    x = self.diagonal.x - width;
                    y = self.diagonal.y - height;
                }
            }
            
            break;
        }
            
        case LeftBottom: {
            if (_isArbitrarily) {
                x += translation.x;
                height = height + translation.y;
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + height) > maxResizeMaxY) {
                    height = maxResizeMaxY - self.diagonal.y;
                }
                
                width = self.diagonal.x - x;
                
                if (width < _minImageWH) {
                    width = _minImageWH;
                    x = self.diagonal.x - width;
                }
                
                if (height < _minImageWH) {
                    height = _minImageWH;
                }
            } else {
                x += translation.x;
                width = self.diagonal.x - x;
                
                if (translation.x != 0) {
                    height = width / _resizeWHScale;
                }
                
                if (x < 0) {
                    x = 0;
                    width = self.diagonal.x;
                    height = width / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + height) > maxResizeMaxY) {
                    height = maxResizeMaxY - self.diagonal.y;
                    width = height * _resizeWHScale;
                    x = self.diagonal.x - width;
                }
                
                if (width < _minImageWH || height < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        width = _minImageWH;
                        height = width / _resizeWHScale;
                    } else {
                        height = _minImageWH;
                        width = height * _resizeWHScale;
                    }
                    x = self.diagonal.x - width;
                    y = self.diagonal.y;
                }
            }
            
            break;
        }
            
        case RightTop: {
            if (_isArbitrarily) {
                y += translation.y;
                width = width + translation.x;
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + width) > maxResizeMaxX) {
                    width = maxResizeMaxX - self.diagonal.x;
                }
                
                height = self.diagonal.y - y;
                
                if (width < _minImageWH) {
                    width = _minImageWH;
                }
                
                if (height < _minImageWH) {
                    height = _minImageWH;
                    y = self.diagonal.y - height;
                }
            } else {
                width = width + translation.x;
                
                if (translation.x != 0) {
                    CGFloat diff = translation.x / _resizeWHScale;
                    y -= diff;
                    height = self.diagonal.y - y;
                }
                
                if (y < 0) {
                    y = 0;
                    height = self.diagonal.y;
                    width = height * _resizeWHScale;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + width) > maxResizeMaxX) {
                    width = maxResizeMaxX - self.diagonal.x;
                    height = width / _resizeWHScale;
                    y = self.diagonal.y - height;
                }
                
                if (width < _minImageWH || height < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        width = _minImageWH;
                        height = width / _resizeWHScale;
                    } else {
                        height = _minImageWH;
                        width = height * _resizeWHScale;
                    }
                    x = self.diagonal.x;
                    y = self.diagonal.y - height;
                }
            }
            
            break;
        }
            
        case RightBottom: {
            if (_isArbitrarily) {
                width = width + translation.x;
                height = height + translation.y;
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + width) > maxResizeMaxX) {
                    width = maxResizeMaxX - self.diagonal.x;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + height) > maxResizeMaxY) {
                    height = maxResizeMaxY - self.diagonal.y;
                }
                
                if (width < _minImageWH) {
                    width = _minImageWH;
                }
                
                if (height < _minImageWH) {
                    height = _minImageWH;
                }
            } else {
                width = width + translation.x;
                
                if (translation.x != 0) {
                    height = width / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + width) > maxResizeMaxX) {
                    width = maxResizeMaxX - self.diagonal.x;
                    height = width / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + height) > maxResizeMaxY) {
                    height = maxResizeMaxY - self.diagonal.y;
                    width = height * _resizeWHScale;
                }
                
                if (width < _minImageWH || height < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        width = _minImageWH;
                        height = width / _resizeWHScale;
                    } else {
                        height = _minImageWH;
                        width = height * _resizeWHScale;
                    }
                    x = self.diagonal.x;
                    y = self.diagonal.y;
                }
            }
            
            break;
        }
            
        case LeftMid: {
            x += translation.x;
            
            if (x < self.maxResizeX) {
                x = self.maxResizeX;
            }
            
            width = self.diagonal.x - x;
            
            if (width < _minImageWH) {
                width = _minImageWH;
                x = self.diagonal.x - width;
            }
            break;
        }
            
        case RightMid: {
            width = width + translation.x;
            
            CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
            if ((x + width) > maxResizeMaxX) {
                width = maxResizeMaxX - self.diagonal.x;
            }
            
            if (width < _minImageWH) {
                width = _minImageWH;
            }
            break;
        }
            
        case TopMid: {
            y += translation.y;
            
            if (y < self.maxResizeY) {
                y = self.maxResizeY;
            }
            
            height = self.diagonal.y - y;
            
            if (height < _minImageWH) {
                height = _minImageWH;
                y = self.diagonal.y - height;
            }
            break;
        }
            
        case BottomMid: {
            height = height + translation.y;
            
            CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
            if ((y + height) > maxResizeMaxY) {
                height = maxResizeMaxY - self.diagonal.y;
            }
            
            if (height < _minImageWH) {
                height = _minImageWH;
            }
            break;
        }
            
        default:
        {
            break;
        }
            
    }
    
    self.imageresizerFrame = CGRectMake(x, y, width, height);
    
    CGRect zoomFrame = [self convertRect:self.imageresizerFrame toView:self.imageView];
    CGFloat diffOffsetX = 0;
    CGFloat diffOffsetY = 0;
    if (zoomFrame.origin.x < 0) {
        diffOffsetX = zoomFrame.origin.x;
    } else if (CGRectGetMaxX(zoomFrame) > self.imageView.bounds.size.width) {
        diffOffsetX = CGRectGetMaxX(zoomFrame) - self.imageView.bounds.size.width;
    }
    if (zoomFrame.origin.y < 0) {
        diffOffsetY = zoomFrame.origin.y;
    } else if (CGRectGetMaxY(zoomFrame) > self.imageView.bounds.size.height) {
        diffOffsetY = CGRectGetMaxY(zoomFrame) - self.imageView.bounds.size.height;
    }
    diffOffsetX /= _sizeScale;
    diffOffsetY /= _sizeScale;
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x - diffOffsetX,
                                                self.scrollView.contentOffset.y - diffOffsetY);
    
    CGFloat wZoomScale = 0;
    CGFloat hZoomScale = 0;
    if (width > _startResizeW) {
        wZoomScale = width / _sizeScale / _baseImageW;
    }
    if (height > _startResizeH) {
        hZoomScale = height / _sizeScale / _baseImageH;
    }
    CGFloat zoomScale = MAX(wZoomScale, hZoomScale);
    if (zoomScale > self.scrollView.zoomScale) {
        self.scrollView.zoomScale = zoomScale;
    }
}

#pragma mark - super method

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat x = self.imageresizeX;
    CGFloat y = self.imageresizeY;
    CGFloat midX = CGRectGetMidX(self.imageresizerFrame);
    CGFloat midY = CGRectGetMidY(self.imageresizerFrame);
    CGFloat maxX = CGRectGetMaxX(self.imageresizerFrame);
    CGFloat maxY = CGRectGetMaxY(self.imageresizerFrame);
    
    CGFloat scopeWH = _scopeWH;
    CGFloat halfScopeWH = scopeWH * 0.5;
    
    CGRect leftTopRect = CGRectMake(x - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect leftBotRect = CGRectMake(x - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    CGRect rightTopRect = CGRectMake(maxX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect rightBotRect = CGRectMake(maxX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    CGRect leftMidRect = CGRectMake(x - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
    CGRect rightMidRect = CGRectMake(maxX - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
    CGRect topMidRect = CGRectMake(midX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect botMidRect = CGRectMake(midX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    
    if (CGRectContainsPoint(leftTopRect, point) ||
        CGRectContainsPoint(leftBotRect, point) ||
        CGRectContainsPoint(rightTopRect, point) ||
        CGRectContainsPoint(rightBotRect, point) ||
        (_isArbitrarily && CGRectContainsPoint(leftMidRect, point)) ||
        (_isArbitrarily && CGRectContainsPoint(rightMidRect, point)) ||
        (_isArbitrarily && CGRectContainsPoint(topMidRect, point)) ||
        (_isArbitrarily && CGRectContainsPoint(botMidRect, point))) {
        return YES;
    }
    return NO;
}

@end
