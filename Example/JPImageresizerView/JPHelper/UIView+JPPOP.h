//
//  UIView+JPPOP.h
//  WoLive
//
//  Created by 周健平 on 2019/8/23.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>

@interface UIView (JPPOP)

// ********************************************* pop basic *********************************************
/** Basic 只有toValue */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue;

/** Basic 只有toValue，propertyNamed为key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Basic 有fromValue、toValue，propertyNamed为key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Basic 有toValue、key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Basic 有fromValue、toValue、key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

// ********************************************* pop spring *********************************************
/** Spring 只有toValue */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue;

/** Spring 只有toValue，propertyNamed为key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Spring 有fromValue、toValue，propertyNamed为key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Spring 有toValue、key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Spring 有fromValue、toValue、key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

@end


@interface CALayer (JPPOP)

// ********************************************* pop basic *********************************************
/** Basic 只有toValue */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue;

/** Basic 只有toValue，propertyNamed为key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Basic 有fromValue、toValue，propertyNamed为key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Basic 有toValue、key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Basic 有fromValue、toValue、key */
- (POPBasicAnimation *)jp_addPOPBasicAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       beginTime:(NSTimeInterval)beginTime
                                                        duration:(NSTimeInterval)duration
                                                       fromValue:(id)fromValue
                                                         toValue:(id)toValue
                                                             key:(NSString *)key
                                                 completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

// ********************************************* pop spring *********************************************
/** Spring 只有toValue */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue;

/** Spring 只有toValue，propertyNamed为key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Spring 有fromValue、toValue，propertyNamed为key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Spring 有toValue、key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

/** Spring 有fromValue、toValue、key */
- (POPSpringAnimation *)jp_addPOPSpringAnimationWithPpropertyNamed:(NSString *)propertyNamed
                                                         beginTime:(NSTimeInterval)beginTime
                                                       springSpeed:(CGFloat)springSpeed
                                                  springBounciness:(CGFloat)springBounciness
                                                         fromValue:(id)fromValue
                                                           toValue:(id)toValue
                                                               key:(NSString *)key
                                                   completionBlock:(void(^)(POPAnimation *anim, BOOL finished))completionBlock;

@end
