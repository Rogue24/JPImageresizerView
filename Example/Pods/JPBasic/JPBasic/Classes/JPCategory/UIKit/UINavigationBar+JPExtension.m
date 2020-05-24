//
//  UINavigationBar+JPExtension.m
//  WoLive
//
//  Created by 周健平 on 2019/1/9.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import "UINavigationBar+JPExtension.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>

@implementation UINavigationBar (JPExtension)

- (void)setJp_navBgView:(UIView *)jp_navBgView {
    objc_setAssociatedObject(self, @selector(jp_navBgView), jp_navBgView, OBJC_ASSOCIATION_ASSIGN);
}
- (UIView *)jp_navBgView {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIView *)jp_setupCustomNavigationBgView:(UIView *)customBgView {
    if (self.jp_navBgView) [self.jp_navBgView removeFromSuperview];
    
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:[UIImage new]];
    
    UIView *navBgView = [self valueForKey:@"backgroundView"];
    [navBgView addSubview:customBgView];
    [customBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(navBgView);
    }];
    self.jp_navBgView = customBgView;
    
    return customBgView;
}

- (UIView *)jp_setupNavigationBgView {
    UIView *navBgView = [UIView new];
    navBgView.backgroundColor = UIColor.whiteColor;
    return [self jp_setupCustomNavigationBgView:navBgView];
}

- (void)jp_setNavigationBgColor:(UIColor *)color {
    if (!self.jp_navBgView) return;
    self.jp_navBgView.backgroundColor = color;
}

- (void)jp_setNavigationBgAlpha:(CGFloat)alpha {
    if (!self.jp_navBgView) return;
    self.jp_navBgView.alpha = alpha;
}
@end
