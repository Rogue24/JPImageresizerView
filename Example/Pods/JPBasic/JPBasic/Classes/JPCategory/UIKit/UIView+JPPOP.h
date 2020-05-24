//
//  UIView+JPPOP.h
//  WoLive
//
//  Created by 周健平 on 2019/8/23.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>

/**
 * kCAMediaTimingFunctionLinear
 * kCAMediaTimingFunctionEaseIn
 * kCAMediaTimingFunctionEaseOut
 * kCAMediaTimingFunctionEaseInEaseOut
 * kCAMediaTimingFunctionDefault
 */

typedef void(^JPPOPCompletionBlock)(POPAnimation *anim, BOOL finished);

@interface UIView (JPPOP)

#pragma mark - pop basic

/** toValue、duration */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration;

/** toValue、duration、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

/** toValue、duration、beginTime、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、duration、beginTime、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、timingFunctionName、duration、beginTime、key、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                       timingFunctionName:(NSString *)timingFunctionName
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                                      key:(NSString *)key
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

#pragma mark - pop spring

/** toValue、springSpeed、springBounciness */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness;

/** toValue、springSpeed、springBounciness、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;

/** toValue、springSpeed、springBounciness、beginTime、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、springSpeed、springBounciness、beginTime、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、springSpeed、springBounciness、beginTime、key、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                              key:(NSString *)key
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;
@end


@interface CALayer (JPPOP)

#pragma mark - pop basic

/** toValue、duration */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration;

/** toValue、duration、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

/** toValue、duration、beginTime、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、duration、beginTime、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、timingFunctionName、duration、beginTime、key、completionBlock */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                fromValue:(id)fromValue
                                                  toValue:(id)toValue
                                       timingFunctionName:(NSString *)timingFunctionName
                                                 duration:(NSTimeInterval)duration
                                                beginTime:(NSTimeInterval)beginTime
                                                      key:(NSString *)key
                                          completionBlock:(JPPOPCompletionBlock)completionBlock;

#pragma mark - pop spring

/** toValue、springSpeed、springBounciness */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness;

/** toValue、springSpeed、springBounciness、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;

/** toValue、springSpeed、springBounciness、beginTime、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、springSpeed、springBounciness、beginTime、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;

/** fromValue、toValue、springSpeed、springBounciness、beginTime、key、completionBlock */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPropertyNamed:(NSString *)propertyNamed
                                                        fromValue:(id)fromValue
                                                          toValue:(id)toValue
                                                      springSpeed:(CGFloat)springSpeed
                                                 springBounciness:(CGFloat)springBounciness
                                                        beginTime:(NSTimeInterval)beginTime
                                                              key:(NSString *)key
                                                  completionBlock:(JPPOPCompletionBlock)completionBlock;

@end
