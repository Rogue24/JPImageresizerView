//
//  JPImageresizerView.h
//  JPImageresizerView
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
        - containerView（容器view）
            - scrollView
                - imageView（裁剪的imageView）
                    - playerView（裁剪的视频画面）
            - frameView（绘制裁剪边框的view）
        - slider（视频进度条）
 * scrollView与frameView的frame一致
 */
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) JPImageresizerFrameView *frameView;

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
 @param resizeImage --- 裁剪图片
 @param videoURL --- 裁剪的视频URL
 @param frame --- 相对父视图的区域
 @param frameType --- 边框样式
 @param animationCurve --- 动画曲线
 @param blurEffect --- 模糊效果
 @param bgColor --- 背景颜色
 @param maskAlpha --- 遮罩颜色的透明度（背景颜色 * 透明度）
 @param strokeColor ---裁剪线颜色
 @param resizeWHScale --- 裁剪宽高比
 @param isArbitrarilyInitial --- 初始化后裁剪宽高比是否可以任意改变（resizeWHScale 为 0 则为任意比例，该值则为 YES）
 @param contentInsets --- 裁剪区域与主视图的内边距（可以通过 -updateFrame:contentInsets:duration: 方法进行修改）
 @param isClockwiseRotation --- 是否顺时针旋转
 @param borderImage --- 边框图片（若为nil则使用frameType的边框）
 @param borderImageRectInset --- 边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距）
 @param maximumZoomScale --- 最大缩放比例
 @param isRoundResize --- 是否初始化圆切（若为YES则resizeWHScale为1）
 @param isShowMidDots --- 是否显示中间的4个点（上、下、左、右的中点）
 @param isBlurWhenDragging --- 拖拽时是否遮罩裁剪区域以外的区域
 @param isShowGridlinesWhenIdle --- 闲置时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格）
 @param isShowGridlinesWhenDragging --- 拖拽时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格）
 @param gridCount --- 每行/列的网格数（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格）
 @param maskImage --- 蒙版图片
 @param isArbitrarilyMask --- 蒙版图片是否可以以任意比例进行拖拽形变
 @param imageresizerIsCanRecovery --- 是否可以重置的回调（当裁剪区域缩放至适应范围后就会触发该回调）
 @param imageresizerIsPrepareToScale --- 是否预备缩放裁剪区域至适应范围（当裁剪区域发生变化的开始和结束就会触发该回调）
 @discussion 自行配置参数
 */
- (instancetype)initWithResizeImage:(UIImage *)resizeImage
                           videoURL:(NSURL *)videoURL
                              frame:(CGRect)frame
                          frameType:(JPImageresizerFrameType)frameType
                     animationCurve:(JPAnimationCurve)animationCurve
                         blurEffect:(UIBlurEffect *)blurEffect
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha
                        strokeColor:(UIColor *)strokeColor
                      resizeWHScale:(CGFloat)resizeWHScale
               isArbitrarilyInitial:(BOOL)isArbitrarilyInitial
                      contentInsets:(UIEdgeInsets)contentInsets
                isClockwiseRotation:(BOOL)isClockwiseRotation
                        borderImage:(UIImage *)borderImage
               borderImageRectInset:(CGPoint)borderImageRectInset
                   maximumZoomScale:(CGFloat)maximumZoomScale
                      isRoundResize:(BOOL)isRoundResize
                      isShowMidDots:(BOOL)isShowMidDots
                 isBlurWhenDragging:(BOOL)isBlurWhenDragging
            isShowGridlinesWhenIdle:(BOOL)isShowGridlinesWhenIdle
        isShowGridlinesWhenDragging:(BOOL)isShowGridlinesWhenDragging
                          gridCount:(NSUInteger)gridCount
                          maskImage:(UIImage *)maskImage
                  isArbitrarilyMask:(BOOL)isArbitrarilyMask
          imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
       imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

/** 边框样式 */
@property (nonatomic) JPImageresizerFrameType frameType;

/** 动画曲线（默认是线性Linear） */
@property (nonatomic, assign) JPAnimationCurve animationCurve;

/** 缩放系数zoomScale为最小时的裁剪最大显示区域 */
@property (readonly) CGSize baseContentMaxSize;

/**
 * 裁剪的图片
 * 设置该值会调用 -setResizeImage: animated: transition: 方法（isAnimated = YES，transition = UIViewAnimationTransitionCurlUp）
 */
@property (nonatomic) UIImage *resizeImage;

/**
 * 裁剪的视频URL
 * 设置该值会调用 -setVideoURL: animated: transition: 方法（isAnimated = YES，transition = UIViewAnimationTransitionNone，淡入淡出的效果）
 */
@property (nonatomic) NSURL *videoURL;

/**
 * 模糊效果
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) UIBlurEffect *blurEffect;

/**
 * 背景颜色
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) UIColor *bgColor;

/**
 * 遮罩颜色的透明度（背景颜色 * 透明度）
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) CGFloat maskAlpha;

/**
 * 裁剪线颜色
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) UIColor *strokeColor;

/**
 * 裁剪宽高比（0则为任意比例）
 * 设置该值会调用 -setResizeWHScale: isToBeArbitrarily: animated: 方法（isToBeArbitrarily = NO，isAnimated = YES）
 */
@property (nonatomic) CGFloat resizeWHScale;

/**
 * 初始裁剪宽高比（默认为初始化时的resizeWHScalem）
 * 调用 -recoveryByInitialResizeWHScale 方法进行重置则 resizeWHScale 会重置为该属性的值
 */
@property (nonatomic) CGFloat initialResizeWHScale;

/** 裁剪框当前的宽高比 */
@property (readonly) CGFloat imageresizeWHScale;

/** 裁剪框边线能否进行对边拖拽（当裁剪宽高比为0，即任意比例时才有效，默认为yes） */
@property (nonatomic, assign) BOOL edgeLineIsEnabled;

/** 是否顺时针旋转（默认逆时针） */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/** 是否锁定裁剪区域（锁定后无法拖动裁剪区域） */
@property (nonatomic) BOOL isLockResizeFrame;

/**
 * 垂直镜像（沿着Y轴旋转180）
 * 设置该值会调用 -setVerticalityMirror: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL verticalityMirror;

/**
 * 水平镜像（沿着X轴旋转180）
 * 设置该值会调用 -setHorizontalMirror: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL horizontalMirror;

/**
 * 预览模式（隐藏边框，停止拖拽操作，用于预览裁剪后的区域）
 * 设置该值会调用 -setIsPreview: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL isPreview;

/** 边框图片（若为nil则使用frameType的边框） */
@property (nonatomic) UIImage *borderImage;

/** 边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距） */
@property (nonatomic) CGPoint borderImageRectInset;

/** 是否显示中间的4个点（上、下、左、右的中点） */
@property (nonatomic) BOOL isShowMidDots;

/** 拖拽时是否遮罩裁剪区域以外的区域 */
@property (nonatomic) BOOL isBlurWhenDragging;

/** 闲置时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic) BOOL isShowGridlinesWhenIdle;

/** 拖拽时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic) BOOL isShowGridlinesWhenDragging;

/** 每行/列的网格数（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格） */
@property (nonatomic, assign) NSUInteger gridCount;

/** 蒙版图片 */
@property (nonatomic) UIImage *maskImage;

/** 蒙版图片是否可以拖拽形变 */
@property (nonatomic) BOOL isArbitrarilyMask;

/*!
 @method
 @brief 更换裁剪的图片
 @param resizeImage --- 裁剪的图片
 @param transition --- 切换效果（isAnimated为YES才生效，若为UIViewAnimationTransitionNone则由淡入淡出效果代替）
 @param isAnimated --- 是否带动画效果
 @discussion 更换裁剪的图片，裁剪宽高比会重置
 */
- (void)setResizeImage:(UIImage *)resizeImage animated:(BOOL)isAnimated transition:(UIViewAnimationTransition)transition;

/*!
 @method
 @brief 更换裁剪的视频模型
 @param videoURL --- 裁剪的视频URL
 @param transition --- 切换效果（isAnimated为YES才生效，若为UIViewAnimationTransitionNone则由淡入淡出效果代替）
 @param isAnimated --- 是否带动画效果
 @discussion 更换裁剪的视频，裁剪宽高比会重置
 */
- (void)setVideoURL:(NSURL *)videoURL animated:(BOOL)isAnimated transition:(UIViewAnimationTransition)transition;

/*!
 @method
 @brief 设置颜色
 @param strokeColor --- 裁剪线颜色
 @param blurEffect --- 模糊效果
 @param bgColor --- 背景颜色
 @param maskAlpha --- 遮罩颜色的透明度（背景颜色 * 透明度）
 @param isAnimated --- 是否带动画效果
 @discussion 同时修改UI元素
 */
- (void)setupStrokeColor:(UIColor *)strokeColor
              blurEffect:(UIBlurEffect *)blurEffect
                 bgColor:(UIColor *)bgColor
               maskAlpha:(CGFloat)maskAlpha
                animated:(BOOL)isAnimated;

/*!
 @method
 @brief 设置裁剪宽高比
 @param resizeWHScale --- 目标裁剪宽高比
 @param isToBeArbitrarily --- 设置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @param isAnimated --- 是否带动画效果
 @discussion 以最合适的尺寸更新裁剪框的尺寸（0则为任意比例）
 */
- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

/*!
 @method
 @brief 圆切
 @param isAnimated --- 是否带动画效果
 @discussion 以圆形裁剪，此状态下边框图片会隐藏，并且宽高比是1:1，恢复矩形则重设resizeWHScale
 */
- (void)roundResize:(BOOL)isAnimated;

/*!
 @method
 @brief 是否正在圆切
 @return YES：圆切，NO：矩形
 */
- (BOOL)isRoundResizing;

/*!
 @method
 @brief 设置是否垂直镜像
 @param verticalityMirror --- 是否垂直镜像
 @param isAnimated --- 是否带动画效果
 @discussion 垂直镜像，沿着Y轴旋转180°
 */
- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated;

/*!
 @method
 @brief 设置是否水平镜像
 @param horizontalMirror --- 是否水平镜像
 @param isAnimated --- 是否带动画效果
 @discussion 水平镜像，沿着X轴旋转180°
 */
- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated;

/*!
 @method
 @brief 设置是否预览
 @param isPreview --- 是否预览
 @param isAnimated --- 是否带动画效果
 @discussion 隐藏边框，停止拖拽操作，用于预览裁剪后的区域
 */
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated;

/*!
 @method
 @brief 更新图片
 @discussion 同步更新
 */
- (void)updateResizeImage:(UIImage *)resizeImage;

/*!
 @method
 @brief 旋转图片
 @discussion 旋转90度，支持4个方向，分别是垂直向上、水平向左、垂直向下、水平向右
 */
- (void)rotation;

/*!
 @method
 @brief 重置回圆切状态
 @discussion 以圆切状态回到最初状态
 */
- (void)recoveryToRoundResize;

/*!
 @method
 @brief 按当前蒙版图片重置
 @discussion 以当前蒙版图片的宽高比作为裁剪宽高比回到最初状态
 */
- (void)recoveryByCurrentMaskImage;

/*!
 @method
 @brief 按指定蒙版图片重置
 @discussion 重置指定蒙版图片，并以蒙版图片的宽高比作为裁剪宽高比回到最初状态
 */
- (void)recoveryToMaskImage:(UIImage *)maskImage;

/*!
 @method
 @brief 按当前裁剪宽高比（resizeWHScale）进行重置
 @discussion 回到最初状态，resizeWHScale 不会被重置
 */
- (void)recoveryByCurrentResizeWHScale;

/*!
 @method
 @brief 按当前裁剪宽高比（resizeWHScale）进行重置
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，若 isToBeArbitrarily 为 YES，则重置之后 resizeWHScale =  0
 */
- (void)recoveryByCurrentResizeWHScale:(BOOL)isToBeArbitrarily;

/*!
 @method
 @brief 按初始裁剪宽高比（initialResizeWHScale）进行重置
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale =  initialResizeWHScale
 */
- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily;

/*!
 @method
 @brief 按目标裁剪宽高比进行重置
 @param targetResizeWHScale --- 目标裁剪宽高比
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale  = targetResizeWHScale
 */
- (void)recoveryToTargetResizeWHScale:(CGFloat)targetResizeWHScale
                    isToBeArbitrarily:(BOOL)isToBeArbitrarily;

/*!
 @method
 @brief 修改视图整体Frame
 @param frame --- 刷新的Frame（例如横竖屏切换，传入self.view.bounds即可）
 @param contentInsets --- 裁剪区域与主视图的内边距
 @param duration --- 刷新时长（大于0即带有动画效果）
 @discussion 可用在【横竖屏的切换】
 */
- (void)updateFrame:(CGRect)frame
      contentInsets:(UIEdgeInsets)contentInsets
           duration:(NSTimeInterval)duration;

/*!
 @method
 @brief 原图尺寸裁剪图片
 @param completeBlock --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropPictureWithCompleteBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪图片
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param completeBlock --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                       completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 原图尺寸裁剪视频当前帧画面
 @param completeBlock --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoCurrentFrameWithCompleteBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪视频当前帧画面
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param completeBlock --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                 completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪视频指定帧画面
 @param second --- 第几秒画面
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param completeBlock --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                      completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 裁剪整段视频
 @param cachePath --- 缓存路径，如果为nil则默认为Caches文件夹下，视频名为当前时间戳，格式为mp4
 @param progressBlock --- 进度回调
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示，默认使用AVAssetExportPresetHighestQuality的导出质量
 */
- (void)cropVideoWithCachePath:(NSString *)cachePath
                 progressBlock:(JPCropVideoProgressBlock)progressBlock
                    errorBlock:(JPCropVideoErrorBlock)errorBlock
                 completeBlock:(JPCropVideoCompleteBlock)completeBlock;

/*!
 @method
 @brief 裁剪整段视频
 @param cachePath --- 缓存路径，如果为nil则默认为Caches文件夹下，视频名为当前时间戳，格式为mp4
 @param presetName --- 系统的视频导出质量，如：AVAssetExportPresetLowQuality，AVAssetExportPresetMediumQuality，AVAssetExportPresetHighestQuality等
 @param progressBlock --- 进度回调
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoWithCachePath:(NSString *)cachePath
                    presetName:(NSString *)presetName
                 progressBlock:(JPCropVideoProgressBlock)progressBlock
                    errorBlock:(JPCropVideoErrorBlock)errorBlock
                 completeBlock:(JPCropVideoCompleteBlock)completeBlock;

/*!
 @method
 @brief 取消视频导出
 @discussion 当视频正在导出时调用即可取消导出，触发errorBlock回调（JPCVEReason_ExportCancelled）
 */
- (void)videoCancelExport;

@end
