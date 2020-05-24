//
//  UIView+JPExtension.h
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIWindow+JPExtension.h"

@interface UIView (JPExtension)

@property (nonatomic, assign) CGRect jp_baseFrame;

@property (nonatomic, strong) CAShapeLayer *jp_maskLayer;
@property (nonatomic, strong) CAShapeLayer *jp_lineLayer;

/** 添加圆角（无边线） */
- (void)jp_addRoundedCornerWithSize:(CGSize)size radius:(CGFloat)radius maskColor:(UIColor *)maskColor;
/** 添加圆角 */
- (void)jp_addRoundedCornerWithSize:(CGSize)size radius:(CGFloat)radius maskColor:(UIColor *)maskColor lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor;

- (UIImage *)jp_convertToImage;

+ (instancetype)jp_viewLoadFromNib;

+ (UIWindow *)jp_frontWindow;
- (BOOL)jp_isShowingOnKeyWindow;

- (UIViewController *)jp_topViewController;
- (UINavigationController *)jp_topNavigationController;

@property (nonatomic, assign) CGFloat jp_x;
@property (nonatomic, assign) CGFloat jp_y;
@property (nonatomic, assign) CGFloat jp_width;
@property (nonatomic, assign) CGFloat jp_height;
@property (nonatomic, assign) CGPoint jp_origin;
@property (nonatomic, assign) CGSize jp_size;
@property (nonatomic, assign) CGFloat jp_midX;
@property (nonatomic, assign) CGFloat jp_midY;
@property (nonatomic, assign) CGFloat jp_maxX;
@property (nonatomic, assign) CGFloat jp_maxY;
@property (nonatomic, assign) CGFloat jp_centerX;
@property (nonatomic, assign) CGFloat jp_centerY;

@property (nonatomic, assign, readonly) CGFloat jp_radian;
@property (nonatomic, assign, readonly) CGFloat jp_angle;

@property (nonatomic, assign, readonly) CGFloat jp_scaleX;
@property (nonatomic, assign, readonly) CGFloat jp_scaleY;
@property (nonatomic, assign, readonly) CGPoint jp_scale;

@property (nonatomic, assign, readonly) CGFloat jp_translationX;
@property (nonatomic, assign, readonly) CGFloat jp_translationY;
@property (nonatomic, assign, readonly) CGPoint jp_translation;

@end

@interface CALayer (JPExtension)

// 暂停ca动画
- (void)jp_pauseAnimate;

// 恢复ca动画
- (void)jp_resumeAnimate;

- (UIImage *)jp_convertToImage;

@property (nonatomic, assign) CGFloat jp_x;
@property (nonatomic, assign) CGFloat jp_y;
@property (nonatomic, assign) CGFloat jp_width;
@property (nonatomic, assign) CGFloat jp_height;
@property (nonatomic, assign) CGPoint jp_origin;
@property (nonatomic, assign) CGSize jp_size;
@property (nonatomic, assign) CGFloat jp_midX;
@property (nonatomic, assign) CGFloat jp_midY;
@property (nonatomic, assign) CGFloat jp_maxX;
@property (nonatomic, assign) CGFloat jp_maxY;
@property (nonatomic, assign) CGFloat jp_anchorX;
@property (nonatomic, assign) CGFloat jp_anchorY;
@property (nonatomic, assign) CGFloat jp_positionX;
@property (nonatomic, assign) CGFloat jp_positionY;

@property (nonatomic, assign, readonly) CGFloat jp_radian;
@property (nonatomic, assign, readonly) CGFloat jp_angle;

@property (nonatomic, assign, readonly) CGFloat jp_scaleX;
@property (nonatomic, assign, readonly) CGFloat jp_scaleY;
@property (nonatomic, assign, readonly) CGPoint jp_scale;

@property (nonatomic, assign, readonly) CGFloat jp_translationX;
@property (nonatomic, assign, readonly) CGFloat jp_translationY;
@property (nonatomic, assign, readonly) CGPoint jp_translation;

@end

