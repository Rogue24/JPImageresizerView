//
//  UIView+JPPOP.m
//  WoLive
//
//  Created by 周健平 on 2019/8/23.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import "UIView+JPPOP.h"

@implementation UIView (JPPOP)

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:0 duration:duration fromValue:nil toValue:toValue key:propertyNamed completionBlock:nil];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime duration:duration fromValue:nil toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime duration:duration fromValue:fromValue toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime duration:duration fromValue:nil toValue:toValue key:key completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:propertyNamed];
    anim.beginTime = CACurrentMediaTime() + beginTime;
    anim.duration = duration;
    if (fromValue) anim.fromValue = fromValue;
    anim.toValue = toValue;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:key];
    return anim;
}


- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:0 springSpeed:springSpeed springBounciness:springBounciness fromValue:nil toValue:toValue key:propertyNamed completionBlock:nil];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime springSpeed:springSpeed springBounciness:springBounciness fromValue:nil toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime springSpeed:springSpeed springBounciness:springBounciness fromValue:fromValue toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime springSpeed:springSpeed springBounciness:springBounciness fromValue:nil toValue:toValue key:key completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:propertyNamed];
    anim.beginTime = CACurrentMediaTime() + beginTime;
    anim.springSpeed = springSpeed;
    anim.springBounciness = springBounciness;
    if (fromValue) anim.fromValue = fromValue;
    anim.toValue = toValue;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:key];
    return anim;
}

@end

@implementation CALayer (JPPOP)
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:0 duration:duration fromValue:nil toValue:toValue key:propertyNamed completionBlock:nil];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime duration:duration fromValue:nil toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime duration:duration fromValue:fromValue toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPBasicAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime duration:duration fromValue:nil toValue:toValue key:key completionBlock:completionBlock];
}

- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:propertyNamed];
    anim.beginTime = CACurrentMediaTime() + beginTime;
    anim.duration = duration;
    if (fromValue) anim.fromValue = fromValue;
    anim.toValue = toValue;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:key];
    return anim;
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:0 springSpeed:springSpeed springBounciness:springBounciness fromValue:nil toValue:toValue key:propertyNamed completionBlock:nil];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime springSpeed:springSpeed springBounciness:springBounciness fromValue:nil toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime springSpeed:springSpeed springBounciness:springBounciness fromValue:fromValue toValue:toValue key:propertyNamed completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    return [self jp_addPOPSpringAnimationWithPpropertyNamed:propertyNamed beginTime:beginTime springSpeed:springSpeed springBounciness:springBounciness fromValue:nil toValue:toValue key:key completionBlock:completionBlock];
}

- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:propertyNamed];
    anim.beginTime = CACurrentMediaTime() + beginTime;
    anim.springSpeed = springSpeed;
    anim.springBounciness = springBounciness;
    if (fromValue) anim.fromValue = fromValue;
    anim.toValue = toValue;
    if (completionBlock) anim.completionBlock = completionBlock;
    [self pop_addAnimation:anim forKey:key];
    return anim;
}

@end
