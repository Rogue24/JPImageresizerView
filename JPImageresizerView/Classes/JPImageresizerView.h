//
//  JPImageresizerView.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPImageresizerView : UIView

/*!
 @method
 @brief 实例类方法
 @discussion 部分参数初始使用默认值
 */
+ (JPImageresizerView *)imageresizerViewWithFrame:(CGRect)frame
                                      resizeImage:(UIImage *)resizeImage
                                    resizeWHScale:(CGFloat)resizeWHScale
                        imageresizerIsCanRecovery:(void(^)(BOOL isCanRecovery))imageresizerIsCanRecovery;

/*!
 @method
 @brief 工厂方法
 @param imageresizerIsCanRecovery 是否可以重置的回调
 @discussion 自行配置参数
 */
- (instancetype)initWithFrame:(CGRect)frame
                  resizeImage:(UIImage *)resizeImage
                  strokeColor:(UIColor *)strokeColor
                      bgColor:(UIColor *)bgColor
                    maskAlpha:(CGFloat)maskAlpha
                verBaseMargin:(CGFloat)verBaseMargin
                horBaseMargin:(CGFloat)horBaseMargin
                resizeWHScale:(CGFloat)resizeWHScale
    imageresizerIsCanRecovery:(void(^)(BOOL isCanRecovery))imageresizerIsCanRecovery;

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
/** 裁剪图片的垂直边距 */
@property (nonatomic, assign) CGFloat verBaseMargin;
/** 裁剪图片的水平边距 */
@property (nonatomic, assign) CGFloat horBaseMargin;
/** 是否顺时针旋转（默认逆时针） */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/*!
 @method
 @brief 更新图片、垂直边距和水平边距
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
 @brief 重置
 @discussion 回到最初状态
 */
- (void)recovery;

/*!
 @method
 @brief 裁剪
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete;

@end
