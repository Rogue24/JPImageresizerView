//
//  JPImageresizerConfigure.h
//  JPImageresizerView
//
//  Created by 周健平 on 2018/4/22.
//
//  用于配置初始化参数

#import <UIKit/UIKit.h>
#import "JPImageresizerTypedef.h"

@interface JPImageresizerConfigure : NSObject
/* 默认参数值：
    - viewFrame = [UIScreen mainScreen].bounds;
    - frameType = JPConciseFrameType;
    - animationCurve = JPAnimationCurveLinear;
    - blurEffect = nil;
    - bgColor = UIColor.blackColor;
    - maskAlpha = 0.75;
    - strokeColor = UIColor.whiteColor;
    - resizeWHScale = 0.0;
    - isRoundResize = NO;
    - isArbitrarily = YES;
    - contentInsets = UIEdgeInsetsZero;
    - borderImage = nil;
    - borderImageRectInset = CGPointZero;
    - maximumZoomScale = 10.0;
    - isShowMidDots = YES;
    - isBlurWhenDragging = NO;
    - isShowGridlinesWhenIdle = NO;
    - isShowGridlinesWhenDragging = YES;
    - gridCount = 3;
    - maskImage = nil;
    - isArbitrarilyMask = NO;
    - isLoopPlaybackGIF = NO;
    - isCleanHistoryAfterInitial = YES;
 */

/**
 * 默认配置裁剪图片/GIF（UIImage）
 */
+ (instancetype)defaultConfigureWithImage:(UIImage *)image make:(void(^)(JPImageresizerConfigure *configure))make;
/**
 * 默认配置裁剪图片/GIF（NSData）
 */
+ (instancetype)defaultConfigureWithImageData:(NSData *)imageData make:(void(^)(JPImageresizerConfigure *configure))make;
/**
 * 默认配置裁剪视频（NSURL）
 */
+ (instancetype)defaultConfigureWithVideoURL:(NSURL *)videoURL
                                        make:(void(^)(JPImageresizerConfigure *configure))make
                               fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                               fixStartBlock:(void(^)(void))fixStartBlock
                            fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                            fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;
/**
 * 默认配置裁剪视频（AVURLAsset）
 */
+ (instancetype)defaultConfigureWithVideoAsset:(AVURLAsset *)videoAsset
                                          make:(void(^)(JPImageresizerConfigure *configure))make
                                 fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                 fixStartBlock:(void(^)(void))fixStartBlock
                              fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                              fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;

/* 默认参数的基础上：
    - blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    - bgColor = UIColor.whiteColor;
    - maskAlpha = 0.3;
    - strokeColor = R: 56, G: 121, B: 242 */
/**
 * 浅色毛玻璃配置裁剪图片/GIF（UIImage）
 */
+ (instancetype)lightBlurMaskTypeConfigureWithImage:(UIImage *)image make:(void (^)(JPImageresizerConfigure *configure))make;
/**
 * 浅色毛玻璃配置裁剪图片/GIF（NSData）
 */
+ (instancetype)lightBlurMaskTypeConfigureWithImageData:(NSData *)imageData make:(void(^)(JPImageresizerConfigure *configure))make;
/**
 * 浅色毛玻璃配置裁剪视频（NSURL）
 */
+ (instancetype)lightBlurMaskTypeConfigureWithVideoURL:(NSURL *)videoURL
                                                  make:(void (^)(JPImageresizerConfigure *configure))make
                                         fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                         fixStartBlock:(void(^)(void))fixStartBlock
                                      fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                      fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;
/**
 * 浅色毛玻璃配置裁剪视频（AVURLAsset）
 */
+ (instancetype)lightBlurMaskTypeConfigureWithVideoAsset:(AVURLAsset *)videoAsset
                                                    make:(void (^)(JPImageresizerConfigure *configure))make
                                           fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                           fixStartBlock:(void(^)(void))fixStartBlock
                                        fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                        fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;

/* 默认参数的基础上：
    - blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    - bgColor = UIColor.blackColor;
    - maskAlpha = 0.3; */
/**
 * 深色毛玻璃配置裁剪图片/GIF（UIImage）
 */
+ (instancetype)darkBlurMaskTypeConfigureWithImage:(UIImage *)image make:(void (^)(JPImageresizerConfigure *configure))make;
/**
 * 深色毛玻璃配置裁剪图片/GIF（NSData）
 */
+ (instancetype)darkBlurMaskTypeConfigureWithImageData:(NSData *)imageData make:(void(^)(JPImageresizerConfigure *configure))make;
/**
 * 深色毛玻璃配置裁剪视频（NSURL）
 */
+ (instancetype)darkBlurMaskTypeConfigureWithVideoURL:(NSURL *)videoURL
                                                 make:(void (^)(JPImageresizerConfigure *configure))make
                                        fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                        fixStartBlock:(void(^)(void))fixStartBlock
                                     fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                     fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;
/**
 * 深色毛玻璃配置裁剪视频（AVURLAsset）
 */
+ (instancetype)darkBlurMaskTypeConfigureWithVideoAsset:(AVURLAsset *)videoAsset
                                                   make:(void (^)(JPImageresizerConfigure *configure))make
                                          fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                                          fixStartBlock:(void(^)(void))fixStartBlock
                                       fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
                                       fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;

/** 裁剪的图片/GIF（UIImage） */
@property (nonatomic, strong) UIImage *image;

/** 裁剪的图片/GIF（NSData） */
@property (nonatomic, strong) NSData *imageData;

/** 裁剪的视频（NSURL） */
@property (nonatomic, strong) NSURL *videoURL;

/** 裁剪的视频（AVURLAsset） */
@property (nonatomic, strong) AVURLAsset *videoAsset;

/** 修正视频方向的错误回调 */
@property (nonatomic, copy) JPImageresizerErrorBlock fixErrorBlock;

/** 修正视频方向的开始回调（如果视频不需要修正，该Block和fixProgressBlock、fixErrorBlock均不会调用） */
@property (nonatomic, copy) void(^fixStartBlock)(void);

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

/** 模糊效果 */
@property (nonatomic, strong) UIBlurEffect *blurEffect;

/** 背景颜色 */
@property (nonatomic, strong) UIColor *bgColor;

/** 遮罩颜色的透明度（背景颜色 * 透明度） */
@property (nonatomic, assign) CGFloat maskAlpha;

/** 裁剪线颜色 */
@property (nonatomic, strong) UIColor *strokeColor;

/** 初始化裁剪宽高比（0 为元素的宽高比，若 isRoundResize 为  YES，或 maskImage 不为空，该属性无效） */
@property (nonatomic, assign) CGFloat resizeWHScale;

/** 初始化是否圆切（若为 YES 则 resizeWHScale 为 1，若  maskImage 不为空，该属性无效） */
@property (nonatomic, assign) BOOL isRoundResize;

/** 初始化蒙版图片 */
@property (nonatomic, strong) UIImage *maskImage;

/** 初始化后是否可以任意比例拖拽 */
@property (nonatomic, assign) BOOL isArbitrarily;

/** 裁剪框边线能否进行对边拖拽（当裁剪宽高比为0，即任意比例时才有效，默认为yes） */
@property (nonatomic, assign) BOOL edgeLineIsEnabled;

/** 裁剪区域与主视图的内边距 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/** 是否顺时针旋转 */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/** 边框图片 */
@property (nonatomic, strong) UIImage *borderImage;

/** 边框图片与边线的偏移量 */
@property (nonatomic, assign) CGPoint borderImageRectInset;

/** 最大缩放比例（默认为10.0，小于1.0则无效） */
@property (nonatomic, assign) CGFloat maximumZoomScale;

/** 是否显示中间的4个点（上、下、左、右的中点） */
@property (nonatomic, assign) BOOL isShowMidDots;

/** 拖拽时是否遮罩裁剪区域以外的区域 */
@property (nonatomic) BOOL isBlurWhenDragging;

/** 闲置时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic) BOOL isShowGridlinesWhenIdle;

/** 拖拽时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic) BOOL isShowGridlinesWhenDragging;

/** 每行/列的网格数（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic, assign) NSUInteger gridCount;

/** 是否重复循环GIF播放（NO则有拖动条控制） */
@property (nonatomic, assign) BOOL isLoopPlaybackGIF;

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
@property (readonly) JPImageresizerConfigure *(^jp_blurEffect)(UIBlurEffect *blurEffect);
@property (readonly) JPImageresizerConfigure *(^jp_bgColor)(UIColor *bgColor);
@property (readonly) JPImageresizerConfigure *(^jp_maskAlpha)(CGFloat maskAlpha);
@property (readonly) JPImageresizerConfigure *(^jp_strokeColor)(UIColor *strokeColor);
@property (readonly) JPImageresizerConfigure *(^jp_resizeWHScale)(CGFloat resizeWHScale);
@property (readonly) JPImageresizerConfigure *(^jp_isRoundResize)(BOOL isRoundResize);
@property (readonly) JPImageresizerConfigure *(^jp_maskImage)(UIImage *maskImage);
@property (readonly) JPImageresizerConfigure *(^jp_isArbitrarily)(BOOL isArbitrarily);
@property (readonly) JPImageresizerConfigure *(^jp_edgeLineIsEnabled)(BOOL edgeLineIsEnabled);
@property (readonly) JPImageresizerConfigure *(^jp_contentInsets)(UIEdgeInsets contentInsets);
@property (readonly) JPImageresizerConfigure *(^jp_isClockwiseRotation)(BOOL isClockwiseRotation);
@property (readonly) JPImageresizerConfigure *(^jp_borderImage)(UIImage *borderImage);
@property (readonly) JPImageresizerConfigure *(^jp_borderImageRectInset)(CGPoint borderImageRectInset);
@property (readonly) JPImageresizerConfigure *(^jp_maximumZoomScale)(CGFloat maximumZoomScale);
@property (readonly) JPImageresizerConfigure *(^jp_isShowMidDots)(BOOL isShowMidDots);
@property (readonly) JPImageresizerConfigure *(^jp_isBlurWhenDragging)(BOOL isBlurWhenDragging);
@property (readonly) JPImageresizerConfigure *(^jp_isShowGridlinesWhenIdle)(BOOL isShowGridlinesWhenIdle);
@property (readonly) JPImageresizerConfigure *(^jp_isShowGridlinesWhenDragging)(BOOL isShowGridlinesWhenDragging);
@property (readonly) JPImageresizerConfigure *(^jp_gridCount)(NSUInteger gridCount);
@property (readonly) JPImageresizerConfigure *(^jp_isLoopPlaybackGIF)(BOOL isLoopPlaybackGIF);
@property (readonly) JPImageresizerConfigure *(^jp_isCleanHistoryAfterInitial)(BOOL isCleanHistoryAfterInitial);
@end
