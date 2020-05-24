//
//  UIView+JPPOP.m
//  WoLive
//
//  Created by 周健平 on 2019/8/23.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import "UIView+JPPOP.h"

@implementation UIView (JPPOP)

#pragma mark - pop basic

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:nil
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:0
                                                      key:nil
                                          completionBlock:nil];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                          completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:nil
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:0
                                                      key:nil
                                          completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock  {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:nil
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:beginTime
                                                      key:nil
                                          completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:fromValue
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:beginTime
                                                      key:nil
                                          completionBlock:completionBlock];
}

/** fromValue、toValue、timingFunctionName、duration、beginTime、key、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                       timingFunctionName:(NSString *)timingFunctionName
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                                      key:(NSString *)key
                                          completionBlock:(JPPOPCompletionBlock)completionBlock {
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:propertyNamed];
    anim.duration = duration;
    anim.toValue = toValue;
    if (fromValue) anim.fromValue = fromValue;
    if (timingFunctionName) anim.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
    if (beginTime > 0) anim.beginTime = CACurrentMediaTime() + beginTime;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:(key ? key : propertyNamed)];
    return anim;
}

#pragma mark - pop spring

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:nil
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:0
                                                       key:nil
                                           completionBlock:nil];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:nil
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:0
                                                       key:nil
                                           completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:nil
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:beginTime
                                                       key:nil
                                           completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:fromValue
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:beginTime
                                                       key:nil
                                           completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                              key:(NSString *)key
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:propertyNamed];
    anim.springSpeed = springSpeed;
    anim.springBounciness = springBounciness;
    anim.toValue = toValue;
    if (fromValue) anim.fromValue = fromValue;
    if (beginTime > 0) anim.beginTime = CACurrentMediaTime() + beginTime;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:(key ? key : propertyNamed)];
    return anim;
}

@end

@implementation CALayer (JPPOP)

#pragma mark - pop basic

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:nil
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:0
                                                      key:nil
                                          completionBlock:nil];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                          completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:nil
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:0
                                                      key:nil
                                          completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock  {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:nil
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:beginTime
                                                      key:nil
                                          completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPBasicAnimationWithPropertyNamed:propertyNamed
                                                fromValue:fromValue
                                                  toValue:toValue
                                       timingFunctionName:nil
                                                 duration:duration
                                                beginTime:beginTime
                                                      key:nil
                                          completionBlock:completionBlock];
}


- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                       timingFunctionName:(NSString *)timingFunctionName
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                                      key:(NSString *)key
                                          completionBlock:(JPPOPCompletionBlock)completionBlock {
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:propertyNamed];
    anim.duration = duration;
    anim.toValue = toValue;
    if (fromValue) anim.fromValue = fromValue;
    if (timingFunctionName) anim.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
    if (beginTime > 0) anim.beginTime = CACurrentMediaTime() + beginTime;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:(key ? key : propertyNamed)];
    return anim;
}

#pragma mark - pop spring

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:nil
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:0
                                                       key:nil
                                           completionBlock:nil];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:nil
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:0
                                                       key:nil
                                           completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:nil
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:beginTime
                                                       key:nil
                                           completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    return [self jp_addPOPSpringAnimationWithPropertyNamed:propertyNamed
                                                 fromValue:fromValue
                                                   toValue:toValue
                                               springSpeed:springSpeed
                                          springBounciness:springBounciness
                                                 beginTime:beginTime
                                                       key:nil
                                           completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                              key:(NSString *)key
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:propertyNamed];
    anim.springSpeed = springSpeed;
    anim.springBounciness = springBounciness;
    anim.toValue = toValue;
    if (fromValue) anim.fromValue = fromValue;
    if (beginTime > 0) anim.beginTime = CACurrentMediaTime() + beginTime;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:(key ? key : propertyNamed)];
    return anim;
}

@end
