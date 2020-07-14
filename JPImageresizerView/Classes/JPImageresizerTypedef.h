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
 * JPCVEReason_NotAssets：视频资源为空
 * JPCVEReason_VideoAlreadyDamage：视频文件已损坏
 * JPCVEReason_CachePathAlreadyExists：缓存路径已存在其他文件
 * JPCVEReason_ExportFailed：视频导出失败
 * JPCVEReason_ExportCancelled：视频导出取消
 */
typedef NS_ENUM(NSUInteger, JPCropVideoErrorReason) {
    JPCVEReason_NotAssets,
    JPCVEReason_VideoAlreadyDamage,
    JPCVEReason_CachePathAlreadyExists,
    JPCVEReason_ExportFailed,
    JPCVEReason_ExportCancelled
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
 * 图片裁剪完成的回调
    - finalImage：裁剪后的图片
 */
typedef void(^JPCropPictureDoneBlock)(UIImage *finalImage);

/**
 * 视频裁剪错误的回调
    - cachePath：目标存放路径
    - reason：错误原因（JPCropVideoErrorReason）
 * 当缓存路径已存在其他文件（JPCVEReason_CachePathAlreadyExists），返回【YES】方法内部会删除已存在的文件并继续裁剪，返回NO则不再继续裁剪。
 */
typedef BOOL(^JPCropVideoErrorBlock)(NSString *cachePath, JPCropVideoErrorReason reason);

/**
 * 视频裁剪导出的进度
    - progress：进度，单位 0~1
 */
typedef void(^JPCropVideoProgressBlock)(float progress);

/**
 * 视频裁剪完成的回调
    - cacheURL：导出后的最终存放路径，如果转移失败，该路径为tmp文件夹下
 */
typedef void(^JPCropVideoCompleteBlock)(NSURL *cacheURL);

/**
 * 取消视频导出的回调，可用个强指针持有，当视频正在导出时调用即可取消导出，触发errorBlock回调（JPCVEReason_ExportCancelled）
 */
typedef void(^JPVideoExportCancelBlock)(void);
