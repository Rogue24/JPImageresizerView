//
//  JPImageresizerTool.h
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/13.
//

#import <AVFoundation/AVFoundation.h>
#import "JPImageresizerTypedef.h"

@interface JPImageresizerTool : NSObject

+ (UIImage *)cropPicture:(UIImage *)image
               maskImage:(UIImage *)maskImage
             isRoundClip:(BOOL)isRoundClip
               direction:(JPImageresizerRotationDirection)direction
             isVerMirror:(BOOL)isVerMirror
             isHorMirror:(BOOL)isHorMirror
           compressScale:(CGFloat)compressScale
       resizeContentSize:(CGSize)resizeContentSize
           resizeWHScale:(CGFloat)resizeWHScale
               cropFrame:(CGRect)cropFrame;

+ (UIImage *)cropVideoOneFrameWithAsset:(AVURLAsset *)asset
                                   time:(CMTime)time
                            maximumSize:(CGSize)maximumSize
                              maskImage:(UIImage *)maskImage
                            isRoundClip:(BOOL)isRoundClip
                              direction:(JPImageresizerRotationDirection)direction
                            isVerMirror:(BOOL)isVerMirror
                            isHorMirror:(BOOL)isHorMirror
                          compressScale:(CGFloat)compressScale
                      resizeContentSize:(CGSize)resizeContentSize
                          resizeWHScale:(CGFloat)resizeWHScale
                              cropFrame:(CGRect)cropFrame;

+ (AVAssetExportSession *)cropVideoWithAsset:(AVURLAsset *)asset
                                   timeRange:(CMTimeRange)timeRange
                               frameDuration:(CMTime)frameDuration
                                   cachePath:(NSString *)cachePath
                                  presetName:(NSString *)presetName
                                   direction:(JPImageresizerRotationDirection)direction
                                 isVerMirror:(BOOL)isVerMirror
                                 isHorMirror:(BOOL)isHorMirror
                           resizeContentSize:(CGSize)resizeContentSize
                               resizeWHScale:(CGFloat)resizeWHScale
                                   cropFrame:(CGRect)cropFrame
                                  errorBlock:(JPCropVideoErrorBlock)errorBlock
                               completeBlock:(JPCropVideoCompleteBlock)completeBlock;

+ (UIImage *)convertBlackImage:(UIImage *)image;

@end
