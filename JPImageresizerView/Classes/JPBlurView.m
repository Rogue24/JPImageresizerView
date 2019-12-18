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
    UIBlurEffect *_blurEffect;
    UIColor *_fillColor;
    BOOL _isBlur;
}

- (instancetype)initWithFrame:(CGRect)frame blurEffect:(UIBlurEffect *)blurEffect fillColor:(UIColor *)fillColor {
    if (self = [super initWithFrame:frame]) {
        _fillColor = fillColor;
        _blurEffect = blurEffect;
        
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:nil];
        visualEffectView.frame = self.bounds;
        visualEffectView.userInteractionEnabled = NO;
        [self addSubview:visualEffectView];
        _visualEffectView = visualEffectView;
        
        CALayer *fillLayer = [CALayer layer];
        fillLayer.frame = self.bounds;
        [self.layer addSublayer:fillLayer];
        _fillLayer = fillLayer;
        
        _isBlur = blurEffect != nil;
        if (_isBlur) {
            visualEffectView.effect = blurEffect;
        } else {
            fillLayer.backgroundColor = fillColor.CGColor;
        }
    }
    return self;
}

- (UIBlurEffect *)blurEffect {
    return _blurEffect;
}

- (UIColor *)fillColor {
    return _fillColor;
}

- (BOOL)isBlur {
    return _isBlur;
}

- (void)setIsBlur:(BOOL)isBlur {
    [self setIsBlur:isBlur animated:NO];
}

- (void)setIsBlur:(BOOL)isBlur animated:(BOOL)isAnimated {
    [self setBlurEffect:_blurEffect fillColor:_fillColor isBlur:isBlur animated:isAnimated];
}

- (void)setBlurEffect:(UIBlurEffect *)blurEffect animated:(BOOL)isAnimated {
    [self setBlurEffect:blurEffect fillColor:_fillColor isBlur:_isBlur animated:isAnimated];
}

- (void)setFillColor:(UIColor *)fillColor animated:(BOOL)isAnimated {
    [self setBlurEffect:_blurEffect fillColor:fillColor isBlur:_isBlur animated:isAnimated];
}

- (void)setBlurEffect:(UIBlurEffect *)blurEffect fillColor:(UIColor *)fillColor isBlur:(BOOL)isBlur animated:(BOOL)isAnimated {
    if (_blurEffect == blurEffect && _fillColor == fillColor && _isBlur == isBlur) return;
    _blurEffect = blurEffect;
    _fillColor = fillColor;
    _isBlur = isBlur;
#warning 怎么办呢~
    [self __setBlurEffect:(_isBlur ? _blurEffect : nil)
                fillColor:(_isBlur ? UIColor.clearColor : _fillColor)
                 animated:isAnimated];
}

- (void)__setBlurEffect:(UIBlurEffect *)blurEffect fillColor:(UIColor *)fillColor animated:(BOOL)isAnimated {
    if (isAnimated) {
        [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.visualEffectView.effect = blurEffect;
            self.fillLayer.backgroundColor = fillColor.CGColor;
        } completion:nil];
    } else {
        self.visualEffectView.effect = blurEffect;
        self.fillLayer.backgroundColor = fillColor.CGColor;
    }
}

@end
