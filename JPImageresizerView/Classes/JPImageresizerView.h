//
//  JPImageresizerView.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerConfigure.h"
#import "JPImageresizerFrameView.h"

@interface JPImageresizerView : UIView

/**
 * 层级结构
    - JPImageresizerView（self）
        - scrollView
            - imageView（裁剪的imageView）
        - frameView（绘制裁剪边框的view）
 * scrollView与frameView的frame一致
 */
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) JPImageresizerFrameView *frameView;

/*!
 @method
 @brief 类方法（推荐）
 @param configure --- 包含了所有初始化参数
 @discussion 使用JPImageresizerConfigure配置好参数
 */
+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure *)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

/*!
 @method
 @brief 工厂方法
 @param verBaseMargin --- 裁剪图片与裁剪区域的垂直间距
 @param horBaseMargin --- 裁剪图片与裁剪区域的水平间距
 @param contentInsets --- 裁剪区域与主视图的内边距，目前初始化后不可再更改
 @param borderImage --- 边框图片（nil则使用frameType的边线）
 @param borderImageRectInset --- 边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距）
 @param imageresizerIsCanRecovery --- 是否可以重置的回调（当裁剪区域缩放至适应范围后就会触发该回调）
 @param imageresizerIsPrepareToScale --- 是否预备缩放裁剪区域至适应范围（当裁剪区域发生变化的开始和结束就会触发该回调）
 @discussion 自行配置参数
 */
- (instancetype)initWithResizeImage:(UIImage *)resizeImage
                              frame:(CGRect)frame
                           maskType:(JPImageresizerMaskType)maskType
                          frameType:(JPImageresizerFrameType)frameType
                     animationCurve:(JPAnimationCurve)animationCurve
                        strokeColor:(UIColor *)strokeColor
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha
                      verBaseMargin:(CGFloat)verBaseMargin
                      horBaseMargin:(CGFloat)horBaseMargin
                      resizeWHScale:(CGFloat)resizeWHScale
                      contentInsets:(UIEdgeInsets)contentInsets
                        borderImage:(UIImage *)borderImage
               borderImageRectInset:(CGPoint)borderImageRectInset
          imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
       imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

/** 遮罩样式，目前初始化后不可再更改 */
@property (nonatomic, readonly) JPImageresizerMaskType maskType;

/** 边框样式 */
@property (nonatomic) JPImageresizerFrameType frameType;

/** 动画曲线（默认是线性Linear） */
@property (nonatomic, assign) JPAnimationCurve animationCurve;

/** 裁剪的图片 */
@property (nonatomic) UIImage *resizeImage;

/** 裁剪线颜色 */
@property (nonatomic) UIColor *strokeColor;

/** 背景颜色 */
@property (nonatomic) UIColor *bgColor;

/** 遮罩颜色的透明度（背景颜色 * 透明度） */
@property (nonatomic) CGFloat maskAlpha;

/** 裁剪宽高比（0则为任意比例，可控8个方向，固定比例为4个方向） */
@property (nonatomic) CGFloat resizeWHScale;
- (void)setResizeWHScale:(CGFloat)resizeWHScale animated:(BOOL)isAnimated;

/** 初始裁剪宽高比（默认为初始化时的resizeWHScalem，调用recoveryByInitialResizeWHScale方法进行重置则resizeWHScale会重置为该属性的值） */
@property (nonatomic) CGFloat initialResizeWHScale;

/** 裁剪框边线能否进行对边拖拽（当裁剪宽高比为0，即任意比例时才有效，默认为yes） */
@property (nonatomic, assign) BOOL edgeLineIsEnabled;

/** 裁剪图片与裁剪区域的垂直边距 */
@property (nonatomic, assign) CGFloat verBaseMargin;

/** 裁剪图片与裁剪区域的水平边距 */
@property (nonatomic, assign) CGFloat horBaseMargin;

/** 是否顺时针旋转（默认逆时针） */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/** 是否锁定裁剪区域（锁定后无法拖动裁剪区域） */
@property (nonatomic) BOOL isLockResizeFrame;

/** verticalityMirror：垂直镜像，沿着Y轴旋转180° */
@property (nonatomic, assign) BOOL verticalityMirror;
- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated;

/** horizontalMirror：水平镜像，沿着X轴旋转180° */
@property (nonatomic, assign) BOOL horizontalMirror;
- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated;

/** 预览模式（隐藏边框，停止拖拽操作，用于预览裁剪后的区域） */
@property (nonatomic, assign) BOOL isPreview;
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated;

/** 边框图片（nil则使用frameType的边线） */
@property (nonatomic) UIImage *borderImage;

/** 边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距） */
@property (nonatomic) CGPoint borderImageRectInset;

/*!
 @method
 @brief 同时更新图片、垂直边距和水平边距
 @discussion 同步更新
 */
- (void)updateResizeImage:(UIImage *)resizeImage verBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin;

/*!
 @method
 @brief 旋转图片
 @discussion 旋转90度，支持4个方向，分别是垂直向上、水平向左、垂直向下、水平向右
 */
- (void)rotation;

/*!
 @method
 @brief 按初始裁剪宽高比进行重置
 @discussion 回到最初状态，resizeWHScale会重置为initialResizeWHScale的值
 */
- (void)recoveryByInitialResizeWHScale;

/*!
 @method
 @brief 按当前裁剪宽高比进行重置
 @discussion 回到最初状态，resizeWHScale不会被重置
 */
- (void)recoveryByCurrentResizeWHScale;

/*!
 @method
 @brief 按指定裁剪宽高比进行重置
 @param resizeWHScale --- 指定裁剪宽高比
 @discussion 回到最初状态，可重置为任意resizeWHScale
 */
- (void)recoveryByResizeWHScale:(CGFloat)resizeWHScale;

/*!
 @method
 @brief 原图尺寸裁剪
 @param complete --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)originImageresizerWithComplete:(void(^)(UIImage *resizeImage))complete;

/*!
 @method
 @brief 压缩尺寸裁剪
 @param complete --- 裁剪完成的回调
 @param scale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：scale = 0.5，1000 x 1000 --> 500 x 500）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete scale:(CGFloat)scale;

@end
