//
//  JPInteractiveTransition.h
//  Infinitee2.0
//
//  Created by guanning on 2016/12/28.
//  Copyright © 2016年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GestureConifg)(void);

/**
 *  动画过渡类型
 */
typedef NS_ENUM(NSUInteger, JPTransitionType) {
    JPTransitionTypePush = 0,
    JPTransitionTypePop,
    JPTransitionPresent,
    JPTransitionDismiss
};

typedef NS_ENUM(NSUInteger, JPInteractiveTransitionGestureDirection) {
    // 手势的方向
    JPInteractiveTransitionGestureDirectionLeft = 0,
    JPInteractiveTransitionGestureDirectionRight,
    JPInteractiveTransitionGestureDirectionUp,
    JPInteractiveTransitionGestureDirectionDown
};

@interface JPInteractiveTransition : UIPercentDrivenInteractiveTransition

/**记录是否开始手势，判断pop操作是手势触发还是返回键触发*/
@property (nonatomic, assign) BOOL interation;

/**促发手势present的时候的config，config中初始化并present需要弹出的控制器*/
@property (nonatomic, copy) GestureConifg presentConifg;

/**促发手势push的时候的config，config中初始化并push需要弹出的控制器*/
@property (nonatomic, copy) GestureConifg pushConifg;

@property (nonatomic, weak) UIScreenEdgePanGestureRecognizer *pan;

@property (nonatomic, copy) void (^persentDidChange)(CGFloat persent);

//初始化方法
+ (instancetype)interactiveTransitionWithTransitionType:(JPTransitionType)type direction:(JPInteractiveTransitionGestureDirection)direction;
- (instancetype)initWithTransitionType:(JPTransitionType)type direction:(JPInteractiveTransitionGestureDirection)direction;

/** 给传入的控制器添加手势 */
- (void)addPanGestureForViewController:(UIViewController *)viewController panView:(UIView *)panView referenceView:(UIView *)referenceView;

- (void)removePanGesture;

@end
