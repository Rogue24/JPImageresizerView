//
//  JPImageresizerTool.m
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/13.
//

#import "JPImageresizerTool.h"

@implementation JPImageresizerTool

#pragma mark - 计算函数

CG_INLINE BOOL JPIsSameSize(CGSize size1, CGSize size2) {
    return (fabs(size1.width - size2.width) < 0.5 && fabs(size1.height - size2.height) < 0.5);
}

CG_INLINE CGRect JPConfirmCropFrame(CGRect cropFrame, CGSize resizeContentSize, CGFloat resizeWHScale, CGSize originSize) {
    if (JPIsSameSize(cropFrame.size, resizeContentSize)) {
        return (CGRect){CGPointZero, originSize};
    }
    // 获取裁剪区域
    CGFloat originWidth = originSize.width;
    CGFloat originHeight = originSize.height;
    CGFloat relativeScale = originWidth / resizeContentSize.width;
    if (cropFrame.origin.x < 0) cropFrame.origin.x = 0;
    if (cropFrame.origin.y < 0) cropFrame.origin.y = 0;
    cropFrame.origin.x *= relativeScale;
    cropFrame.origin.y *= relativeScale;
    cropFrame.size.width *= relativeScale;
    if (cropFrame.size.width > originWidth) cropFrame.size.width = originWidth;
    cropFrame.size.height = cropFrame.size.width / resizeWHScale;
    if (cropFrame.size.height > originHeight) {
        cropFrame.size.height = originHeight;
        cropFrame.size.width = cropFrame.size.height * resizeWHScale;
    }
    if (CGRectGetMaxX(cropFrame) > originWidth) cropFrame.origin.x = originWidth - cropFrame.size.width;
    if (CGRectGetMaxY(cropFrame) > originHeight) cropFrame.origin.y = originHeight - cropFrame.size.height;
    return cropFrame;
}

CG_INLINE CGAffineTransform JPConfirmTransform(CGSize originSize, JPImageresizerRotationDirection direction, BOOL isVerMirror, BOOL isHorMirror, BOOL isImage) {
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (direction) {
        case JPImageresizerHorizontalLeftDirection:
        {
            if (isImage) {
                transform = CGAffineTransformTranslate(transform, originSize.height, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
            } else {
                transform = CGAffineTransformTranslate(transform, 0, originSize.width);
                transform = CGAffineTransformRotate(transform, M_PI_2 * 3);
            }
            break;
        }
        case JPImageresizerVerticalDownDirection:
        {
            if (isImage) {
                transform = CGAffineTransformTranslate(transform, originSize.width, originSize.height);
                transform = CGAffineTransformRotate(transform, M_PI);
            } else {
                transform = CGAffineTransformTranslate(transform, originSize.width, originSize.height);
                transform = CGAffineTransformRotate(transform, M_PI);
            }
            break;
        }
        case JPImageresizerHorizontalRightDirection:
        {
            if (isImage) {
                transform = CGAffineTransformTranslate(transform, 0, originSize.width);
                transform = CGAffineTransformRotate(transform,  M_PI_2 * 3);
            } else {
                transform = CGAffineTransformTranslate(transform, originSize.height, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
            }
            break;
        }
        default:
            break;
    }
    if (isVerMirror) {
        transform = CGAffineTransformTranslate(transform, originSize.width, 0.0);
        transform = CGAffineTransformScale(transform, -1.0, 1.0);
    }
    if (isHorMirror) {
        transform = CGAffineTransformTranslate(transform, 0.0, originSize.height);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
    }
    return transform;
}

CG_INLINE CGPoint JPConfirmTranslate(CGRect cropFrame, CGSize originSize, JPImageresizerRotationDirection direction, BOOL isVerMirror, BOOL isHorMirror, BOOL isImage) {
    if (JPIsSameSize(cropFrame.size, originSize)) {
        return CGPointZero;
    }
    CGFloat tx = cropFrame.origin.x;
    CGFloat ty = cropFrame.origin.y;
    switch (direction) {
        case JPImageresizerVerticalUpDirection:
            // 原点在左上
            if (isVerMirror || isHorMirror) {
                if (isVerMirror && isHorMirror) {
                    return JPConfirmTranslate(cropFrame, originSize, JPImageresizerVerticalDownDirection, NO, NO, isImage);
                } else if (isVerMirror) {
                    if (isImage) {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                        ty = -(originSize.height - CGRectGetMaxY(cropFrame));
                    } else {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                        ty = -ty;
                    }
                } else {
                    if (isImage) {
                        tx = -tx;
                    } else {
                        tx = -tx;
                        ty = originSize.height - CGRectGetMaxY(cropFrame);
                    }
                }
            } else {
                if (isImage) {
                    tx = -tx;
                    ty = -(originSize.height - CGRectGetMaxY(cropFrame));
                } else {
                    tx = -tx;
                    ty = -ty;
                }
            }
            break;
        case JPImageresizerHorizontalLeftDirection:
            // 原点在左下
            if (isVerMirror || isHorMirror) {
                if (isVerMirror && isHorMirror) {
                    return JPConfirmTranslate(cropFrame, originSize, JPImageresizerHorizontalRightDirection, NO, NO , isImage);
                } else if (isVerMirror) {
                    if (isImage) {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                    } else {
                        tx = -tx;
                        ty = -ty;
                    }
                } else {
                    if (isImage) {
                        tx = -tx;
                        ty = -(originSize.height - CGRectGetMaxY(cropFrame));
                    } else {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                        ty = originSize.height - CGRectGetMaxY(cropFrame);
                    }
                }
            } else {
                if (isImage) {
                    tx = -tx;
                } else {
                    tx = originSize.width - CGRectGetMaxX(cropFrame);
                    ty = -ty;
                }
            }
            break;
        case JPImageresizerVerticalDownDirection:
            // 原点在右下
            if (isVerMirror || isHorMirror) {
                if (isVerMirror && isHorMirror) {
                    return JPConfirmTranslate(cropFrame, originSize, JPImageresizerVerticalUpDirection, NO, NO, isImage);
                } else if (isVerMirror) {
                    if (isImage) {
                        tx = -tx;
                    } else {
                        tx = -tx;
                        ty = originSize.height - CGRectGetMaxY(cropFrame);
                    }
                } else {
                    if (isImage) {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                        ty = -(originSize.height - CGRectGetMaxY(cropFrame));
                    } else {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                        ty = -ty;
                    }
                }
            } else {
                if (isImage) {
                    tx = originSize.width - CGRectGetMaxX(cropFrame);
                } else {
                    tx = originSize.width - CGRectGetMaxX(cropFrame);
                    ty = originSize.height - CGRectGetMaxY(cropFrame);
                }
            }
            break;
        case JPImageresizerHorizontalRightDirection:
            // 原点在右上
            if (isVerMirror || isHorMirror) {
                if (isVerMirror && isHorMirror) {
                    return JPConfirmTranslate(cropFrame, originSize, JPImageresizerHorizontalLeftDirection, NO, NO, isImage);
                } else if (isVerMirror) {
                    if (isImage) {
                        tx = -tx;
                        ty = -(originSize.height - CGRectGetMaxY(cropFrame));
                    } else {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                        ty = originSize.height - CGRectGetMaxY(cropFrame);
                    }
                } else {
                    if (isImage) {
                        tx = originSize.width - CGRectGetMaxX(cropFrame);
                    } else {
                        tx = -tx;
                        ty = -ty;
                    }
                }
            } else {
                if (isImage) {
                    tx = originSize.width - CGRectGetMaxX(cropFrame);
                    ty = -(originSize.height - CGRectGetMaxY(cropFrame));
                } else {
                    tx = -tx;
                    ty = originSize.height - CGRectGetMaxY(cropFrame);
                }
            }
            break;
    }
    return CGPointMake(tx, ty);
}

#pragma mark - 裁剪图片

+ (UIImage *)cropPicture:(UIImage *)image
               maskImage:(UIImage *)maskImage
             isRoundClip:(BOOL)isRoundClip
               direction:(JPImageresizerRotationDirection)direction
             isVerMirror:(BOOL)isVerMirror
             isHorMirror:(BOOL)isHorMirror
           compressScale:(CGFloat)compressScale
       resizeContentSize:(CGSize)resizeContentSize
           resizeWHScale:(CGFloat)resizeWHScale
               cropFrame:(CGRect)cropFrame {
    if (!image || compressScale <= 0) return nil;
    @autoreleasepool {
        
        image = [self __imageFixOrientation:image];
        
        if (compressScale > 1) compressScale = 1;
        if (JPIsSameSize(cropFrame.size, resizeContentSize) &&
            direction == JPImageresizerVerticalUpDirection &&
            isVerMirror == NO &&
            isHorMirror == NO &&
            maskImage == nil &&
            isRoundClip == NO &&
            compressScale == 1) {
            return image;
        }
        
        CGImageRef imageRef = image.CGImage;
        
        // 获取裁剪尺寸和裁剪区域
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef) * compressScale, CGImageGetHeight(imageRef) * compressScale);
        
        cropFrame = JPConfirmCropFrame(cropFrame, resizeContentSize, resizeWHScale, imageSize);
        
        CGRect renderRect = (CGRect){CGPointZero, cropFrame.size};
        if (direction == JPImageresizerHorizontalLeftDirection || direction == JPImageresizerHorizontalRightDirection) {
            CGFloat tmp = renderRect.size.width;
            renderRect.size.width = renderRect.size.height;
            renderRect.size.height = tmp;
        }
        
        CGAffineTransform transform = JPConfirmTransform(imageSize, direction, isVerMirror, isHorMirror, YES);
        CGPoint translate = JPConfirmTranslate(cropFrame, imageSize, direction, isVerMirror, isHorMirror, YES);
        transform = CGAffineTransformTranslate(transform, translate.x, translate.y);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        if (maskImage || isRoundClip) {
            bitmapInfo |= kCGImageAlphaPremultipliedFirst;
        } else {
            CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
            if (alphaInfo == kCGImageAlphaPremultipliedLast ||
                alphaInfo == kCGImageAlphaPremultipliedFirst ||
                alphaInfo == kCGImageAlphaLast ||
                alphaInfo == kCGImageAlphaFirst) {
                bitmapInfo |= kCGImageAlphaPremultipliedFirst;
            } else {
                bitmapInfo |= kCGImageAlphaNoneSkipFirst;
            }
        }
        
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     renderRect.size.width,
                                                     renderRect.size.height,
                                                     8,
                                                     0,
                                                     colorSpace,
                                                     bitmapInfo);
        
        CGContextSetShouldAntialias(context, true);
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        
        if (maskImage) {
            CGImageRef maskImageRef = maskImage.CGImage;
            CGContextClipToMask(context, renderRect, maskImageRef);
        }
        
        if (isRoundClip) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:renderRect cornerRadius:MIN(renderRect.size.width, renderRect.size.height)];
            CGContextAddPath(context, path.CGPath);
            CGContextClip(context);
        }
        
        CGContextConcatCTM(context, transform);
        CGContextDrawImage(context, (CGRect){CGPointZero, imageSize}, imageRef);
        
        CGImageRef newImageRef = CGBitmapContextCreateImage(context);
        UIImage *finalImage = [UIImage imageWithCGImage:newImageRef];
        
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CGImageRelease(newImageRef);
        
        return finalImage;
    }
}

#pragma mark - 裁剪视频一帧画面

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
                              cropFrame:(CGRect)cropFrame {
    if (!asset || compressScale <= 0) return nil;
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.maximumSize = maximumSize;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:nil error:nil];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    return [self cropPicture:image
                   maskImage:maskImage
                 isRoundClip:isRoundClip
                   direction:direction
                 isVerMirror:isVerMirror
                 isHorMirror:isHorMirror
               compressScale:compressScale
           resizeContentSize:resizeContentSize
               resizeWHScale:resizeWHScale
                   cropFrame:cropFrame];
}

#pragma mark - 裁剪视频

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
                               completeBlock:(JPCropVideoCompleteBlock)completeBlock {
    if (!asset) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(nil, JPCVEReason_NotAssets);
            });
        }
        return nil;
    }
    
    NSString *fileName;
    if (cachePath) {
        fileName = [cachePath lastPathComponent];
    } else {
        fileName = [NSString stringWithFormat:@"%.0lf.mp4", [[NSDate date] timeIntervalSince1970]];
        cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    }
    
    // 判断缓存路径是否已经存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cachePath]) {
        if (errorBlock) {
            __block BOOL isContinue = NO;
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_main_queue(), ^{
                isContinue = errorBlock ? errorBlock(cachePath, JPCVEReason_CachePathAlreadyExists) : NO;
                dispatch_semaphore_signal(semaphore);
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (isContinue) {
                if ([fileManager fileExistsAtPath:cachePath]) [fileManager removeItemAtPath:cachePath error:nil];
            } else {
                return nil;
            }
        } else {
            [fileManager removeItemAtPath:cachePath error:nil];
        }
    }
    
    // 设置临时导出路径
    NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:tmpFilePath]) {
        [fileManager removeItemAtPath:tmpFilePath error:nil];
    }
    
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!videoTrack) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(nil, JPCVEReason_VideoAlreadyDamage);
            });
        }
        return nil;
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 插入音频
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }
    
    // 插入视频
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    CGSize videoSize = videoTrack.naturalSize;
    cropFrame = JPConfirmCropFrame(cropFrame, resizeContentSize, resizeWHScale, videoSize);
    
    CGSize renderSize = cropFrame.size;
    // 防止绿边
    NSInteger renderW = (NSInteger)renderSize.width;
    NSInteger renderH = (NSInteger)renderSize.height;
    renderW -= (renderW % 16);
    renderH -= (renderH % 16);
    if (direction == JPImageresizerHorizontalLeftDirection || direction == JPImageresizerHorizontalRightDirection) {
        renderSize = CGSizeMake((CGFloat)renderH, (CGFloat)renderW);
    } else {
        renderSize = CGSizeMake((CGFloat)renderW, (CGFloat)renderH);
    }
    
    CGAffineTransform transform = JPConfirmTransform(videoSize, direction, isVerMirror, isHorMirror, NO);
    CGPoint translate = JPConfirmTranslate(cropFrame, videoSize, direction, isVerMirror, isHorMirror, NO);
    transform = CGAffineTransformTranslate(transform, translate.x, translate.y);
    
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [layerInstruciton setTransform:transform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *compositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    compositionInstruction.timeRange = timeRange;
    compositionInstruction.layerInstructions = @[layerInstruciton];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = @[compositionInstruction];
    videoComposition.frameDuration = frameDuration;
    videoComposition.renderScale = 1;
    videoComposition.renderSize = renderSize;
    
    // 根据文件后缀名获取文件类型
    NSString *extension = [fileName pathExtension];
    AVFileType fileType = nil;
    if ([extension isEqualToString:@"m4a"]) {
        fileType = AVFileTypeAppleM4A;
    } else if ([extension isEqualToString:@"m4v"]) {
        fileType = AVFileTypeAppleM4V;
    } else if ([extension isEqualToString:@"mov"]) {
        fileType = AVFileTypeQuickTimeMovie;
    } else if ([extension isEqualToString:@"mp4"]) {
        fileType = AVFileTypeMPEG4;
    } else {
        fileType = AVFileTypeMPEGLayer3;
    }
    
    AVAssetExportSession *exporterSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:(presetName ? presetName : AVAssetExportPresetHighestQuality)];
    exporterSession.videoComposition = videoComposition;
    exporterSession.outputFileType = fileType;
    exporterSession.outputURL = [NSURL fileURLWithPath:tmpFilePath];
    exporterSession.shouldOptimizeForNetworkUse = YES;
    
    [exporterSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = exporterSession.status;
        if (status == AVAssetExportSessionStatusCompleted) {
            NSURL *videoURL;
            if ([tmpFilePath isEqualToString:cachePath]) {
                videoURL = [NSURL fileURLWithPath:cachePath];
            } else {
                NSError *error;
                [[NSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:cachePath error:&error];
                videoURL = error == nil ? [NSURL fileURLWithPath:cachePath] : [NSURL fileURLWithPath:tmpFilePath];
            }
            if (completeBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(videoURL);
                });
            }
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil];
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(nil, (status == AVAssetExportSessionStatusCancelled ? JPCVEReason_ExportCancelled : JPCVEReason_ExportFailed));
                });
            }
        }
    }];
    
    return exporterSession;
}

#pragma mark - 图片处理

+ (UIImage *)__imageFixOrientation:(UIImage *)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGFloat imageWidth = CGImageGetWidth(image.CGImage);
    CGFloat imageHeight = CGImageGetHeight(image.CGImage);
    if ((imageWidth >= imageHeight) != (image.size.width >= image.size.height)) {
        CGFloat tmpW = imageWidth;
        CGFloat tmpH = imageHeight;
        if (image.size.width >= image.size.height) {
            imageWidth = MAX(tmpW, tmpH);
            imageHeight = MIN(tmpW, tmpH);
        } else {
            imageWidth = MIN(tmpW, tmpH);
            imageHeight = MAX(tmpW, tmpH);
        }
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageWidth, imageHeight);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, imageWidth, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, imageHeight);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageWidth, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, imageHeight, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, imageWidth, imageHeight,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, imageHeight, imageWidth), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)convertBlackImage:(UIImage *)image {
    if (!image) return nil;
    CGRect rect = (CGRect){CGPointZero, image.size};
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    [UIColor.blackColor setFill];
    UIRectFill(rect);
    [image drawInRect:rect blendMode:kCGBlendModeDestinationOut alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
