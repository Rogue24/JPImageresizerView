//
//  JPImageresizerTool.h
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/13.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerTypedef.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPImageresizerTool : NSObject
/**
 * 转换成黑色轮廓的图片
 */
+ (UIImage *)convertBlackImage:(UIImage *)image;

/**
 * 解码GIF【该方法采用的是 YYKit 的代码（膜拜大神）】
 */
+ (UIImage *_Nullable)decodeGIFData:(NSData *)data;

/**
 * 是否GIF
 */
+ (BOOL)isGIFData:(NSData *)data;

#pragma mark - 裁剪图片
/**
 * 裁剪图片（UIImage）
 */
+ (void)cropPictureWithImage:(UIImage *)image
                   maskImage:(UIImage *_Nullable)maskImage
                   configure:(JPCropConfigure)configure
               compressScale:(CGFloat)compressScale
                    cacheURL:(NSURL *_Nullable)cacheURL
                  errorBlock:(JPImageresizerErrorBlock)errorBlock
               completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 裁剪图片（NSData）
 */
+ (void)cropPictureWithImageData:(NSData *)imageData
                       maskImage:(UIImage *_Nullable)maskImage
                       configure:(JPCropConfigure)configure
                   compressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *_Nullable)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 裁剪N宫格图片（UIImage）
 */
+ (void)cropGirdPicturesWithImage:(UIImage *)image
                      columnCount:(NSInteger)columnCount
                         rowCount:(NSInteger)rowCount
                          bgColor:(UIColor *_Nullable)bgColor
                        maskImage:(UIImage *_Nullable)maskImage
                        configure:(JPCropConfigure)configure
                    compressScale:(CGFloat)compressScale
                         cacheURL:(NSURL *_Nullable)cacheURL
                       errorBlock:(JPImageresizerErrorBlock)errorBlock
                    completeBlock:(JPCropNGirdDoneBlock)completeBlock;

/**
 * 裁剪N宫格图片（NSData）
 */
+ (void)cropGirdPicturesWithImageData:(NSData *)imageData
                          columnCount:(NSInteger)columnCount
                             rowCount:(NSInteger)rowCount
                              bgColor:(UIColor *_Nullable)bgColor
                            maskImage:(UIImage *_Nullable)maskImage
                            configure:(JPCropConfigure)configure
                        compressScale:(CGFloat)compressScale
                             cacheURL:(NSURL *_Nullable)cacheURL
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
                        completeBlock:(JPCropNGirdDoneBlock)completeBlock;

#pragma mark - 裁剪GIF
/**
 * 裁剪GIF（UIImage）
 */
+ (void)cropGIFWithGifImage:(UIImage *)gifImage
             isReverseOrder:(BOOL)isReverseOrder
                       rate:(float)rate
                  maskImage:(UIImage *_Nullable)maskImage
                  configure:(JPCropConfigure)configure
              compressScale:(CGFloat)compressScale
                   cacheURL:(NSURL *_Nullable)cacheURL
                 errorBlock:(JPImageresizerErrorBlock)errorBlock
              completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 裁剪GIF其中一帧（UIImage）
 */
+ (void)cropGIFWithGifImage:(UIImage *)gifImage
                      index:(NSInteger)index
                  maskImage:(UIImage *_Nullable)maskImage
                  configure:(JPCropConfigure)configure
              compressScale:(CGFloat)compressScale
                   cacheURL:(NSURL *_Nullable)cacheURL
                 errorBlock:(JPImageresizerErrorBlock)errorBlock
              completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 裁剪GIF（NSData）
 */
+ (void)cropGIFWithGifData:(NSData *)gifData
            isReverseOrder:(BOOL)isReverseOrder
                      rate:(float)rate
                 maskImage:(UIImage *_Nullable)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *_Nullable)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 裁剪GIF其中一帧（NSData）
 */
+ (void)cropGIFWithGifData:(NSData *)gifData
                     index:(NSInteger)index
                 maskImage:(UIImage *_Nullable)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *_Nullable)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropDoneBlock)completeBlock;


#pragma mark - 裁剪视频
/**
 * 裁剪视频其中一帧
 */
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                  atSecond:(NSTimeInterval)second
                 maskImage:(UIImage *_Nullable)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *_Nullable)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 截取视频一小段并裁剪成GIF
 */
+ (void)cropVideoToGIFWithAsset:(AVURLAsset *)asset
                    startSecond:(NSTimeInterval)startSecond
                       duration:(NSTimeInterval)duration
                            fps:(float)fps
                           rate:(float)rate
                    maximumSize:(CGSize)maximumSize
                      maskImage:(UIImage *_Nullable)maskImage
                      configure:(JPCropConfigure)configure
                       cacheURL:(NSURL *_Nullable)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                  completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 裁剪视频
 */
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                presetName:(NSString *)presetName
                 configure:(JPCropConfigure)configure
                  cacheURL:(NSURL *_Nullable)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
                startBlock:(JPExportVideoStartBlock)startBlock
             completeBlock:(JPCropDoneBlock)completeBlock;

#pragma mark - 修正视频方向
+ (void)fixOrientationVideoWithAsset:(AVURLAsset *)asset
                       fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                       fixStartBlock:(JPExportVideoStartBlock)fixStartBlock
                    fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock;
@end

NS_ASSUME_NONNULL_END
