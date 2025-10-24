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

- (instancetype)initWithFrame:(CGRect)frame
                   appearance:(JPImageresizerAppearance *)appearance
                       isBlur:(BOOL)isBlur
                  isMaskAlpha:(BOOL)isMaskAlpha
                 cornerRadius:(CGFloat)cornerRadius {
    if (self = [super initWithFrame:frame]) {
        _appearance = appearance;
        _isBlur = isBlur;
        _isMaskAlpha = isMaskAlpha;
        _cornerRadius = cornerRadius;
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:(isBlur ? appearance.bgEffect : nil)];
        effectView.frame = self.bounds;
        effectView.userInteractionEnabled = NO;
        effectView.layer.masksToBounds = YES;
        effectView.layer.cornerRadius = cornerRadius;
        [self addSubview:effectView];
        _effectView = effectView;

        UIView *fillView = [[UIView alloc] initWithFrame:self.bounds];
        fillView.alpha = isMaskAlpha ? ((appearance.bgEffect || !isBlur) ? 0 : appearance.maskAlpha) : 1;
        fillView.userInteractionEnabled = NO;
        fillView.layer.masksToBounds = YES;
        fillView.layer.cornerRadius = cornerRadius;
        fillView.layer.backgroundColor = appearance.bgColor.CGColor;
        [self addSubview:fillView];
        _fillView = fillView;
        
        _effectView.layer.cornerRadius = _fillView.layer.cornerRadius = cornerRadius;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _effectView.frame = self.bounds;
    _fillView.frame = self.bounds;
    self.maskView.frame = self.bounds;
}

#pragma mark - setter

- (void)setAppearance:(JPImageresizerAppearance *)appearance {
    [self setAppearance:appearance duration:0];
}
- (void)setAppearance:(JPImageresizerAppearance *)appearance duration:(NSTimeInterval)duration {
    _appearance = appearance;
    
    UIVisualEffect *effect = self.isBlur ? appearance.bgEffect : nil;
    CGColorRef cgColor = appearance.bgColor.CGColor;
    CGFloat alpha = self.isMaskAlpha ? ((appearance.bgEffect || !self.isBlur) ? 0 : appearance.maskAlpha) : 1;
    
    void (^animations)(void) = ^{
        self.effectView.effect = effect;
        self.fillView.layer.backgroundColor = cgColor;
        self.fillView.alpha = alpha;
    };
    
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        animations();
    }
}

- (void)setIsBlur:(BOOL)isBlur {
    [self setIsBlur:isBlur duration:0];
}
- (void)setIsBlur:(BOOL)isBlur duration:(NSTimeInterval)duration {
    if (_isBlur == isBlur) return;
    _isBlur = isBlur;
    [self setAppearance:_appearance duration:duration];
}

- (void)setIsMaskAlpha:(BOOL)isMaskAlpha {
    [self setIsMaskAlpha:isMaskAlpha duration:0];
}
- (void)setIsMaskAlpha:(BOOL)isMaskAlpha duration:(NSTimeInterval)duration {
    if (_isMaskAlpha == isMaskAlpha) return;
    _isMaskAlpha = isMaskAlpha;
    [self setAppearance:_appearance duration:duration];
}

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

@end
