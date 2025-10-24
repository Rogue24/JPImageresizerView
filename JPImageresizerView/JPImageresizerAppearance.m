//
//  JPImageresizerAppearance.m
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import "JPImageresizerAppearance.h"

@implementation JPImageresizerAppearance

- (instancetype)initWithStrokeColor:(UIColor *)strokeColor
                           bgEffect:(UIVisualEffect *)bgEffect
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha {
    if (self = [super init]) {
        _strokeColor = strokeColor;
        _bgEffect = bgEffect;
        _bgColor = bgColor;
        _maskAlpha = maskAlpha;
    }
    return self;
}

@end
