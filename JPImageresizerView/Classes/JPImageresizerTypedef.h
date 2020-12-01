//
//  JPImageresizerTypedef.h
//  JPImageresizerView
//
//  Created by 周健平 on 2018/4/22.
//
//  公共类型定义

#import <AVFoundation/AVFoundation.h>

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
 * JPIEReason_NilObject：裁剪元素为空
 * JPIEReason_CacheURLAlreadyExists：缓存路径已存在其他文件
 * JPIEReason_NoSupportedFileType：不支持的文件类型
 * JPIEReason_VideoAlreadyDamage：视频文件已损坏
 * JPIEReason_VideoExportFailed：视频导出失败
 * JPIEReason_VideoExportCancelled：视频导出取消
 */
typedef NS_ENUM(NSUInteger, JPImageresizerErrorReason) {
    JPIEReason_NilObject,
    JPIEReason_CacheURLAlreadyExists,
    JPIEReason_NoSupportedFileType,
    JPIEReason_VideoAlreadyDamage,
    JPIEReason_VideoExportFailed,
    JPIEReason_VideoExportCancelled
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
 * 错误的回调
    - cacheURL：目标存放路径
    - reason：错误原因（JPImageresizerErrorReason）
 */
typedef void(^JPImageresizerErrorBlock)(NSURL *cacheURL, JPImageresizerErrorReason reason);

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
typedef void(^JPExportVideoProgressBlock)(float progress);

/**
 * 视频导出开始的回调
    - exportSession：导出会话，可用于取消
 */
typedef void(^JPExportVideoStartBlock)(AVAssetExportSession *exportSession);

/**
 * 视频导出完成的回调
    - cacheURL：修正方向/裁剪后的视频导出后的最终存放路径，默认该路径为NSTemporaryDirectory文件夹下
        - 如果是修正方向的视频，是无需修正的视频，cacheURL则以原路径返回
        - 如果是裁剪的视频，裁剪后自定义的路径转移失败，cacheURL返回的是也是在NSTemporaryDirectory里
 */
typedef void(^JPExportVideoCompleteBlock)(NSURL *cacheURL);

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

#pragma mark - 额外用于保存的属性

struct JPCropHistory {
    CGRect viewFrame;
    UIEdgeInsets contentInsets;
    JPImageresizerRotationDirection direction;
    CATransform3D contentViewTransform;
    CATransform3D containerViewTransform;
    CGRect imageresizerFrame;
    BOOL isVerMirror;
    BOOL isHorMirror;
    UIEdgeInsets scrollViewContentInsets;
    CGPoint scrollViewContentOffset;
    CGFloat scrollViewMinimumZoomScale;
    CGFloat scrollViewCurrentZoomScale;
};
typedef struct CG_BOXABLE JPCropHistory JPCropHistory;

CG_INLINE JPCropHistory JPCropHistoryMake(CGRect viewFrame,
                                          UIEdgeInsets contentInsets,
                                          JPImageresizerRotationDirection direction,
                                          CATransform3D contentViewTransform,
                                          CATransform3D containerViewTransform,
                                          CGRect imageresizerFrame,
                                          BOOL isVerMirror,
                                          BOOL isHorMirror,
                                          UIEdgeInsets scrollViewContentInsets,
                                          CGPoint scrollViewContentOffset,
                                          CGFloat scrollViewMinimumZoomScale,
                                          CGFloat scrollViewCurrentZoomScale) {
    JPCropHistory history;
    history.viewFrame = viewFrame;
    history.contentInsets = contentInsets;
    history.direction = direction;
    history.contentViewTransform = contentViewTransform;
    history.containerViewTransform = containerViewTransform;
    history.imageresizerFrame = imageresizerFrame;
    history.isVerMirror = isVerMirror;
    history.isHorMirror = isHorMirror;
    history.scrollViewContentInsets = scrollViewContentInsets;
    history.scrollViewContentOffset = scrollViewContentOffset;
    history.scrollViewMinimumZoomScale = scrollViewMinimumZoomScale;
    history.scrollViewCurrentZoomScale = scrollViewCurrentZoomScale;
    return history;
}

CG_INLINE BOOL JPCropHistoryIsNull(JPCropHistory history) {
    return CGRectIsNull(history.viewFrame) || CGRectIsEmpty(history.viewFrame);
}
