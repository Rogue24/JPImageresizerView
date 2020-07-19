//
//  JPImageresizerTool.h
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/13.
//

#import <AVFoundation/AVFoundation.h>
#import "JPImageresizerTypedef.h"

@interface JPImageresizerTool : NSObject

/**
 * 转换成黑色轮廓的图片
 */
+ (UIImage *)convertBlackImage:(UIImage *)image;

/**
 * 是否GIF
 */
+ (BOOL)isGIFData:(NSData *)data;

/**
 * 获取图片类型后缀
 */
+ (NSString *)contentTypeForImageData:(NSData *)data;

/**
 * 解码GIF
 */
+ (UIImage *)decodeGIFData:(NSData *)data;

#pragma mark - 裁剪图片
/**
 * 裁剪图片（UIImage）
 */
+ (void)cropPictureWithImage:(UIImage *)image
                   maskImage:(UIImage *)maskImage
                   configure:(JPCropConfigure)configure
               compressScale:(CGFloat)compressScale
                    cacheURL:(NSURL *)cacheURL
                  errorBlock:(JPCropErrorBlock)errorBlock
               completeBlock:(JPCropPictureDoneBlock)completeBlock;

/**
 * 裁剪图片（NSData）
 */
+ (void)cropPictureWithImageData:(NSData *)imageData
                       maskImage:(UIImage *)maskImage
                       configure:(JPCropConfigure)configure
                   compressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPCropErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;

#pragma mark - 裁剪GIF
/**
 * 裁剪GIF（UIImage）
 */
+ (void)cropGIFwithGifImage:(UIImage *)gifImage
             isReverseOrder:(BOOL)isReverseOrder
                       rate:(float)rate
                  maskImage:(UIImage *)maskImage
                  configure:(JPCropConfigure)configure
              compressScale:(CGFloat)compressScale
                   cacheURL:(NSURL *)cacheURL
                 errorBlock:(JPCropErrorBlock)errorBlock
              completeBlock:(JPCropPictureDoneBlock)completeBlock;

/**
 * 裁剪GIF其中一帧（UIImage）
 */
+ (void)cropGIFwithGifImage:(UIImage *)gifImage
                      index:(NSInteger)index
                  maskImage:(UIImage *)maskImage
                  configure:(JPCropConfigure)configure
              compressScale:(CGFloat)compressScale
                   cacheURL:(NSURL *)cacheURL
                 errorBlock:(JPCropErrorBlock)errorBlock
              completeBlock:(JPCropPictureDoneBlock)completeBlock;

/**
 * 裁剪GIF（NSData）
 */
+ (void)cropGIFwithGifData:(NSData *)gifData
            isReverseOrder:(BOOL)isReverseOrder
                      rate:(float)rate
                 maskImage:(UIImage *)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPCropErrorBlock)errorBlock
             completeBlock:(JPCropPictureDoneBlock)completeBlock;

/**
 * 裁剪GIF其中一帧（NSData）
 */
+ (void)cropGIFwithGifData:(NSData *)gifData
                     index:(NSInteger)index
                 maskImage:(UIImage *)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPCropErrorBlock)errorBlock
             completeBlock:(JPCropPictureDoneBlock)completeBlock;


#pragma mark - 裁剪视频
/**
 * 裁剪视频其中一帧
 */
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                      time:(CMTime)time
               maximumSize:(CGSize)maximumSize
                 maskImage:(UIImage *)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPCropErrorBlock)errorBlock
             completeBlock:(JPCropPictureDoneBlock)completeBlock;

/**
 * 截取视频一小段并裁剪成GIF
 */
+ (void)cropVideoToGIFwithAsset:(AVURLAsset *)asset
                    startSecond:(NSTimeInterval)startSecond
                       duration:(NSTimeInterval)duration
                            fps:(float)fps
                           rate:(float)rate
                    maximumSize:(CGSize)maximumSize
                      maskImage:(UIImage *)maskImage
                      configure:(JPCropConfigure)configure
                       cacheURL:(NSURL *)cacheURL
                     errorBlock:(JPCropErrorBlock)errorBlock
                  completeBlock:(JPCropPictureDoneBlock)completeBlock;

/**
 * 裁剪视频
 */
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                 timeRange:(CMTimeRange)timeRange
             frameDuration:(CMTime)frameDuration
                presetName:(NSString *)presetName
                 configure:(JPCropConfigure)configure
                  cacheURL:(NSURL *)cacheURL
        exportSessionBlock:(void(^)(AVAssetExportSession *exportSession))exportSessionBlock
                errorBlock:(JPCropErrorBlock)errorBlock
             completeBlock:(JPCropVideoCompleteBlock)completeBlock;
@end
