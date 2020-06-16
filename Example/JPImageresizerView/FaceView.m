//
//  FaceView.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/6/15.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "FaceView.h"

@interface FaceView () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *withdrawBtn;
@property (nonatomic, weak) UIButton *scaleBtn;
@property (nonatomic, weak) CALayer *borderLayer;

@property (nonatomic, assign) BOOL paning;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *operations;

// 缩放+旋转用到的属性
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, assign) CGPoint diffPoint;
@property (nonatomic, assign) CGFloat minRadius;
@property (nonatomic, assign) CGFloat maxRadius;
@property (nonatomic, assign) CGFloat currentRadius;
@end

@implementation FaceView
{
    BOOL _isShowingOther;
    BOOL _isHideOther;
}

#pragma mark - getter

- (NSMutableArray *)operations {
    if (!_operations) {
        _operations = [NSMutableArray array];
    }
    return _operations;
}

#pragma mark - setter

- (void)setPaning:(BOOL)paning {
    if (_paning == paning) return;
    _paning = paning;
    [self.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:(paning ? @0.7 : @1) duration:0.2];
}

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        _isShowingOther = YES;

        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = self.bounds;
        borderLayer.borderWidth = 2;
        borderLayer.borderColor = UIColor.whiteColor.CGColor;
        [self.layer addSublayer:borderLayer];
        self.borderLayer = borderLayer;

        UIButton *withdrawBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[[UIImage imageNamed:@"jp_reset_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            btn.frame = CGRectMake(-10, -10, 20, 20);
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            [btn addTarget:self action:@selector(withdrawAction) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self addSubview:withdrawBtn];
        self.withdrawBtn = withdrawBtn;

        UIButton *scaleBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[[UIImage imageNamed:@"jp_zoom_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            btn.frame = CGRectMake(frame.size.width - 10, frame.size.height - 10, 20, 20);
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn;
        });
        [self addSubview:scaleBtn];
        self.scaleBtn = scaleBtn;

        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGR];

        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        panGR.delegate = self;
        [self addGestureRecognizer:panGR];
        
        CGPoint diagonalPoint = CGPointMake(frame.size.width, frame.size.height);
        self.currentRadius = [JPSolveTool radiusFromCenter:CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5) point:diagonalPoint];
        self.maxRadius = self.currentRadius * 1.3;
        self.minRadius = self.currentRadius * 0.8;
        UIPanGestureRecognizer *scaleRotationGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(scaleRotation:)];
        [self.scaleBtn addGestureRecognizer:scaleRotationGR];
    }
    return self;
}

- (void)dealloc {
    [self __removeTimer];
}

#pragma mark - 监听手势

- (void)tap:(UITapGestureRecognizer *)tapGR {
    if (_isShowingOther) {
        [self __hideOther];
    } else {
        [self __showOther:YES];
    }
}

- (void)pan:(UIPanGestureRecognizer *)panGR {
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.paning = YES;
        [self __showOther:NO];
    }

    if (panGR.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGR translationInView:self.superview];
        [panGR setTranslation:CGPointZero inView:self.superview];
        
        CGPoint position = self.layer.position;
        position.x += translation.x;
        position.y += translation.y;
        
        CGFloat halfW = -self.frame.size.width * 0.4;
        CGFloat halfH = -self.frame.size.height * 0.4;
        if (position.x < halfW) {
            position.x = halfW;
        } else if ((position.x + halfW) > self.superview.jp_width) {
            position.x = self.superview.jp_width - halfW;
        }
        if (position.y < halfH) {
            position.y = halfH;
        } else if ((position.y + halfH) > self.superview.jp_height) {
            position.y = self.superview.jp_height - halfH;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.layer.position = position;
        [CATransaction commit];
    }

    if (panGR.state == UIGestureRecognizerStateEnded ||
        panGR.state == UIGestureRecognizerStateCancelled ||
        panGR.state == UIGestureRecognizerStateFailed) {
        self.paning = NO;
        [self __saveLayout];
        [self __showOther:YES];
    }
}

// 缩放+旋转
- (void)scaleRotation:(UIPanGestureRecognizer *)scaleRotationGR {
    if (scaleRotationGR.state == UIGestureRecognizerStateBegan) {
        [self __showOther:NO];
        self.previousPoint = [scaleRotationGR locationInView:self.superview];
        self.diffPoint = [scaleRotationGR locationInView:scaleRotationGR.view];
        self.diffPoint = CGPointMake(self.diffPoint.x - scaleRotationGR.view.bounds.size.width * 0.5,
                                     self.diffPoint.y - scaleRotationGR.view.bounds.size.height * 0.5);
        self.currentRadius = [JPSolveTool radiusFromCenter:self.layer.position point:CGPointMake(self.previousPoint.x - self.diffPoint.x, self.previousPoint.y - self.diffPoint.y)];
    }
    
    if (scaleRotationGR.state == UIGestureRecognizerStateChanged) {
        CGPoint position = self.layer.position;
        CGPoint previousPoint = self.previousPoint;
        CGPoint currentPoint = [scaleRotationGR locationInView:self.superview];
        
        CGFloat angle = atan2f(currentPoint.y - position.y, currentPoint.x - position.x) - atan2f(previousPoint.y - position.y, previousPoint.x - position.x);
        
        CGFloat currentRadius = [JPSolveTool radiusFromCenter:position point:CGPointMake(currentPoint.x - self.diffPoint.x, currentPoint.y - self.diffPoint.y)];
        if (currentRadius < self.minRadius) currentRadius = self.minRadius;
        if (currentRadius > self.maxRadius) currentRadius = self.maxRadius;
        CGFloat scale = currentRadius / self.currentRadius;
        
        CATransform3D transform = self.layer.transform;
        transform = CATransform3DScale(transform, scale, scale, 1);
        transform = CATransform3DRotate(transform, angle, 0, 0, 1);
        
        angle = -angle;
        scale = 1.0 / scale;
        
        CATransform3D withdrawBtnTransform = self.withdrawBtn.layer.transform;
        withdrawBtnTransform = CATransform3DScale(withdrawBtnTransform, scale, scale, 1);
        withdrawBtnTransform = CATransform3DRotate(withdrawBtnTransform, angle, 0, 0, 1);

        CATransform3D scaleBtnTransform = self.scaleBtn.layer.transform;
        scaleBtnTransform = CATransform3DScale(scaleBtnTransform, scale, scale, 1);
        scaleBtnTransform = CATransform3DRotate(scaleBtnTransform, angle, 0, 0, 1);
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.layer.transform = transform;
        self.borderLayer.borderWidth *= scale;
        self.withdrawBtn.layer.transform = withdrawBtnTransform;
        self.scaleBtn.layer.transform = scaleBtnTransform;
        [CATransaction commit];
        
        self.previousPoint = currentPoint;
        self.currentRadius = currentRadius;
    }
    
    if (scaleRotationGR.state == UIGestureRecognizerStateEnded ||
        scaleRotationGR.state == UIGestureRecognizerStateCancelled ||
        scaleRotationGR.state == UIGestureRecognizerStateFailed) {
        [self __saveLayout];
        [self __showOther:YES];
    }
}


#pragma mark - 监听按钮

- (void)withdrawAction {
    if (self.operations.count <= 1) {
        [self __showOther:YES];
        return;
    }
    
    [self __showOther:NO];
    
    NSDictionary *layoutDic = self.operations[self.operations.count - 2];
    [self.operations removeLastObject];
    
    CGPoint position = [layoutDic[@"position"] CGPointValue];
    
    CGFloat scale = [layoutDic[@"scale"] doubleValue];
    
    CGFloat radian = [layoutDic[@"radian"] doubleValue];
    
    CATransform3D transform = CATransform3DMakeScale(scale, scale, 1);
    transform = CATransform3DRotate(transform, radian, 0, 0, 1);
    
    radian = -radian;
    scale = 1.0 / scale;
    CATransform3D btnTransform = CATransform3DMakeScale(scale, scale, 1);
    btnTransform = CATransform3DRotate(btnTransform, radian, 0, 0, 1);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.layer.transform = transform;
        self.layer.position = position;
        self.borderLayer.borderWidth = 2 * scale;
        self.withdrawBtn.layer.transform = btnTransform;
        self.scaleBtn.layer.transform = btnTransform;
    } completion:^(BOOL finished) {
        if (finished) {
            [self __showOther:YES];
        }
    }];
}

#pragma mark - 重写父类方法

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        [self.operations removeAllObjects];
        [self __saveLayout];
        [self __showOther:YES];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!view) {
        if (CGRectContainsPoint(CGRectInset(self.withdrawBtn.frame, -5, -5), point)) {
            return self.withdrawBtn;
        } else if (CGRectContainsPoint(CGRectInset(self.scaleBtn.frame, -5, -5), point)) {
            return self.scaleBtn;
        } else {
            if (_isShowingOther) [self __hideOther];
        }
    }
    return view;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.view == self) {
        CGPoint point = [gestureRecognizer locationInView:self];
        if (CGRectContainsPoint(CGRectInset(self.withdrawBtn.frame, -5, -5), point)) {
            return NO;
        } else if (CGRectContainsPoint(CGRectInset(self.scaleBtn.frame, -5, -5), point)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 公开方法

- (UIImage *)faceImage {
    return self.imageView.image;
}
- (CGRect)faceBounds {
    return self.layer.bounds;
}
- (CGPoint)faceOrigin {
    return [self convertPoint:CGPointZero toView:self.superview];
}
- (CGFloat)faceScale {
    return self.layer.jp_scaleX;
}
- (CGFloat)faceRadian {
    return self.layer.jp_radian;
}

#pragma mark - 私有方法

- (void)__saveLayout {
    CGPoint position = self.layer.position;
    CGFloat scale = self.layer.jp_scaleX;
    CGFloat radian = self.layer.jp_radian;
    
    NSDictionary *lastLayoutDic = self.operations.lastObject;
    CGPoint lPosition = [lastLayoutDic[@"position"] CGPointValue];
    CGFloat lScale = [lastLayoutDic[@"scale"] doubleValue];
    CGFloat lRadian = [lastLayoutDic[@"radian"] doubleValue];
    
    if (!CGPointEqualToPoint(position, lPosition) || scale != lScale || radian != lRadian) {
        NSDictionary *layoutDic = @{@"position": @(position),
                                    @"scale": @(scale),
                                    @"radian": @(radian)};
        [self.operations addObject:layoutDic];
    }
}

- (void)__showOther:(BOOL)isAutoHide {
    [self __removeTimer];
    if (_isShowingOther) {
        if (isAutoHide) [self __addTimer];
        return;
    }
    _isShowingOther = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.borderLayer.borderColor = UIColor.whiteColor.CGColor;
        self.withdrawBtn.alpha = 1;
        self.scaleBtn.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished && isAutoHide) [self __addTimer];
    }];
}

- (void)__hideOther {
    [self __removeTimer];
    if (!_isShowingOther) return;
    _isShowingOther = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.borderLayer.borderColor = UIColor.clearColor.CGColor;
        self.withdrawBtn.alpha = 0;
        self.scaleBtn.alpha = 0;
    }];
}

#pragma mark - timer

- (void)__addTimer {
    [self __removeTimer];
    self.timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(__hideOther) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)__removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
