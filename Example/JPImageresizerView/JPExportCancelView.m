//
//  JPExportCancelView.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/7/21.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPExportCancelView.h"

@interface JPExportCancelView ()
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, copy) void (^cancelHandler)(void);
@end
@implementation JPExportCancelView

+ (void)showWithCancelHandler:(void (^)(void))cancelHandler {
    JPExportCancelView *ecView = (JPExportCancelView *)[JPKeyWindow viewWithTag:184669029];
    if (!ecView) {
        ecView = [[self alloc] init];
        ecView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        UIButton *cancelBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.layer.cornerRadius = 2;
            btn.backgroundColor = UIColor.whiteColor;
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitle:@"取消导出" forState:UIControlStateNormal];
            [btn addTarget:ecView action:@selector(__cancelAction) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [ecView addSubview:cancelBtn];
        ecView.cancelBtn = cancelBtn;
        
        [ecView __didChangeStatusBarOrientation];
        JPObserveNotification(ecView, @selector(__didChangeStatusBarOrientation), UIApplicationDidChangeStatusBarOrientationNotification, nil);
        
        ecView.tag = 184669029;
        ecView.alpha = 0;
        [JPKeyWindow addSubview:ecView];
    }
    
    ecView.cancelHandler = cancelHandler;
    
    [UIView animateWithDuration:0.25 animations:^{
        ecView.alpha = 1;
    }];
}

+ (void)hide {
    JPExportCancelView *ecView = (JPExportCancelView *)[JPKeyWindow viewWithTag:184669029];
    if (ecView) [ecView __hideView];
}

- (void)dealloc {
    JPRemoveNotification(self);
}

- (void)__didChangeStatusBarOrientation {
    self.frame = JPScreenBounds;
    CGFloat w = 70;
    CGFloat h = 30;
    CGFloat x = JPHalfOfDiff(JPScreenWidth, w);
    CGFloat y = JPScreenHeight * 0.6;
    self.cancelBtn.frame = CGRectMake(x, y, w, h);
}

- (void)__cancelAction {
    !self.cancelHandler ? : self.cancelHandler();
    [self __hideView];
}

- (void)__hideView {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
