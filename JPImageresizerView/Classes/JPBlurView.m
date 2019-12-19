//
//  JPBlurView.m
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import "JPBlurView.h"

@interface JPBlurView ()
@property (nonatomic, weak) UIVisualEffectView *visualEffectView;
@property (nonatomic, weak) CALayer *fillLayer;
@end

@implementation JPBlurView
{
    BOOL _isBlur;
    UIBlurEffect *_blurEffect;
    UIColor *_bgColor;
    CGFloat _maskAlpha;
    BOOL _isMaskAlpha;
}

- (instancetype)initWithFrame:(CGRect)frame
                   blurEffect:(UIBlurEffect *)blurEffect
                      bgColor:(UIColor *)bgColor
                    maskAlpha:(CGFloat)maskAlpha {
    if (self = [super initWithFrame:frame]) {
        _isBlur = blurEffect != nil;
        _blurEffect = blurEffect;
        _bgColor = bgColor;
        _maskAlpha = maskAlpha;
        _isMaskAlpha = YES;
        
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:nil];
        visualEffectView.frame = self.bounds;
        visualEffectView.userInteractionEnabled = NO;
        [self addSubview:visualEffectView];
        _visualEffectView = visualEffectView;

        CALayer *fillLayer = [CALayer layer];
        fillLayer.frame = self.bounds;
        fillLayer.opacity = maskAlpha;
        [self.layer addSublayer:fillLayer];
        _fillLayer = fillLayer;
        
        if (_isBlur) {
            visualEffectView.effect = blurEffect;
        } else {
            fillLayer.backgroundColor = bgColor.CGColor;
        }
    }
    return self;
}

- (BOOL)isBlur {
    return _isBlur;
}
- (UIBlurEffect *)blurEffect {
    return _blurEffect;
}
- (UIColor *)bgColor {
    return _bgColor;
}
- (CGFloat)maskAlpha {
    return _maskAlpha;
}
- (BOOL)isMaskAlpha {
    return _isMaskAlpha;
}

- (void)setIsBlur:(BOOL)isBlur duration:(NSTimeInterval)duration {
    _isBlur = isBlur;
    [self __blurEffectAnimation:duration];
}
- (void)setBlurEffect:(UIBlurEffect *)blurEffect duration:(NSTimeInterval)duration {
    _blurEffect = blurEffect;
    [self __blurEffectAnimation:duration];
}
- (void)setBgColor:(UIColor *)bgColor duration:(NSTimeInterval)duration {
    _bgColor = bgColor;
    [self __blurEffectAnimation:duration];
}
- (void)setMaskAlpha:(BOOL)maskAlpha duration:(NSTimeInterval)duration {
    _maskAlpha = maskAlpha;
    [self __maskAlphaAnimation:duration];
}
- (void)setIsMaskAlpha:(BOOL)isMaskAlpha duration:(NSTimeInterval)duration {
    _isMaskAlpha = isMaskAlpha;
    [self __maskAlphaAnimation:duration];
}

- (void)setupIsBlur:(BOOL)isBlur
         blurEffect:(UIBlurEffect *)blurEffect
            bgColor:(UIColor *)bgColor
          maskAlpha:(CGFloat)maskAlpha
        isMaskAlpha:(BOOL)isMaskAlpha
           duration:(NSTimeInterval)duration {
    _isBlur = isBlur;
    _blurEffect = blurEffect;
    _bgColor = bgColor;
    _maskAlpha = maskAlpha;
    _isMaskAlpha = isMaskAlpha;
    blurEffect = _isBlur ? _blurEffect : nil;
    bgColor = _isMaskAlpha ? ((_isBlur && _blurEffect) ? UIColor.clearColor : _bgColor) : _bgColor;
    maskAlpha = _isMaskAlpha ? maskAlpha : 1;
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.visualEffectView.effect = blurEffect;
            self.fillLayer.backgroundColor = bgColor.CGColor;
            self.fillLayer.opacity = maskAlpha;
        }];
    } else {
        self.visualEffectView.effect = blurEffect;
        self.fillLayer.backgroundColor = bgColor.CGColor;
        self.fillLayer.opacity = maskAlpha;
    }
 }

- (void)__blurEffectAnimation:(NSTimeInterval)duration {
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.visualEffectView.effect = self->_isBlur ? self->_blurEffect : nil;
            if (self->_isMaskAlpha) {
                self.fillLayer.backgroundColor = (self->_isBlur && self->_blurEffect) ? UIColor.clearColor.CGColor : self->_bgColor.CGColor;
                self.fillLayer.opacity = self->_maskAlpha;
            } else {
                self.fillLayer.backgroundColor = self->_bgColor.CGColor;
                self.fillLayer.opacity = 1;
            }
        }];
    } else {
        self.visualEffectView.effect = self->_isBlur ? self->_blurEffect : nil;
        if (self->_isMaskAlpha) {
            self.fillLayer.backgroundColor = (self->_isBlur && self->_blurEffect) ? UIColor.clearColor.CGColor : self->_bgColor.CGColor;
            self.fillLayer.opacity = self->_maskAlpha;
        } else {
            self.fillLayer.backgroundColor = self->_bgColor.CGColor;
            self.fillLayer.opacity = 1;
        }
    }
}

- (void)__maskAlphaAnimation:(NSTimeInterval)duration {
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:^{
            if (self->_isMaskAlpha) {
                self.fillLayer.backgroundColor = self->_isBlur ? UIColor.clearColor.CGColor : self->_bgColor.CGColor;
                self.fillLayer.opacity = self->_maskAlpha;
            } else {
                self.fillLayer.backgroundColor = self->_bgColor.CGColor;
                self.fillLayer.opacity = 1;
            }
        }];
    } else {
        if (self->_isMaskAlpha) {
            self.fillLayer.backgroundColor = self->_isBlur ? UIColor.clearColor.CGColor : self->_bgColor.CGColor;
            self.fillLayer.opacity = self->_maskAlpha;
        } else {
            self.fillLayer.backgroundColor = self->_bgColor.CGColor;
            self.fillLayer.opacity = 1;
        }
    }
}

@end
