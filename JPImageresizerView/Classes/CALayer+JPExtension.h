//
//  CALayer+JPExtension.h
//  JPImageresizerView
//
//  Created by 周健平 on 2019/8/2.
//

#import <QuartzCore/QuartzCore.h>

@interface CABasicAnimation (JPExtension)

+ (CABasicAnimation *)jp_backwardsAnimationWithKeyPath:(NSString *)keyPath
                                             fromValue:(id)fromValue
                                               toValue:(id)toValue
                                    timingFunctionName:(CAMediaTimingFunctionName)timingFunctionName
                                              duration:(NSTimeInterval)duration;

@end

@interface CALayer (JPExtension)

- (void)jp_addBackwardsAnimationWithKeyPath:(NSString *)keyPath
                                  fromValue:(id)fromValue
                                    toValue:(id)toValue
                         timingFunctionName:(CAMediaTimingFunctionName)timingFunctionName
                                   duration:(NSTimeInterval)duration;

@end
