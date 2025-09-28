//
//  JPImageresizerTool.h
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/13.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerTypedef.h"
#import "JPImageProcessingSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPImageresizerTool : NSObject
/**
 * 转换成 alpha 反转的黑色蒙版图片
 */
+ (UIImage *)convertToAlphaInvertedBlackMaskImage:(UIImage *)image;

/**
 * 是否GIF
 */
+ (BOOL)isGIFData:(NSData *)data;

/**
 * 解码GIF【该方法采用的是 YYKit 的代码】
 */
+ (UIImage *_Nullable)decodeGIFData:(NSData *)data;

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
              otherSettings:(JPImageProcessingSettings *_Nullable)settings
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
             otherSettings:(JPImageProcessingSettings *_Nullable)settings
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
               startSecond:(NSTimeInterval)startSecond
                  duration:(NSTimeInterval)duration
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

#pragma mark - 图片处理并缓存（背景色、圆角、边框、轮廓描边、内容边距）

/**
 * 图片处理（NSData）
 */
+ (void)processImageWithImageData:(NSData *)imageData
                         settings:(JPImageProcessingSettings *_Nullable)settings
                         cacheURL:(NSURL *_Nullable)cacheURL
                       errorBlock:(JPImageresizerErrorBlock)errorBlock
                    completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 图片处理（UIImage）
 */
+ (void)processImageWithImage:(UIImage *)image
                     settings:(JPImageProcessingSettings *_Nullable)settings
                     cacheURL:(NSURL *_Nullable)cacheURL
                   errorBlock:(JPImageresizerErrorBlock)errorBlock
                completeBlock:(JPCropDoneBlock)completeBlock;

/**
 * 本地图片组装GIF
 */
+ (void)makeGIFWithImages:(NSArray<UIImage *> *)images
                 duration:(NSTimeInterval)duration
                 settings:(JPImageProcessingSettings *_Nullable)settings
                 cacheURL:(NSURL *_Nullable)cacheURL
               errorBlock:(JPImageresizerErrorBlock)errorBlock
            completeBlock:(JPCropDoneBlock)completeBlock;

#pragma mark - 获取图片目标像素的颜色值

/**
 * 获取图片目标像素的颜色值
 *  - 获取`RBGA`值并返回是否成功获取
 *  - `RGB: 0~255, alpha: 0~1`
 */
+ (BOOL)getRGBAFromImage:(UIImage *)image atPoint:(CGPoint)point red:(CGFloat *_Nullable)red green:(CGFloat *_Nullable)green blue:(CGFloat *_Nullable)blue alpha:(CGFloat *_Nullable)alpha;

/**
 * 获取图片目标像素的颜色
 *  - 返回`UIColor`
 */
+ (UIColor *_Nullable)getColorFromImage:(UIImage *)image atPoint:(CGPoint)point;

#pragma mark - 持续获取图片目标像素的颜色值

/**
 * 开始检索图片
 *  - 调用后会一直【持有】图片数据，当不再需要检索时，要调用`endRetrievalImage`方法来释放内存
 */
+ (void)beginRetrievalImage:(UIImage *)image;

/**
 * 获取「正在检索的图片」目标像素的颜色值
 *  - 获取`RBGA`值并返回是否成功获取
 *  - `RGB: 0~255, alpha: 0~1`
 */
+ (BOOL)getColorFromRetrievingImageAtPoint:(CGPoint)point red:(CGFloat *_Nullable)red green:(CGFloat *_Nullable)green blue:(CGFloat *_Nullable)blue alpha:(CGFloat *_Nullable)alpha;

/**
 * 获取「正在检索的图片」目标像素的颜色
 *  - 返回`UIColor`
 */
+ (UIColor *_Nullable)getColorFromRetrievingImageAtPoint:(CGPoint)point;

/**
 * 结束检索图片
 *  - 调用`beginRetrievalImage`方法后，最后要搭配该方法来释放内存
 */
+ (void)endRetrievalImage;

@end

NS_ASSUME_NONNULL_END
