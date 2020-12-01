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

#pragma mark - UI控件
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

/**
 * 可配置初始化（configure）：
    image --- 裁剪的图片/GIF（UIImage）
    imageData --- 裁剪的图片/GIF（NSData）
    videoURL --- 裁剪的视频URL
    frame --- 相对父视图的区域
    frameType --- 边框样式
    animationCurve --- 动画曲线
    blurEffect --- 模糊效果
    bgColor --- 背景颜色
    maskAlpha --- 遮罩颜色的透明度（背景颜色 * 透明度）
    strokeColor ---裁剪线颜色
    resizeWHScale --- 裁剪宽高比（设置为0则为任意比例）
    maskImage --- 蒙版图片
    isRoundResize --- 是否初始化圆切
    isArbitrarily --- 是否可以任意比例拖拽
    contentInsets --- 裁剪区域与主视图的内边距（可以通过 -updateFrame:contentInsets:duration: 方法进行修改）
    isClockwiseRotation --- 是否顺时针旋转
    borderImage --- 边框图片（若为nil则使用frameType的边框）
    borderImageRectInset --- 边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距）
    maximumZoomScale --- 最大缩放比例
    isShowMidDots --- 是否显示中间的4个点（上、下、左、右的中点）
    isBlurWhenDragging --- 拖拽时是否遮罩裁剪区域以外的区域
    isShowGridlinesWhenIdle --- 闲置时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格）
    isShowGridlinesWhenDragging --- 拖拽时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格）
    gridCount --- 每行/列的网格数（frameType 为 JPClassicFrameType 且 gridCount > 1 且 maskImage 为 nil 才显示网格）
    isLoopPlaybackGIF --- 是否重复循环GIF播放（NO则有拖动条控制）
    fixErrorBlock --- 修正视频方向的错误回调
    fixStartBlock --- 修正视频方向的开始回调（如果视频不需要修正，该Block和fixProgressBlock、fixErrorBlock均不会调用）
    fixProgressBlock --- 修正视频方向的进度回调
    fixCompleteBlock --- 修正视频方向的完成回调（如果视频不需要修正，会直接调用该Block，返回原路径）
 */

#pragma mark - 工厂
/*!
 @method
 @brief 类工厂
 @param imageresizerIsCanRecovery --- 是否可以重置的回调（当裁剪区域缩放至适应范围后就会触发该回调）
 @param imageresizerIsPrepareToScale --- 是否预备缩放裁剪区域至适应范围（当裁剪区域发生变化的开始和结束就会触发该回调）
 @discussion 可使用JPImageresizerConfigure配置好初始参数创建实例
 */
+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure *)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;
/*!
 @method
 @brief 实例工厂
 @param imageresizerIsCanRecovery --- 是否可以重置的回调（当裁剪区域缩放至适应范围后就会触发该回调）
 @param imageresizerIsPrepareToScale --- 是否预备缩放裁剪区域至适应范围（当裁剪区域发生变化的开始和结束就会触发该回调）
 @discussion 可使用JPImageresizerConfigure配置好初始参数创建实例
 */
- (instancetype)initWithConfigure:(JPImageresizerConfigure *)configure
        imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
     imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

#pragma mark - 裁剪元素相关
/**
 * 裁剪的图片/GIF（UIImage）
 * 设置该值会调用 -setImage: animated: 方法（默认isAnimated = YES，淡入淡出的效果）
 */
@property (nonatomic, strong) UIImage *image;
/*!
 @method
 @brief 更换裁剪的图片/GIF（UIImage）
 @param image --- 裁剪的图片/GIF
 @param isAnimated --- 是否带动画效果（淡入淡出的效果）
 @discussion 更换裁剪的图片，裁剪宽高比会重置
 */
- (void)setImage:(UIImage *)image animated:(BOOL)isAnimated;

/**
 * 裁剪的图片/GIF（NSData）
 * 设置该值会调用 -setImageData: animated: 方法（默认isAnimated = YES，淡入淡出的效果）
 */
@property (nonatomic, strong) NSData *imageData;
/*!
 @method
 @brief 更换裁剪的图片/GIF（NSData）
 @param imageData --- 裁剪的二进制图片/GIF
 @param isAnimated --- 是否带动画效果（淡入淡出的效果）
 @discussion 更换裁剪的图片，裁剪宽高比会重置
 */
- (void)setImageData:(NSData *)imageData animated:(BOOL)isAnimated;

/**
 * 裁剪的视频（NSURL）
 * 设置该值需调用 -setVideoURL: animated: fixErrorBlock: fixStartBlock: fixProgressBlock: fixCompleteBlock: 方法
 */
@property (readonly) NSURL *videoURL;
/*!
 @method
 @brief 更换裁剪的视频
 @param videoURL --- 裁剪的视频（NSURL）
 @param isAnimated --- 是否带动画效果（淡入淡出的效果）
 @param fixErrorBlock  --- 修正视频方向的错误回调
 @param fixStartBlock --- 修正视频方向的开始回调（如果视频不需要修正，该Block和fixProgressBlock、fixErrorBlock均不会调用）
 @param fixProgressBlock --- 修正视频方向的进度回调
 @param fixCompleteBlock --- 修正视频方向的完成回调（如果视频不需要修正，会直接调用该Block，返回原路径）
 @discussion 更换裁剪的视频，裁剪宽高比会重置，如果确定是无需修正方向的视频，fixErrorBlock、fixStartBlock、fixProgressBlock、fixCompleteBlock传nil
 */
- (void)setVideoURL:(NSURL *)videoURL
           animated:(BOOL)isAnimated
      fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
      fixStartBlock:(void(^)(void))fixStartBlock
   fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
   fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;

/**
 * 裁剪的视频（AVURLAsset）
 * 设置该值需调用 -setVideoAsset: animated: fixErrorBlock: fixStartBlock: fixProgressBlock: fixCompleteBlock: 方法
 */
@property (readonly) AVURLAsset *videoAsset;
/*!
 @method
 @brief 更换裁剪的视频
 @param videoAsset --- 裁剪的视频（AVURLAsset）
 @param isAnimated --- 是否带动画效果（淡入淡出的效果）
 @param fixErrorBlock  --- 修正视频方向的错误回调
 @param fixStartBlock --- 修正视频方向的开始回调（如果视频不需要修正，该Block和fixProgressBlock、fixErrorBlock均不会调用）
 @param fixProgressBlock --- 修正视频方向的进度回调
 @param fixCompleteBlock --- 修正视频方向的完成回调（如果视频不需要修正，会直接调用该Block，返回原路径）
 @discussion 更换裁剪的视频，裁剪宽高比会重置，如果确定是无需修正方向的视频，fixErrorBlock、fixStartBlock、fixProgressBlock、fixCompleteBlock传nil
 */
- (void)setVideoAsset:(AVURLAsset *)videoAsset
             animated:(BOOL)isAnimated
        fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
        fixStartBlock:(void(^)(void))fixStartBlock
     fixProgressBlock:(JPExportVideoProgressBlock)fixProgressBlock
     fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;

/** 当前裁剪元素的宽高比 */
@property (nonatomic, assign, readonly) CGFloat resizeObjWhScale;

/** 当前裁剪元素是否为GIF */
@property (nonatomic, assign, readonly) BOOL isGIF;

/** 是否重复循环GIF播放（NO则有拖动条控制） */
@property (nonatomic, assign) BOOL isLoopPlaybackGIF;

#pragma mark - 裁剪宽高比相关
/**
 * 初始裁剪宽高比（默认为初始化时的resizeWHScalem）
 * 调用 -recoveryByInitialResizeWHScale 方法进行重置则 resizeWHScale 会重置为该属性的值
 */
@property (nonatomic) CGFloat initialResizeWHScale;

/**
 * 裁剪宽高比（直接设置：若设置为0，则 self.isArbitrarily = YES，可任意比例拖拽；否则 self.isArbitrarily = NO，固定比例拖拽）
 * 设置该值会调用 -setResizeWHScale: isToBeArbitrarily: animated: 方法（isToBeArbitrarily = (resizeWHScale <= 0)，isAnimated = YES）
 */
@property (nonatomic) CGFloat resizeWHScale;
/*!
 @method
 @brief 设置裁剪宽高比
 @param resizeWHScale --- 目标裁剪宽高比
 @param isToBeArbitrarily --- 设置之后是否为任意比例拖拽（若为YES，最后 resizeWHScale = 0；若为NO，并且 resizeWHScale 设置为0，则最后以裁剪框当前的宽高比固定比例 resizeWHScale = imageresizerWHScale）
 @param isAnimated --- 是否带动画效果
 @discussion 以最合适的尺寸更新裁剪框的尺寸
 */
- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

/**
 * 是否圆切（直接设置：YES --> self.isArbitrarily = NO，固定以 1:1 比例拖拽）
 * 设置该值会调用 -setIsRoundResize: isToBeArbitrarily: animated: 方法（isToBeArbitrarily = (isRoundResize ? NO : self.isArbitrarily)，isAnimated = YES）
 */
@property (nonatomic) BOOL isRoundResize;
/*!
 @method
 @brief 设置是否圆切
 @param isToBeArbitrarily --- 设置之后是否为任意比例拖拽（若为YES，最后 resizeWHScale = 0；若为NO，则 resizeWHScale = 1）
 @param isAnimated --- 是否带动画效果
 @discussion 以圆形裁剪，此状态下边框图片会隐藏，并且宽高比是1:1
 */
- (void)setIsRoundResize:(BOOL)isRoundResize isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

/**
 * 蒙版图片（直接设置：不为空 --> self.isArbitrarily = NO，固定以蒙版图片的宽高比例拖拽）
 * 设置该值会调用 -setMaskImage: isToBeArbitrarily: animated: 方法（isToBeArbitrarily = (maskImage ? NO : self.isArbitrarily)，isAnimated = YES）
 */
@property (nonatomic) UIImage *maskImage;
/*!
 @method
 @brief 设置蒙版图片
 @param isToBeArbitrarily --- 设置之后是否为任意比例拖拽（若为YES，最后 resizeWHScale = 0；若为NO，则 resizeWHScale = maskImage.size.width / maskImage.size.height）
 @param isAnimated --- 是否带动画效果
 @discussion 设置蒙版，此状态下网格线会隐藏，并且宽高比是蒙版图片的宽高比
 */
- (void)setMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

/**
 * 是否可以任意比例拖拽
 * 设置该值会调用 -setIsArbitrarily: animated: 方法（isAnimated = YES）
 */
@property (nonatomic) BOOL isArbitrarily;
/*!
@method
@brief 设置是否可以任意比例拖拽
@param isAnimated --- 是否带动画效果
@discussion 若为NO，以裁剪框当前的宽高比固定比例 resizeWHScale = imageresizerWHScale；如果是 isRoundResize，则 resizeWHScale = 1；如果有 maskImage，则以蒙版图片的宽高比固定比例 resizeWHScale = maskImage.size.width / maskImage.size.height
*/
- (void)setIsArbitrarily:(BOOL)isArbitrarily animated:(BOOL)isAnimated;

/** 裁剪框当前的宽高比 */
@property (readonly) CGFloat imageresizerWHScale;

#pragma mark - 裁剪框样式相关
/** 边框样式 */
@property (nonatomic) JPImageresizerFrameType frameType;

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

/** 是否锁定裁剪区域（锁定后无法拖动裁剪区域） */
@property (nonatomic) BOOL isLockResizeFrame;

/** 裁剪框边线能否进行对边拖拽（当裁剪宽高比为0，即任意比例时才有效，默认为yes） */
@property (nonatomic, assign) BOOL edgeLineIsEnabled;

#pragma mark - 裁剪框、背景、遮罩颜色相关
/**
 * 裁剪线颜色
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) UIColor *strokeColor;
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

#pragma mark - 旋转、镜像翻转相关
/** 是否顺时针旋转（默认逆时针） */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/*!
 @method
 @brief 旋转图片
 @discussion 旋转90度，支持4个方向，分别是垂直向上、水平向左、垂直向下、水平向右
 */
- (void)rotation;

/**
 * 垂直镜像（沿着Y轴旋转180）
 * 设置该值会调用 -setVerticalityMirror: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL verticalityMirror;
/*!
 @method
 @brief 设置是否垂直镜像
 @param verticalityMirror --- 是否垂直镜像
 @param isAnimated --- 是否带动画效果
 @discussion 垂直镜像，沿着Y轴旋转180°
 */
- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated;

/**
 * 水平镜像（沿着X轴旋转180）
 * 设置该值会调用 -setHorizontalMirror: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL horizontalMirror;
/*!
 @method
 @brief 设置是否水平镜像
 @param horizontalMirror --- 是否水平镜像
 @param isAnimated --- 是否带动画效果
 @discussion 水平镜像，沿着X轴旋转180°
 */
- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated;

#pragma mark - 其他
/** 缩放系数zoomScale为最小时的裁剪最大显示区域 */
@property (readonly) CGSize baseContentMaxSize;

/** 动画曲线（默认是线性Linear） */
@property (nonatomic, assign) JPAnimationCurve animationCurve;

#pragma mark 预览
/**
 * 预览模式（隐藏边框，停止拖拽操作，用于预览裁剪后的区域）
 * 设置该值会调用 -setIsPreview: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL isPreview;
/*!
 @method
 @brief 设置是否预览
 @param isPreview --- 是否预览
 @param isAnimated --- 是否带动画效果
 @discussion 隐藏边框，停止拖拽操作，用于预览裁剪后的区域
 */
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated;

#pragma mark 更新视图整体Frame，可作用于横竖屏切换
/*!
 @method
 @brief 更新视图整体Frame
 @param frame --- 刷新的Frame（例如横竖屏切换，传入self.view.bounds即可）
 @param contentInsets --- 裁剪区域与主视图的内边距
 @param duration --- 刷新时长（大于0即带有动画效果）
 @discussion 可用在【横竖屏的切换】
 */
- (void)updateFrame:(CGRect)frame
      contentInsets:(UIEdgeInsets)contentInsets
           duration:(NSTimeInterval)duration;

#pragma mark - 重置
/*!
 @method
 @brief 一切按当前状态重置
 @discussion 回到最初状态
 */
- (void)recovery;

#pragma mark 以resizeWHScale重置（会移除圆切、蒙版）
/*!
 @method
 @brief 按初始裁剪宽高比（initialResizeWHScale）进行重置
 @discussion 回到最初状态，会移除圆切、蒙版
 */
- (void)recoveryByInitialResizeWHScale;
/*!
 @method
 @brief 按初始裁剪宽高比（initialResizeWHScale）进行重置
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，会移除圆切、蒙版，若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale =  initialResizeWHScale，否则为 0
 */
- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily;

/*!
 @method
 @brief 按当前裁剪宽高比进行重置（如果resizeWHScale为0，则重置到整个裁剪元素区域）
 @discussion 回到最初状态，会移除圆切、蒙版，resizeWHScale 不会被重置
 */
- (void)recoveryByCurrentResizeWHScale;
/*!
 @method
 @brief 按当前裁剪宽高比进行重置（如果resizeWHScale为0，则重置到整个裁剪元素区域）
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，会移除圆切、蒙版，若 isToBeArbitrarily 为 YES，则重置之后 resizeWHScale =  0
 */
- (void)recoveryByCurrentResizeWHScale:(BOOL)isToBeArbitrarily;
/*!
 @method
 @brief 按目标裁剪宽高比进行重置（如果resizeWHScale为0，则重置到整个裁剪元素区域）
 @param targetResizeWHScale --- 目标裁剪宽高比
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，会移除圆切、蒙版，若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale  = targetResizeWHScale，否则为 0
 */
- (void)recoveryToTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily;

#pragma mark 以圆切重置
/*!
 @method
 @brief 重置回圆切状态
 @discussion 以圆切状态回到最初状态
 */
- (void)recoveryToRoundResize;
/*!
 @method
 @brief 重置回圆切状态
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0，否则为 1）
 @discussion 以圆切状态回到最初状态
 */
- (void)recoveryToRoundResize:(BOOL)isToBeArbitrarily;

#pragma mark 以蒙版图片重置
/*!
 @method
 @brief 按当前蒙版图片重置
 @discussion 以当前蒙版图片的宽高比作为裁剪宽高比回到最初状态
 */
- (void)recoveryByCurrentMaskImage;
/*!
 @method
 @brief 按当前蒙版图片重置
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0，否则为蒙版图片的宽高比 resizeWHScale = maskImage.size.width / maskImage.size.height）
 @discussion 以当前蒙版图片的宽高比作为裁剪宽高比回到最初状态
 */
- (void)recoveryByCurrentMaskImage:(BOOL)isToBeArbitrarily;
/*!
 @method
 @brief 按指定蒙版图片重置
 @param maskImage --- 指定蒙版图片，为 nil 则以当前 resizeWHScale 重置
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0，否则为蒙版图片的宽高比 resizeWHScale = maskImage.size.width / maskImage.size.height）
 @discussion 重置指定蒙版图片，并以蒙版图片的宽高比作为裁剪宽高比回到最初状态
 */
- (void)recoveryToMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily;

#pragma mark - 获取当前裁剪状态
/*!
 @method
 @brief 获取当前裁剪状态
 @discussion 可用于保存，下次重新打开
 */
- (JPImageresizerConfigure *)saveCurrentConfigure;

#pragma mark - 裁剪

#pragma mark 裁剪图片
/*!
 @method
 @brief 原图尺寸裁剪图片
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropPictureWithCacheURL:(NSURL *)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪图片
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                            cacheURL:(NSURL *)cacheURL
                          errorBlock:(JPImageresizerErrorBlock)errorBlock
                       completeBlock:(JPCropPictureDoneBlock)completeBlock;

#pragma mark 裁剪GIF
/*!
 @method
 @brief 原图尺寸裁剪GIF
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的GIF，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropGIFWithCacheURL:(NSURL *)cacheURL
                 errorBlock:(JPImageresizerErrorBlock)errorBlock
              completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪GIF
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的GIF，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义裁剪GIF
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param isReverseOrder --- 是否倒放
 @param rate --- 速率
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的GIF，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                  isReverseOrder:(BOOL)isReverseOrder
                            rate:(float)rate
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 原图尺寸裁剪GIF当前帧画面
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropGIFCurrentIndexWithCacheURL:(NSURL *)cacheURL
                             errorBlock:(JPImageresizerErrorBlock)errorBlock
                          completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪GIF当前帧画面
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                    cacheURL:(NSURL *)cacheURL
                                  errorBlock:(JPImageresizerErrorBlock)errorBlock
                               completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪GIF指定帧画面
 @param index --- 第几帧画面
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropGIFWithIndex:(NSUInteger)index
           compressScale:(CGFloat)compressScale
                cacheURL:(NSURL *)cacheURL
              errorBlock:(JPImageresizerErrorBlock)errorBlock
           completeBlock:(JPCropPictureDoneBlock)completeBlock;

#pragma mark 裁剪视频
/*!
 @method
 @brief 原图尺寸裁剪视频当前帧画面
 @param cacheURL --- 缓存路径（可设置为nil）
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片、缓存路径、是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoCurrentFrameWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPImageresizerErrorBlock)errorBlock
                            completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪视频当前帧画面
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param cacheURL --- 缓存路径（可设置为nil）
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片、缓存路径、是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                      cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
                                 completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 自定义压缩比例裁剪视频指定帧画面
 @param second --- 第几秒画面
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @param cacheURL --- 缓存路径（可设置为nil）
 @param completeBlock --- 裁剪完成的回调（返回已解码好的图片、缓存路径、是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                           cacheURL:(NSURL *)cacheURL
                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                      completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 视频从当前时间开始截取指定秒数画面转GIF（fps = 10，rate = 1，maximumSize = 500 * 500）
 @param duration --- 截取多少秒
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的GIF、缓存路径、是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoToGIFFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                           cacheURL:(NSURL *)cacheURL
                                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                                      completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 视频自定义截取指定秒数画面转GIF
 @param startSecond --- 从第几秒开始截取
 @param duration --- 截取多少秒
 @param fps --- 帧率（设置为0则以视频真身帧率）
 @param rate --- 速率
 @param maximumSize --- 截取的尺寸（设置为0则以视频真身尺寸）
 @param cacheURL --- 缓存路径（可设置为nil）
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回已解码好的GIF、缓存路径、是否缓存成功）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoToGIFFromStartSecond:(NSTimeInterval)startSecond
                             duration:(NSTimeInterval)duration
                                  fps:(float)fps
                                 rate:(float)rate
                          maximumSize:(CGSize)maximumSize
                             cacheURL:(NSURL *)cacheURL
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
                        completeBlock:(JPCropPictureDoneBlock)completeBlock;

/*!
 @method
 @brief 裁剪整段视频
 @param cacheURL --- 缓存路径，如果为nil则默认为NSTemporaryDirectory文件夹下，视频名为当前时间戳，格式为mp4
 @param progressBlock --- 进度回调
 @param errorBlock --- 错误回调
 @param completeBlock --- 裁剪完成的回调（返回缓存路径）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示，默认使用AVAssetExportPresetHighestQuality的导出质量
 */
- (void)cropVideoWithCacheURL:(NSURL *)cacheURL
                   errorBlock:(JPImageresizerErrorBlock)errorBlock
                progressBlock:(JPExportVideoProgressBlock)progressBlock
                completeBlock:(JPExportVideoCompleteBlock)completeBlock;

/*!
 @method
 @brief 裁剪整段视频
 @param cacheURL --- 缓存路径，如果为nil则默认为NSTemporaryDirectory文件夹下，视频名为当前时间戳，格式为mp4
 @param presetName --- 系统的视频导出质量，如：AVAssetExportPresetLowQuality，AVAssetExportPresetMediumQuality，AVAssetExportPresetHighestQuality等
 @param errorBlock --- 错误回调
 @param progressBlock --- 进度回调
 @param completeBlock --- 裁剪完成的回调（返回缓存路径）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)cropVideoWithPresetName:(NSString *)presetName
                       cacheURL:(NSURL *)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                  progressBlock:(JPExportVideoProgressBlock)progressBlock
                  completeBlock:(JPExportVideoCompleteBlock)completeBlock;

/*!
 @method
 @brief 取消视频导出
 @discussion 当视频正在导出时（裁剪、修正方向）调用即可取消导出，触发errorBlock回调（JPIEReason_ExportCancelled）
 */
- (void)videoCancelExport;

@end
