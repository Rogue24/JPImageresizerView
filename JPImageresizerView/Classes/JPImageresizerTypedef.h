//
//  JPImageresizerTypedef.h
//  JPImageresizerView
//
//  Created by 周健平 on 2018/4/22.
//
//  公共类型定义

#pragma mark - 枚举

/**
 * 边框样式
 * JPConciseFrameType：简洁样式
 * JPClassicFrameType：经典样式，类似微信的裁剪边框样式
 */
typedef NS_ENUM(NSUInteger, JPImageresizerFrameType) {
    JPConciseFrameType, // default
    JPClassicFrameType
};

/**
 * 动画曲线
 * JPAnimationCurveEaseInOut：慢进慢出，中间快
 * JPAnimationCurveEaseIn：由慢到快
 * JPAnimationCurveEaseOut：由快到慢
 * JPAnimationCurveLinear：匀速
 */
typedef NS_ENUM(NSUInteger, JPAnimationCurve) {
    JPAnimationCurveEaseInOut, // default
    JPAnimationCurveEaseIn,
    JPAnimationCurveEaseOut,
    JPAnimationCurveLinear
};

/**
 * 当前方向
 * JPImageresizerVerticalUpDirection：垂直向上
 * JPImageresizerHorizontalLeftDirection：水平向左
 * JPImageresizerVerticalDownDirection：垂直向下
 * JPImageresizerHorizontalRightDirection：水平向右
 */
typedef NS_ENUM(NSUInteger, JPImageresizerRotationDirection) {
    JPImageresizerVerticalUpDirection = 0,  // default
    JPImageresizerHorizontalLeftDirection,
    JPImageresizerVerticalDownDirection,
    JPImageresizerHorizontalRightDirection
};

/**
 * 裁剪视频错误原因
 * JPCEReason_NilObject：裁剪元素为空
 * JPCEReason_CacheURLAlreadyExists：缓存路径已存在其他文件
 * JPCEReason_NoSupportedFileType：不支持的文件类型
 * JPCEReason_VideoAlreadyDamage：视频文件已损坏
 * JPCEReason_VideoExportFailed：视频导出失败
 * JPCEReason_VideoExportCancelled：视频导出取消
 */
typedef NS_ENUM(NSUInteger, JPCropErrorReason) {
    JPCEReason_NilObject,
    JPCEReason_CacheURLAlreadyExists,
    JPCEReason_NoSupportedFileType,
    JPCEReason_VideoAlreadyDamage,
    JPCEReason_VideoExportFailed,
    JPCEReason_VideoExportCancelled
};

#pragma mark - Block

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

/**
 * 视频裁剪错误的回调
    - cacheURL：目标存放路径
    - reason：错误原因（JPCropErrorReason）
 */
typedef void(^JPCropErrorBlock)(NSURL *cacheURL, JPCropErrorReason reason);

/**
 * 图片裁剪完成的回调
    - finalImage：裁剪后的图片/GIF
    - cacheURL：目标存放路径
    - isCacheSuccess：是否缓存成功（缓存不成功则cacheURL为nil）
 */
typedef void(^JPCropPictureDoneBlock)(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess);

/**
 * 视频裁剪导出的进度
    - progress：进度，单位 0~1
 */
typedef void(^JPVideoExportProgressBlock)(float progress);

/**
 * 视频修正方向导出完成的回调
    - videoURL：修正过方向的视频导出后的URL，该路径为NSTemporaryDirectory文件夹下，为nil则导出失败或取消
    - isCanceled：是否取消导出
 */
typedef void(^JPVideoFixOrientationCompleteBlock)(NSURL *videoURL, BOOL isCanceled);

/**
 * 视频裁剪完成的回调
    - cacheURL：导出后的最终存放路径，如果转移失败，该路径为NSTemporaryDirectory文件夹下
 */
typedef void(^JPCropVideoCompleteBlock)(NSURL *cacheURL);

#pragma mark - 裁剪属性

struct JPCropConfigure {
    JPImageresizerRotationDirection direction;
    BOOL isVerMirror;
    BOOL isHorMirror;
    BOOL isRoundClip;
    CGSize resizeContentSize;
    CGFloat resizeWHScale;
    CGRect cropFrame;
};
typedef struct CG_BOXABLE JPCropConfigure JPCropConfigure;

CG_INLINE JPCropConfigure JPCropConfigureMake(JPImageresizerRotationDirection direction,
                                              BOOL isVerMirror,
                                              BOOL isHorMirror,
                                              BOOL isRoundClip,
                                              CGSize resizeContentSize,
                                              CGFloat resizeWHScale,
                                              CGRect cropFrame) {
    JPCropConfigure configure;
    configure.direction = direction;
    configure.isVerMirror = isVerMirror;
    configure.isHorMirror = isHorMirror;
    configure.isRoundClip = isRoundClip;
    configure.resizeContentSize = resizeContentSize;
    configure.resizeWHScale = resizeWHScale;
    configure.cropFrame = cropFrame;
    return configure;
}
