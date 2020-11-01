//
//  JPBounceView.h
//  Infinitee2.0
//
//  Created by 周健平 on 2017/10/12.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPBounceView : UIView
/** 默认0.15 */
@property (nonatomic, assign) NSTimeInterval imageSetterDuration;
@property (nonatomic, strong) UIImage *image;
- (void)setImage:(UIImage *)image animated:(BOOL)animated;

/** 默认YES */
@property (nonatomic, assign) BOOL isBounce;
/** 默认1.13 */
@property (nonatomic, assign) CGFloat scale;
/** 默认0.27 */
@property (nonatomic, assign) NSTimeInterval scaleDuration;
/** 默认20.0 */
@property (nonatomic, assign) CGFloat recoverSpeed;
/** 默认17.0 */
@property (nonatomic, assign) CGFloat recoverBounciness;
/** 默认NO */
@property (nonatomic, assign) BOOL isJudgeBegin;
/** 默认YES */
@property (nonatomic, assign) BOOL isCanTouchesBegan;

@property (nonatomic, copy) void (^viewTouchUpInside)(JPBounceView *bounceView);

- (void)recover;
@property (nonatomic, assign) BOOL isTouching;
@property (nonatomic, copy) void (^touchingDidChanged)(BOOL isTouching);
@end
