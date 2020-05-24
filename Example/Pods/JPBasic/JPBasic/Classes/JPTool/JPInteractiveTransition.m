//
//  JPInteractiveTransition.m
//  Infinitee2.0
//
//  Created by guanning on 2016/12/28.
//  Copyright © 2016年 Infinitee. All rights reserved.
//

#import "JPInteractiveTransition.h"

@interface JPInteractiveTransition ()

@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, weak) UIView *panView;
@property (nonatomic, weak) UIView *referenceView;

/** 手势方向 */
@property (nonatomic, assign) JPInteractiveTransitionGestureDirection direction;
/** 手势类型 */
@property (nonatomic, assign) JPTransitionType type;

@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation JPInteractiveTransition
{
    CGFloat _transitionValue;
    CGFloat _persent;
    CGFloat _linkValue;
}

+ (instancetype)interactiveTransitionWithTransitionType:(JPTransitionType)type direction:(JPInteractiveTransitionGestureDirection)direction {
    return [[self alloc] initWithTransitionType:type direction:direction];
}

- (instancetype)initWithTransitionType:(JPTransitionType)type direction:(JPInteractiveTransitionGestureDirection)direction {
    if (self = [super init]) {
        _direction = direction;
        _type = type;
        _linkValue = 1.0 / 30.0;
    }
    return self;
}

- (void)addPanGestureForViewController:(UIViewController *)viewController panView:(UIView *)panView referenceView:(UIView *)referenceView {
    
    if (self.panView && self.pan && [self.panView.gestureRecognizers containsObject:self.pan]) {
        [self.panView removeGestureRecognizer:self.pan];
    }
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pan.edges = UIRectEdgeLeft;
    [panView addGestureRecognizer:pan];
    
    self.pan = pan;
    self.vc = viewController;
    self.panView = panView;
    self.referenceView = referenceView;
}

- (void)removePanGesture {
    [self.panView removeGestureRecognizer:self.pan];
    self.pan = nil;
    self.vc = nil;
    self.panView = nil;
    self.referenceView = nil;
}

- (void)dealloc {
    [self removePanGesture];
}

/**
 *  手势过渡的过程
 */
- (void)handleGesture:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint velocity = [panGesture velocityInView:_referenceView];
    
    CGPoint transition = [panGesture translationInView:_referenceView];
    
    [panGesture setTranslation:CGPointZero inView:_referenceView];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 手势开始的时候标记手势状态，并开始相应的事件
            self.interation = YES;
            _transitionValue = 0;
            _persent = 0;
            [self startGesture];
            !self.persentDidChange ? : self.persentDidChange(0);
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (_transitionValue == 0) {
                [self updateInteractiveTransition:0];
            }
            
            // 手势百分比
            switch (_direction) {
                case JPInteractiveTransitionGestureDirectionLeft:
                {
                    _transitionValue += (-1.0 * transition.x);
                }
                    break;
                case JPInteractiveTransitionGestureDirectionRight:
                {
                    _transitionValue += transition.x;
                }
                    break;
                case JPInteractiveTransitionGestureDirectionUp:
                {
                    _transitionValue += (-1.0 * transition.y);
                }
                    break;
                case JPInteractiveTransitionGestureDirectionDown:
                {
                    _transitionValue += transition.y;
                }
                    break;
            }
            
            if (_transitionValue < 0) _transitionValue = 0;
            CGFloat persent = _transitionValue / _referenceView.bounds.size.width;
            
            _persent = persent;
            
            // 手势过程中，通过updateInteractiveTransition设置pop过程进行的百分比
            [self updateInteractiveTransition:persent];
            !self.persentDidChange ? : self.persentDidChange(persent);
            
//            JPLog(@"persent ==== %.2lf", persent);
//            JPLog(@"transitionValue ==== %.2lf", _transitionValue);
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            // 手势完成后结束标记并且判断移动距离是否过半，过则finishInteractiveTransition完成转场操作，否则取消转场操作
            self.interation = NO;
            _transitionValue = 0;
            
            CGFloat velocityValue = (_direction == JPInteractiveTransitionGestureDirectionLeft ||
                                     _direction == JPInteractiveTransitionGestureDirectionRight) ? velocity.x : velocity.y;
            
            if (velocityValue > 500 || _persent > 0.5) {
                _persent = 0;
                [self finishInteractiveTransition];
                !self.persentDidChange ? : self.persentDidChange(1);
            } else {
                
                if (_persent > 0 && panGesture.state == UIGestureRecognizerStateEnded) {
                    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
                    [self addLink];
                    return;
                }
                
                [self cancelInteractiveTransition];
                !self.persentDidChange ? : self.persentDidChange(0);
            }
            break;
        }
        default:
            break;
    }

}

- (void)addLink {
    [self removeLink];
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkHandle)];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLink {
    if (self.link) {
        [self.link invalidate];
        self.link = nil;
    }
}

- (void)linkHandle {
    _persent -= _linkValue;
    if (_persent > 0) {
        [self updateInteractiveTransition:_persent];
    } else {
        _persent = 0;
        [self removeLink];
        [self cancelInteractiveTransition];
        !self.persentDidChange ? : self.persentDidChange(0);
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    }
}

- (void)startGesture {
    switch (_type) {
        case JPTransitionPresent:
        {
            if (_presentConifg) {
                _presentConifg();
            }
        }
            break;
            
        case JPTransitionDismiss:
        {
            [_vc dismissViewControllerAnimated:YES completion:nil];
            break;
        }
            
        case JPTransitionTypePush:
        {
            if (_pushConifg) {
                _pushConifg();
            }
        }
            break;
        case JPTransitionTypePop:
        {
            [_vc.navigationController popViewControllerAnimated:YES];
            break;
        }
    }
}

@end
