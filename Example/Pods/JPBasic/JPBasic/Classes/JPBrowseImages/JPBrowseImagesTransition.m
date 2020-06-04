//
//  BrowseImagesTransition.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImagesTransition.h"
#import "JPBrowseImagesViewController.h"

@interface JPBrowseImagesTransition ()
@property (nonatomic, assign) BOOL isPresent;
@end

@implementation JPBrowseImagesTransition

+ (instancetype)presentTransition {
    return [[self alloc] initWithIsPresent:YES];
}

+ (instancetype)dismissTransition {
    return [[self alloc] initWithIsPresent:NO];
}

- (instancetype)initWithIsPresent:(BOOL)isPresent {
    self = [super init];
    if (self) {
        _isPresent = isPresent;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5; // 0.45
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresent) {
        [self presentAnimation:transitionContext];
    } else {
        [self dismissAnimation:transitionContext];
    }
}

/**
 * present动画
 */
- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    JPBrowseImagesViewController *toVC = (JPBrowseImagesViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    [toVC willTransitionAnimateion:self.isPresent];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0 options:0 animations:^{
        [toVC transitionAnimateion:self.isPresent];
    } completion:^(BOOL finished) {
        [toVC transitionDoneAnimateion:self.isPresent complete:^{
            [transitionContext completeTransition:YES];
        }];
    }];
}

/**
 * dimiss动画
 */
- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    JPBrowseImagesViewController *fromVC = (JPBrowseImagesViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [fromVC willTransitionAnimateion:self.isPresent];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0 options:kNilOptions animations:^{
        [fromVC transitionAnimateion:self.isPresent];
    } completion:^(BOOL finished) {
        [fromVC transitionDoneAnimateion:self.isPresent complete:^{
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }];
}

@end
