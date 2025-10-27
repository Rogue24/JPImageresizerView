//
//  JPImageresizerConfigure.h
//  JPImageresizerView
//
//  Created by 周健平 on 2018/4/22.
//
//  用于配置初始化参数
//

#import <UIKit/UIKit.h>
#import "JPImageresizerTypedef.h"
#import "JPImageProcessingSettings.h"
#import "JPImageresizerAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPImageresizerConfigure : NSObject
/* 默认参数值：
    - viewFrame = [UIScreen mainScreen].bounds;
    - frameType = JPConciseFrameType;
    - animationCurve = JPAnimationCurveLinear;
    - mainAppearance
        - strokeColor = UIColor.whiteColor;
        - bgEffect = nil;
        - bgColor = UIColor.blackColor;
        - maskAlpha = 0.75;
    - resizeScaledBounds = CGRectZero;
    - resizeWHScale = 0.0;
    - resizeCornerRadius = 0.0;
    - ignoresCornerRadiusForDisplay = NO;
    - isRoundResize = NO;
    - maskImage = nil;
    - maskAppearance = nil;
    - maskImageDisplayHandler = nil;
    - ignoresMaskImageForCrop = NO;
    - isArbitrarily = YES;
    - contentInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    - borderImage = nil;
    - borderImageRectInset = CGPointZero;
    - maximumZoomScale = 10.0;
    - isShowMidDots = YES;
    - isBlurWhenDragging = NO;
    - isShowGridlinesWhenIdle = NO;
    - isShowGridlinesWhenDragging = YES;
    - gridCount = 3;
    - isLoopPlaybackGIF = NO;
    - gifSettings = nil;
    - isCleanHistoryAfterInitial = YES;
 */

/** 默认配置_空资源 */
+ (instancetype)defaultConfigure;

/** 默认配置_图片/GIF_UIImage */
+ (instancetype)defaultConfigureWithImage:(UIImage *)image make:(JPImageresizerConfigureMakeBlock)make;
/** 默认配置_图片/GIF_NSData */
+ (instancetype)defaultConfigureWithImageData:(NSData *)imageData make:(JPImageresizerConfigureMakeBlock)make;

/** 默认配置_视频_NSURL */
+ (instancetype)defaultConfigureWithVideoURL:(NSURL *)videoURL
                                        make:(JPImageresizerConfigureMakeBlock)make
                               fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                               fixStartBlock:(JPVoidBlock)fixStartBlock
                            fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                            fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;
/** 默认配置_视频_AVURLAsset */
+ (instancetype)defaultConfigureWithVideoAsset:(AVURLAsset *)videoAsset
                                          make:(JPImageresizerConfigureMakeBlock)make
                                 fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                 fixStartBlock:(JPVoidBlock)fixStartBlock
                              fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                              fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;

/** 裁剪的图片/GIF_UIImage */
@property (nonatomic, strong) UIImage *_Nullable image;

/** 裁剪的图片/GIF_NSData */
@property (nonatomic, strong) NSData *_Nullable imageData;

/** 裁剪的视频_NSURL */
@property (nonatomic, strong) NSURL *_Nullable videoURL;

/** 裁剪的视频_AVURLAsset */
@property (nonatomic, strong) AVURLAsset *_Nullable videoAsset;

/** 修正视频方向的错误回调 */
@property (nonatomic, copy) JPImageresizerErrorBlock fixErrorBlock;

/** 修正视频方向的开始回调（如果视频不需要修正，该Block和fixProgressBlock、fixErrorBlock均不会调用） */
@property (nonatomic, copy) void(^_Nullable fixStartBlock)(void);

/** 修正视频方向的进度回调 */
@property (nonatomic, copy) JPExportVideoProgressBlock fixProgressBlock;

/** 修正视频方向的完成回调（如果视频不需要修正，会直接调用该Block，返回原路径） */
@property (nonatomic, copy) JPExportVideoCompleteBlock fixCompleteBlock;

/** 视图区域 */
@property (nonatomic, assign) CGRect viewFrame;

/** 边框样式 */
@property (nonatomic, assign) JPImageresizerFrameType frameType;

/** 动画曲线 */
@property (nonatomic, assign) JPAnimationCurve animationCurve;

/**
 * 主要外观配置
 *  - 包括裁剪边框颜色、模糊效果、背景颜色、遮罩颜色的透明度（背景颜色 * 透明度）
 */
@property (nonatomic, strong) JPImageresizerAppearance *mainAppearance;

/**
 * 初始裁剪区域（只会在初始化时使用一次）
 *  - 该值表示裁剪区域的 x, y, width, height，以【原尺寸的百分比形式】表示，例如 CGRectMake(0.1, 0.1, 0.8, 0.8) 表示裁剪区域为图片的中间 80% 区域
 *  - 该属性和另一个属性 resizeWHScale 互斥，当有值时 imageresizerView.resizeWHScale = resizeScaledBounds.size.width / resizeScaledBounds.size.height
 *  - 只会在初始化时使用一次，因此如果已经使用了该属性，或者后续对 imageresizerView 设置了 resizeWHScale、isRoundResize 、maskImage，resizeScaledBounds 都会被清空。
 */
@property (nonatomic, assign) CGRect resizeScaledBounds;

/** 初始化裁剪宽高比（0 为元素的宽高比，若 isRoundResize 为  YES，或 maskImage 不为空，该属性无效） */
@property (nonatomic, assign) CGFloat resizeWHScale;

/** 初始化裁剪圆角（与 isRoundResize 相互独立，且优先级比 isRoundResize 低；最终裁剪的圆角不会超出「裁剪宽高最小边」的一半） */
@property (nonatomic, assign) CGFloat resizeCornerRadius;

/** 裁剪框的显示是否忽略裁剪圆角（默认为NO） */
@property (nonatomic, assign) BOOL ignoresCornerRadiusForDisplay;

/** 初始化是否圆切（若为 YES 则 resizeWHScale 为 1，若  maskImage 不为空，该属性无效） */
@property (nonatomic, assign) BOOL isRoundResize;

/** 初始化蒙版图片 */
@property (nonatomic, strong) UIImage *_Nullable maskImage;

/**
 * 蒙版外观配置
 *  - 包括模糊效果、背景颜色、遮罩颜色的透明度（背景颜色 * 透明度）
 *  - 需要 maskImage 不为空才能设置，若设置空值则与主要外观配置一致
 */
@property (nonatomic, strong) JPImageresizerAppearance *_Nullable maskAppearance;

/** 自定义蒙版图片的遮罩显示处理（默认为nil；若为 nil 内部会自动生成 alpha 反转的黑色蒙版图片用于遮罩显示） */
@property (nonatomic, copy) JPMaskImageDisplayHandler maskImageDisplayHandler;

/** 裁剪时是否忽略蒙版图片（默认为NO，若为YES裁剪时会忽略蒙版） */
@property (nonatomic, assign) BOOL ignoresMaskImageForCrop;

/** 初始化后是否可以任意比例拖拽 */
@property (nonatomic, assign) BOOL isArbitrarily;

/** 裁剪框边线能否进行对边拖拽（当裁剪宽高比为0，即任意比例时才有效，默认为yes） */
@property (nonatomic, assign) BOOL edgeLineIsEnabled;

/** 裁剪区域与主视图的内边距 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/** 是否顺时针旋转 */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/** 边框图片 */
@property (nonatomic, strong) UIImage *_Nullable borderImage;

/** 边框图片与边线的偏移量 */
@property (nonatomic, assign) CGPoint borderImageRectInset;

/** 最大缩放比例（默认为10.0，小于1.0则无效） */
@property (nonatomic, assign) CGFloat maximumZoomScale;

/** 是否显示中间的4个点（上、下、左、右的中点） */
@property (nonatomic, assign) BOOL isShowMidDots;

/** 拖拽时是否遮罩裁剪区域以外的区域 */
@property (nonatomic, assign) BOOL isBlurWhenDragging;

/** 闲置时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic, assign) BOOL isShowGridlinesWhenIdle;

/** 拖拽时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic, assign) BOOL isShowGridlinesWhenDragging;

/** 每行/列的网格数（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic, assign) NSUInteger gridCount;

/** 是否重复循环GIF播放（NO则有拖动条控制） */
@property (nonatomic, assign) BOOL isLoopPlaybackGIF;

/** GIF图像处理设置（背景色、圆角、边框、轮廓描边、内容边距） */
@property (nonatomic, strong) JPImageProcessingSettings *_Nullable gifSettings;

/** 裁剪历史 */
@property (nonatomic, assign) JPCropHistory history;

/** 是否初始化后清除历史（默认为yes） */
@property (nonatomic, assign) BOOL isCleanHistoryAfterInitial;

/** 是否已经保存了历史 */
@property (readonly) BOOL isSavedHistory;

/** 清除历史 */
- (void)cleanHistory;

@property (readonly) JPImageresizerConfigure *(^jp_viewFrame)(CGRect viewFrame);
@property (readonly) JPImageresizerConfigure *(^jp_frameType)(JPImageresizerFrameType frameType);
@property (readonly) JPImageresizerConfigure *(^jp_animationCurve)(JPAnimationCurve animationCurve);
@property (readonly) JPImageresizerConfigure *(^jp_mainAppearance)(JPAppearanceSettingBlock settingBlock);
@property (readonly) JPImageresizerConfigure *(^jp_resizeScaledBounds)(CGRect resizeScaledBounds);
@property (readonly) JPImageresizerConfigure *(^jp_resizeWHScale)(CGFloat resizeWHScale);
@property (readonly) JPImageresizerConfigure *(^jp_resizeCornerRadius)(CGFloat resizeCornerRadius);
@property (readonly) JPImageresizerConfigure *(^jp_ignoresCornerRadiusForDisplay)(BOOL ignoresCornerRadiusForDisplay);
@property (readonly) JPImageresizerConfigure *(^jp_isRoundResize)(BOOL isRoundResize);
@property (readonly) JPImageresizerConfigure *(^jp_maskImage)(UIImage *_Nullable maskImage);
@property (readonly) JPImageresizerConfigure *(^jp_maskAppearance)(JPImageresizerAppearance *_Nullable maskAppearance);
@property (readonly) JPImageresizerConfigure *(^jp_maskImageDisplayHandler)(JPMaskImageDisplayHandler maskImageDisplayHandler);
@property (readonly) JPImageresizerConfigure *(^jp_ignoresMaskImageForCrop)(BOOL ignoresMaskImageForCrop);
@property (readonly) JPImageresizerConfigure *(^jp_isArbitrarily)(BOOL isArbitrarily);
@property (readonly) JPImageresizerConfigure *(^jp_edgeLineIsEnabled)(BOOL edgeLineIsEnabled);
@property (readonly) JPImageresizerConfigure *(^jp_contentInsets)(UIEdgeInsets contentInsets);
@property (readonly) JPImageresizerConfigure *(^jp_isClockwiseRotation)(BOOL isClockwiseRotation);
@property (readonly) JPImageresizerConfigure *(^jp_borderImage)(UIImage *_Nullable borderImage);
@property (readonly) JPImageresizerConfigure *(^jp_borderImageRectInset)(CGPoint borderImageRectInset);
@property (readonly) JPImageresizerConfigure *(^jp_maximumZoomScale)(CGFloat maximumZoomScale);
@property (readonly) JPImageresizerConfigure *(^jp_isShowMidDots)(BOOL isShowMidDots);
@property (readonly) JPImageresizerConfigure *(^jp_isBlurWhenDragging)(BOOL isBlurWhenDragging);
@property (readonly) JPImageresizerConfigure *(^jp_isShowGridlinesWhenIdle)(BOOL isShowGridlinesWhenIdle);
@property (readonly) JPImageresizerConfigure *(^jp_isShowGridlinesWhenDragging)(BOOL isShowGridlinesWhenDragging);
@property (readonly) JPImageresizerConfigure *(^jp_gridCount)(NSUInteger gridCount);
@property (readonly) JPImageresizerConfigure *(^jp_isLoopPlaybackGIF)(BOOL isLoopPlaybackGIF);
@property (readonly) JPImageresizerConfigure *(^jp_gifSettings)(JPImageProcessingSettings *_Nullable gifSettings);
@property (readonly) JPImageresizerConfigure *(^jp_isCleanHistoryAfterInitial)(BOOL isCleanHistoryAfterInitial);
@end

NS_ASSUME_NONNULL_END
