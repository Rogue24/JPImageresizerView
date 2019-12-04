//
//  CALayer+JPImageresizer.m
//  JPImageresizerView
//
//  Created by 周健平 on 2019/8/2.
//

#import "CALayer+JPImageresizer.h"

@implementation CABasicAnimation (JPImageresizer)

+ (CABasicAnimation *)jpir_backwardsAnimationWithKeyPath:(NSString *)keyPath
                                                fromValue:(id)fromValue
                                                 toValue:(id)toValue
                                      timingFunctionName:(CAMediaTimingFunctionName)timingFunctionName
                                                duration:(NSTimeInterval)duration {
    if (duration <= 0) return nil;
    CABasicAnimation *anim = [self animationWithKeyPath:keyPath];
    anim.fillMode = kCAFillModeBackwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
    anim.duration = duration;
    anim.fromValue = fromValue;
    anim.toValue = toValue;
    return anim;
}

@end

@implementation CALayer (JPImageresizer)

- (void)jpir_addBackwardsAnimationWithKeyPath:(NSString *)keyPath
                                    fromValue:(id)fromValue
                                      toValue:(id)toValue
                           timingFunctionName:(CAMediaTimingFunctionName)timingFunctionName
                                     duration:(NSTimeInterval)duration {
    CABasicAnimation *anim = [CABasicAnimation jpir_backwardsAnimationWithKeyPath:keyPath fromValue:fromValue toValue:toValue timingFunctionName:timingFunctionName duration:duration];
    if (anim) [self addAnimation:anim forKey:keyPath];
}

@end


