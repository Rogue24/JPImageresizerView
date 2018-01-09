//
//  JPImageresizerView.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPImageresizerConfigure;

/**
 * 遮罩样式
 * JPNormalMaskType：    通常类型，bgColor能任意设置
 * JPLightBlurMaskType： 明亮高斯模糊，bgColor强制为白色，maskAlpha可自行修改，建议为0.3
 * JPDarkBlurMaskType：  暗黑高斯模糊，bgColor强制为黑色，maskAlpha可自行修改，建议为0.3
 */
typedef NS_ENUM(NSUInteger, JPImageresizerMaskType) {
    JPNormalMaskType, // default
    JPLightBlurMaskType,
    JPDarkBlurMaskType
};

/**
 * 边框样式
 * JPConciseFrameType：简洁样式，可拖拽8个方向（固定比例则4个方向）
 * JPConciseWithoutOtherDotFrameType：简洁样式，可拖拽4个方向（4角）
 * JPClassicFrameType：经典样式，类似微信的裁剪边框样式，可拖拽4个方向
 */
typedef NS_ENUM(NSUInteger, JPImageresizerFrameType) {
    JPConciseFrameType, // default
    JPConciseWithoutOtherDotFrameType,
    JPClassicFrameType
};

/**
 * 动画曲线
 */
typedef NS_ENUM(NSUInteger, JPAnimationCurve) {
    JPAnimationCurveEaseInOut, // default
    JPAnimationCurveEaseIn,
    JPAnimationCurveEaseOut,
    JPAnimationCurveLinear
};

/**
 * 是否可以重置的回调
 * 当裁剪区域缩放至适应范围后就会触发该回调
    - YES：可重置
    - NO：不需要重置，裁剪区域跟图片区域一致，并且没有旋转、镜像过
 */
typedef void(^JPImageresizerIsCanRecoveryBlock)(BOOL isCanRecovery);

/**
 * 是否预备缩放裁剪区域至适应范围
 * 当裁剪区域发生变化的开始和结束就会触发该回调
    - YES：预备缩放，此时裁剪、旋转、镜像功能不可用
    - NO：没有预备缩放
 */
typedef void(^JPImageresizerIsPrepareToScaleBlock)(BOOL isPrepareToScale);

@interface JPImageresizerView : UIView

/**
 * 层级结构
    - JPImageresizerView（self）
        - scrollView
            - imageView（裁剪的imageView）
        - frameView（绘制裁剪边框的view）
 * scrollView与frameView的frame一致
 */

/*!
 @method
 @brief 类方法
 @param configure --- 包含了所有初始化参数
 @discussion 使用JPImageresizerConfigure配置好参数
 */
+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure*)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

/*!
 @method
 @brief 工厂方法
 @param verBaseMargin --- 裁剪图片与裁剪区域的垂直间距
 @param horBaseMargin --- 裁剪图片与裁剪区域的水平间距
 @param contentInsets --- 裁剪区域与主视图的内边距，目前初始化后不可再更改
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

/** 裁剪图片与裁剪区域的垂直边距 */
@property (nonatomic, assign) CGFloat verBaseMargin;

/** 裁剪图片与裁剪区域的水平边距 */
@property (nonatomic, assign) CGFloat horBaseMargin;

/** 是否顺时针旋转（默认逆时针） */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/** 是否锁定裁剪区域（锁定后无法拖动裁剪区域） */
@property (nonatomic) BOOL isLockResizeFrame;

/** 旋转后，是否自动缩放至合适尺寸（默认当图片的宽度比高度小时为YES） */
@property (nonatomic, assign) BOOL isRotatedAutoScale;

/**
 * verticalityMirror：垂直镜像，沿着Y轴旋转180°
 * horizontalMirror：水平镜像，沿着X轴旋转180°
 */
@property (nonatomic, assign) BOOL verticalityMirror;
- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated;
@property (nonatomic, assign) BOOL horizontalMirror;
- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated;

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


@interface JPImageresizerConfigure : NSObject

/**
 * 默认参数值：
 viewFrame = [UIScreen mainScreen].bounds;
 maskAlpha = JPNormalMaskType;
 frameType = JPConciseFrameType;
 animationCurve = JPAnimationCurveLinear;
 strokeColor = [UIColor whiteColor];
 bgColor = [UIColor blackColor];
 maskAlpha = 0.75;
 verBaseMargin = 10.0;
 horBaseMargin = 10.0;
 resizeWHScale = 0.0;
 contentInsets = UIEdgeInsetsZero;
 */
+ (instancetype)defaultConfigureWithResizeImage:(UIImage *)resizeImage make:(void(^)(JPImageresizerConfigure *configure))make;

+ (instancetype)blurMaskTypeConfigureWithResizeImage:(UIImage *)resizeImage isLight:(BOOL)isLight make:(void (^)(JPImageresizerConfigure *configure))make;

@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_resizeImage)(UIImage *resizeImage);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_viewFrame)(CGRect viewFrame);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_maskType)(JPImageresizerMaskType maskType);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_frameType)(JPImageresizerFrameType frameType);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_animationCurve)(JPAnimationCurve animationCurve);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_strokeColor)(UIColor *strokeColor);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_bgColor)(UIColor *bgColor);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_maskAlpha)(CGFloat maskAlpha);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_resizeWHScale)(CGFloat resizeWHScale);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_verBaseMargin)(CGFloat verBaseMargin);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_horBaseMargin)(CGFloat horBaseMargin);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_contentInsets)(UIEdgeInsets contentInsets);
@property (nonatomic, copy, readonly) JPImageresizerConfigure *(^jp_isClockwiseRotation)(BOOL isClockwiseRotation);

@property (nonatomic, strong) UIImage *resizeImage;
@property (nonatomic, assign) CGRect viewFrame;
@property (nonatomic, assign) JPImageresizerMaskType maskType;
@property (nonatomic, assign) JPImageresizerFrameType frameType;
@property (nonatomic, assign) JPAnimationCurve animationCurve;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) CGFloat maskAlpha;
@property (nonatomic, assign) CGFloat resizeWHScale;
@property (nonatomic, assign) CGFloat verBaseMargin;
@property (nonatomic, assign) CGFloat horBaseMargin;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) BOOL isClockwiseRotation;
@end
