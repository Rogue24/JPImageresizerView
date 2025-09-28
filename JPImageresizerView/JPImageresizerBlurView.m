//
//  JPImageresizerBlurView.m
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import "JPImageresizerBlurView.h"

@interface JPImageresizerBlurView ()
@property (nonatomic, weak) UIVisualEffectView *effectView;
@property (nonatomic, weak) UIView *fillView;
@end

@implementation JPImageresizerBlurView
{
    BOOL _isBlur;
    UIVisualEffect *_effect;
    UIColor *_bgColor;
    CGFloat _maskAlpha;
    BOOL _isMaskAlpha;
}

- (instancetype)initWithFrame:(CGRect)frame
                       effect:(UIVisualEffect *)effect
                      bgColor:(UIColor *)bgColor
                    maskAlpha:(CGFloat)maskAlpha {
    if (self = [super initWithFrame:frame]) {
        _effect = effect;
        _bgColor = bgColor;
        _maskAlpha = maskAlpha;
        _isBlur = effect != nil;
        _isMaskAlpha = YES;

        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = self.bounds;
        effectView.userInteractionEnabled = NO;
        effectView.layer.masksToBounds = YES;
        [self addSubview:effectView];
        _effectView = effectView;

        UIView *fillView = [[UIView alloc] initWithFrame:self.bounds];
        fillView.userInteractionEnabled = NO;
        fillView.layer.backgroundColor = bgColor.CGColor;
        fillView.layer.masksToBounds = YES;
        fillView.alpha = _isMaskAlpha ? (_isBlur ? 0 : maskAlpha) : 1;
        [self addSubview:fillView];
        _fillView = fillView;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _effectView.frame = self.bounds;
    _fillView.frame = self.bounds;
    self.maskView.frame = self.bounds;
}

#pragma mark - getter

- (BOOL)isBlur {
    return _isBlur;
}
- (UIVisualEffect *)effect {
    return _effect;
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

#pragma mark - setter

- (void)setCornerRadius:(CGFloat)cornerRadius {
    // 已经确保了赋值的地方做好了限制，这里就不重复判断了
//    if (cornerRadius < 0) {
//        cornerRadius = 0;
//    } else {
//        if (cornerRadius > (self.bounds.size.width * 0.5)) {
//            cornerRadius = self.bounds.size.width * 0.5;
//        }
//        if (cornerRadius > (self.bounds.size.height * 0.5)) {
//            cornerRadius = self.bounds.size.height * 0.5;
//        }
//    }
    if (_cornerRadius == cornerRadius) return;
    _cornerRadius = cornerRadius;
    _effectView.layer.cornerRadius = _fillView.layer.cornerRadius = cornerRadius;
}

- (void)setIsBlur:(BOOL)isBlur duration:(NSTimeInterval)duration {
    _isBlur = isBlur;
    [self __effectAnimation:duration];
}
- (void)setEffect:(UIVisualEffect *)effect duration:(NSTimeInterval)duration {
    _effect = effect;
    [self __effectAnimation:duration];
}
- (void)setBgColor:(UIColor *)bgColor duration:(NSTimeInterval)duration {
    _bgColor = bgColor;
    [self __effectAnimation:duration];
}
- (void)setMaskAlpha:(CGFloat)maskAlpha duration:(NSTimeInterval)duration {
    _maskAlpha = maskAlpha;
    [self __maskAlphaAnimation:duration];
}
- (void)setIsMaskAlpha:(BOOL)isMaskAlpha duration:(NSTimeInterval)duration {
    _isMaskAlpha = isMaskAlpha;
    [self __maskAlphaAnimation:duration];
}

- (void)setupIsBlur:(BOOL)isBlur
             effect:(UIVisualEffect *)effect
            bgColor:(UIColor *)bgColor
          maskAlpha:(CGFloat)maskAlpha
        isMaskAlpha:(BOOL)isMaskAlpha
           duration:(NSTimeInterval)duration {
    _isBlur = isBlur;
    _effect = effect;
    _bgColor = bgColor;
    _maskAlpha = maskAlpha;
    _isMaskAlpha = isMaskAlpha;
    effect = _isBlur ? _effect : nil;
    maskAlpha = _isMaskAlpha ? ((_effect || !_isBlur) ? 0 : _maskAlpha) : 1;
    void (^animations)(void) = ^{
        self.effectView.effect = effect;
        self.fillView.layer.backgroundColor = bgColor.CGColor;
        self.fillView.alpha = maskAlpha;
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        animations();
    }
 }

- (void)__effectAnimation:(NSTimeInterval)duration {
    void (^animations)(void) = ^{
        self.effectView.effect = self->_isBlur ? self->_effect : nil;
        if (self->_isMaskAlpha) {
            self.fillView.alpha = (self->_effect || !self->_isBlur) ? 0 : self->_maskAlpha;
        } else {
            self.fillView.alpha = 1;
        }
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        animations();
    }
}

- (void)__maskAlphaAnimation:(NSTimeInterval)duration {
    void (^animations)(void) = ^{
        if (self->_isMaskAlpha) {
            self.fillView.alpha = (self->_effect || !self->_isBlur) ? 0 : self->_maskAlpha;
        } else {
            self.fillView.alpha = 1;
        }
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        animations();
    }
}

@end
