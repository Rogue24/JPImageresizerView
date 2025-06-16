//
//  JPGlassEffectViewController.m
//  JPImageresizerView_Example
//
//  Created by aa on 2025/6/11.
//  Copyright © 2025 ZhouJianPing. All rights reserved.
//

#import "JPGlassEffectViewController.h"
#import <JPImageresizerView_Example-Swift.h>

@interface JPGlassEffectViewController ()

@end

@implementation JPGlassEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage randomGirlImage]];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.frame = self.view.bounds;
    [self.view addSubview:imgView];
    
    
    
    if (@available(iOS 26.0, *)) {
        // 1️⃣ 添加全屏玻璃背景
//        UIGlassEffect *glassEffect = [[UIGlassEffect alloc] init];
//        glassEffect.interactive = YES;
//        glassEffect.tintColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.2];
//        
//        UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:glassEffect];
//        glassView.frame = CGRectMake(80, 150, 200, 200); // self.view.bounds;
//        glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        [self.view addSubview:glassView];
//        
//        // 2️⃣ 添加玻璃容器 + 多个小玻璃块
//        UIGlassContainerEffect *glassContainer = [[UIGlassContainerEffect alloc] init];
//        glassContainer.spacing = 12.0;
//        
//        UIVisualEffectView *containerView = [[UIVisualEffectView alloc] initWithEffect:glassContainer];
//        containerView.frame = CGRectMake(80, 150, 100, 100); // self.view.bounds;
//        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        [self.view addSubview:containerView];
//        
//        // 添加3个玻璃块
//        for (NSInteger i = 0; i < 3; i++) {
//            UIGlassEffect *blockEffect = [[UIGlassEffect alloc] init];
//            blockEffect.interactive = NO;
//            blockEffect.tintColor = [[UIColor systemPinkColor] colorWithAlphaComponent:0.3 + 0.1 * i];
//            
//            UIVisualEffectView *blockView = [[UIVisualEffectView alloc] initWithEffect:blockEffect];
//            blockView.frame = CGRectMake(60 + i * 80, 150, 100, 100);
//            blockView.layer.cornerRadius = 20;
//            blockView.clipsToBounds = YES;
//            
//            [containerView.contentView addSubview:blockView];
//        }
        
        UIGlassContainerEffect *glassContainer = [[UIGlassContainerEffect alloc] init];
        glassContainer.spacing = 12.0;
        UIVisualEffectView *containerView = [[UIVisualEffectView alloc] initWithEffect:glassContainer];
        containerView.frame = self.view.bounds;
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:containerView];
        containerView.userInteractionEnabled = YES;
        
        UIGlassEffect *blockEffect = [[UIGlassEffect alloc] init];
        blockEffect.interactive = NO;
        blockEffect.tintColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];
        UIVisualEffectView *blockView = [[UIVisualEffectView alloc] initWithEffect:blockEffect];
        blockView.frame = CGRectMake(160, 250, 100, 100);
        blockView.layer.cornerRadius = 20;
        blockView.clipsToBounds = YES;
        [containerView.contentView addSubview:blockView];
//        [self.view addSubview:blockView];
        
        UIGlassEffect *blockEffect3 = [[UIGlassEffect alloc] init];
        blockEffect3.interactive = YES;
        blockEffect3.tintColor = [UIColor clearColor];
        UIVisualEffectView *blockView3 = [[UIVisualEffectView alloc] initWithEffect:blockEffect3];
        blockView3.frame = CGRectMake(160, 550, 100, 100);
        blockView3.layer.cornerRadius = 20;
        blockView3.clipsToBounds = YES;
        [containerView.contentView addSubview:blockView3];
        
        
        
        
        
        
        
        
        
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(160, 400, 150, 150)];
        v.backgroundColor = JPRandomColor;
        v.userInteractionEnabled = NO;
//        [containerView.contentView addSubview:v];
        [self.view insertSubview:v aboveSubview:imgView];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = v.bounds;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.fillRule = kCAFillRuleEvenOdd;
//        blockView2.layer.mask = maskLayer;
        v.layer.mask = maskLayer;
        UIBezierPath *framePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, 20, 110, 110) cornerRadius:20];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:v.bounds];
        [maskPath appendPath:framePath];
        maskLayer.path = maskPath.CGPath;
        
        UIGlassEffect *blockEffect2 = [[UIGlassEffect alloc] init];
        blockEffect2.interactive = YES;
        blockEffect2.tintColor = [UIColor clearColor];
        UIVisualEffectView *blockView2 = [[UIVisualEffectView alloc] initWithEffect:blockEffect2];
        blockView2.frame = CGRectMake(160, 400, 150, 150);
        blockView2.layer.cornerRadius = 20;
        blockView2.clipsToBounds = YES;
        [containerView.contentView addSubview:blockView2];
        
        
//        blockView2.frame = v.bounds;
//        [v addSubview:blockView2];
        
        blockView2.userInteractionEnabled = YES;
        [blockView2 addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMe:)]];
    } else {
        NSLog(@"UIGlassEffect 需要 iOS 26.0+ 才能使用");
    }
}

- (void)panMe:(UIPanGestureRecognizer *)panGR {
    UIView *view = panGR.view;
    UIView *superview = panGR.view.superview;
    
    CGPoint translation = [panGR translationInView:superview];
    [panGR setTranslation:CGPointZero inView:superview];
    
    switch (panGR.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            break;
            
        default: {
            CGRect frame = view.frame;
            frame.origin.x += translation.x;
            frame.origin.y += translation.y;
            view.frame = frame;
            break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (@available(iOS 26.0, *)) {
        self.navigationController.interactiveContentPopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 26.0, *)) {
        self.navigationController.interactiveContentPopGestureRecognizer.enabled = YES;
    }
}

@end
