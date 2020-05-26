//
//  JPImageresizerBlurView.m
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import "JPImageresizerBlurView.h"

@interface JPImageresizerBlurView ()
@property (nonatomic, weak) UIVisualEffectView *visualEffectView;
@property (nonatomic, weak) UIView *fillView;
@end

@implementation JPImageresizerBlurView
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
        _blurEffect = blurEffect;
        _bgColor = bgColor;
        _maskAlpha = maskAlpha;
        _isBlur = blurEffect != nil;
        _isMaskAlpha = YES;

        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = self.bounds;
        visualEffectView.userInteractionEnabled = NO;
        [self addSubview:visualEffectView];
        _visualEffectView = visualEffectView;

        UIView *fillView = [[UIView alloc] initWithFrame:self.bounds];
        fillView.userInteractionEnabled = NO;
        fillView.layer.backgroundColor = bgColor.CGColor;
        fillView.alpha = _isMaskAlpha ? (_isBlur ? 0 : maskAlpha) : 1;
        [self addSubview:fillView];
        _fillView = fillView;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _visualEffectView.frame = _fillView.frame = (CGRect){CGPointZero, frame.size};
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
    CGFloat visualEffectAlpha = _isBlur ? 1 : 0;
    maskAlpha = _isMaskAlpha ? ((_blurEffect || !_isBlur) ? 0 : _maskAlpha) : 1;
    void (^animations)(void) = ^{
        self.visualEffectView.effect = blurEffect;
        self.visualEffectView.alpha = visualEffectAlpha;
        self.fillView.layer.backgroundColor = bgColor.CGColor;
        self.fillView.alpha = maskAlpha;
    };
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        animations();
    }
 }

- (void)__blurEffectAnimation:(NSTimeInterval)duration {
    void (^animations)(void) = ^{
        self.visualEffectView.alpha = self->_isBlur ? 1 : 0;
        if (self->_isMaskAlpha) {
            self.fillView.alpha = (self->_blurEffect || !self->_isBlur) ? 0 : self->_maskAlpha;
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
            self.fillView.alpha = (self->_blurEffect || !self->_isBlur) ? 0 : self->_maskAlpha;
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
