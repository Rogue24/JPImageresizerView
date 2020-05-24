//
//  UINavigationBar+JPExtension.h
//  WoLive
//
//  Created by 周健平 on 2019/1/9.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (JPExtension)
- (UIView *)jp_setupCustomNavigationBgView:(UIView *)customBgView;
- (UIView *)jp_setupNavigationBgView; // white view
- (void)jp_setNavigationBgColor:(UIColor *)color;
- (void)jp_setNavigationBgAlpha:(CGFloat)alpha;
@end
