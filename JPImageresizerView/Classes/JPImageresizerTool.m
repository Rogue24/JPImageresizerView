//
//  JPImageresizerTool.m
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/13.
//

#import "JPImageresizerTool.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation JPImageresizerTool

#pragma mark - 计算函数

static BOOL JPIsSameSize(CGSize size1, CGSize size2) {
    return (fabs(size1.width - size2.width) < 0.5 && fabs(size1.height - size2.height) < 0.5);
}

static CGRect JPConfirmCropFrame(CGRect cropFrame, CGSize resizeContentSize, CGFloat resizeWHScale, CGSize originSize) {
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

static CGAffineTransform JPConfirmTransform(CGSize originSize, JPImageresizerRotationDirection direction, BOOL isVerMirror, BOOL isHorMirror, BOOL isImage) {
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

static CGPoint JPConfirmTranslate(CGRect cropFrame, CGSize originSize, JPImageresizerRotationDirection direction, BOOL isVerMirror, BOOL isHorMirror, BOOL isImage) {
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

static NSTimeInterval JPImageSourceGetGIFFrameDelayAtIndex(CGImageSourceRef source, size_t index) {
    NSTimeInterval delay = 0;
    CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    if (dic) {
        CFDictionaryRef dicGIF = CFDictionaryGetValue(dic, kCGImagePropertyGIFDictionary);
        if (dicGIF) {
            NSNumber *num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFUnclampedDelayTime);
            if (num.doubleValue <= __FLT_EPSILON__) {
                num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFDelayTime);
            }
            delay = num.doubleValue;
        }
        CFRelease(dic);
    }
    // http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    if (delay < 0.02) delay = 0.1;
    return delay;
};

static CGImageRef JPCreateNewCGImage(CGImageRef imageRef, CGContextRef context, UIImage *maskImage, BOOL isRoundClip, CGRect renderRect, CGAffineTransform transform, CGSize imageSize) {
    if (maskImage) {
        CGImageRef maskImageRef = maskImage.CGImage;
        CGContextClipToMask(context, renderRect, maskImageRef);
    }
    if (isRoundClip) {
        CGFloat radius = MIN(renderRect.size.width, renderRect.size.height) * 0.5;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:renderRect cornerRadius:radius];
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, (CGRect){CGPointZero, imageSize}, imageRef);
    return CGBitmapContextCreateImage(context);
}

#pragma mark - 私有方法

#pragma mark 修正图片方向
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

#pragma mark 执行回调的Block
+ (void)__executeErrorBlock:(JPImageresizerErrorBlock)block cacheURL:(NSURL *)cacheURL reason:(JPImageresizerErrorReason)reason {
    if (!block) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        block(cacheURL, reason);
    });
}
+ (void)__executeCropPictureDoneBlock:(JPCropPictureDoneBlock)block finalImage:(UIImage *)finalImage cacheURL:(NSURL *)cacheURL isCacheSuccess:(BOOL)isCacheSuccess {
    if (!block) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        block(finalImage, isCacheSuccess ? cacheURL : nil, isCacheSuccess);
    });
}
+ (void)__executeExportVideoStart:(JPExportVideoStartBlock)block exportSession:(AVAssetExportSession *)exportSession {
    if (!block) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        block(exportSession);
    });
}
+ (void)__executeExportVideoCompleteBlock:(JPExportVideoCompleteBlock)block cacheURL:(NSURL *)cacheURL {
    if (!block) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        block(cacheURL);
    });
}

#pragma mark 获取图片类型后缀
+ (NSString *)__contentTypeSuffixForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
        {
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
        }
        default:
            return nil;
    }
}

#pragma mark 根据后缀获取图片类型
+ (CFStringRef)__contentTypeForSuffix:(NSString *)suffix quality:(CGFloat *)quality {
    CFStringRef contentType;
    if ([suffix caseInsensitiveCompare:@"jpeg"] == NSOrderedSame) {
        contentType = kUTTypeJPEG;
        if (quality) *quality = 0.9;
    } else if ([suffix caseInsensitiveCompare:@"png"] == NSOrderedSame) {
        contentType = kUTTypePNG;
        if (quality) *quality = 1;
    } else if ([suffix caseInsensitiveCompare:@"gif"] == NSOrderedSame) {
        contentType = kUTTypeGIF;
        if (quality) *quality = 1;
    } else if ([suffix caseInsensitiveCompare:@"tiff"] == NSOrderedSame) {
        contentType = kUTTypeTIFF;
        if (quality) *quality = 1;
    } else {
        contentType = NULL;
        if (quality) *quality = ([suffix caseInsensitiveCompare:@"webp"] == NSOrderedSame) ? 0.8 : 1;
    }
    return contentType;
}

#pragma mark 根据后缀获取视频类型
+ (AVFileType)__videoFileTypeForSuffix:(NSString *)suffix {
    // 根据文件后缀名获取文件类型
    AVFileType fileType = nil;
    if ([suffix caseInsensitiveCompare:@"m4a"] == NSOrderedSame) {
        fileType = AVFileTypeAppleM4A;
    } else if ([suffix caseInsensitiveCompare:@"m4v"] == NSOrderedSame) {
        fileType = AVFileTypeAppleM4V;
    } else if ([suffix caseInsensitiveCompare:@"mov"] == NSOrderedSame) {
        fileType = AVFileTypeQuickTimeMovie;
    } else if ([suffix caseInsensitiveCompare:@"mp4"] == NSOrderedSame) {
        fileType = AVFileTypeMPEG4;
    }
    return fileType;
}

#pragma mark 缓存图片
+ (BOOL)__cacheImage:(UIImage *)image cacheURL:(NSURL *)cacheURL {
    if (!cacheURL || !image) {
        return NO;
    }
    
    CGFloat quality;
    CFStringRef imageType = [self __contentTypeForSuffix:cacheURL.pathExtension quality:&quality];
    NSDictionary *frameProperty = @{(id)kCGImageDestinationLossyCompressionQuality: @(quality)};
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)cacheURL, imageType, 1, NULL);
    CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)frameProperty);
    
    BOOL isCacheSuccess = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    if (!isCacheSuccess) [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
    return isCacheSuccess;
}

#pragma mark 缓存GIF文件
+ (BOOL)__cacheGIF:(NSArray<UIImage *> *)images delays:(NSArray *)delays cacheURL:(NSURL *)cacheURL {
    if (!cacheURL || images.count == 0) {
        return NO;
    }
    
    size_t count = images.count;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)cacheURL, kUTTypeGIF , count, NULL);
    
    NSDictionary *gifProperty = @{(__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFLoopCount: @0}};
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperty);
    
    void (^cacheBlock)(NSInteger i);
    if (images.count == delays.count) {
        cacheBlock = ^(NSInteger i) {
           UIImage *img = images[i];
           NSTimeInterval delay = [delays[i] doubleValue];
           NSDictionary *frameProperty = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(delay)}};
           CGImageDestinationAddImage(destination, img.CGImage, (CFDictionaryRef)frameProperty);
       };
    } else {
        NSTimeInterval delay = delays.count ? [delays.firstObject doubleValue] : 0.1;
        NSDictionary *frameProperty = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(delay)}};
        
        cacheBlock = ^(NSInteger i) {
            UIImage *img = images[i];
            CGImageDestinationAddImage(destination, img.CGImage, (CFDictionaryRef)frameProperty);
        };
    }
    
    for (NSInteger i = 0; i < count; i++) {
        cacheBlock(i);
    }
    
    BOOL isCacheSuccess = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    if (!isCacheSuccess) [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
    return isCacheSuccess;
}

#pragma mark 裁剪图片&GIF
+ (void)__cropPicture:(UIImage *)image
            imageData:(NSData *)imageData
                isGIF:(BOOL)isGIF
       isReverseOrder:(BOOL)isReverseOrder
                 rate:(float)rate
                index:(NSInteger)index // -1 代表裁剪整个Gif全部
            maskImage:(UIImage *)maskImage
            configure:(JPCropConfigure)configure
        compressScale:(CGFloat)compressScale
             cacheURL:(NSURL *)cacheURL
           errorBlock:(JPImageresizerErrorBlock)errorBlock
        completeBlock:(JPCropPictureDoneBlock)completeBlock {
    
    if ((!image && !imageData) || compressScale <= 0) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self __cropPicture:image
                      imageData:imageData
                          isGIF:isGIF
                 isReverseOrder:isReverseOrder
                           rate:rate
                          index:index
                      maskImage:maskImage
                      configure:configure
                  compressScale:compressScale
                       cacheURL:cacheURL
                     errorBlock:errorBlock
                  completeBlock:completeBlock];
        });
        return;
    }
    
    if (!image) image = [UIImage imageWithData:imageData];
    if (!image) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    JPImageresizerRotationDirection direction = configure.direction;
    BOOL isVerMirror = configure.isVerMirror;
    BOOL isHorMirror = configure.isHorMirror;
    BOOL isRoundClip = configure.isRoundClip;
    CGSize resizeContentSize = configure.resizeContentSize;
    CGFloat resizeWHScale = configure.resizeWHScale;
    CGRect cropFrame = configure.cropFrame;
    if (compressScale > 1) compressScale = 1;
    
    BOOL isCacheSuccess = NO;
    
    CGImageRef imageRef = image.CGImage;
    
    // 是否带透明度
    BOOL hasAlpha = NO;
    if (maskImage || isRoundClip) {
        hasAlpha = YES;
    } else {
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) hasAlpha = YES;
    }
    
    if (cacheURL) {
        NSString *pathExtension = cacheURL.pathExtension;
        NSString *extension = isGIF ? @"gif" : (hasAlpha ? @"png" : (imageData ? [self __contentTypeSuffixForImageData:imageData] : @"jpeg"));
        if (!extension.length) {
            cacheURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", cacheURL.absoluteString, extension]];
        } else if (![extension isEqualToString:pathExtension]) {
            NSString *absoluteString = cacheURL.absoluteString;
            if (pathExtension.length) {
                NSString *lastPathComponent = cacheURL.lastPathComponent;
                NSRange lastPathComponentRange = NSMakeRange(absoluteString.length - lastPathComponent.length, lastPathComponent.length);
                lastPathComponent = [lastPathComponent componentsSeparatedByString:@"."].firstObject;
                absoluteString = [absoluteString stringByReplacingCharactersInRange:lastPathComponentRange withString:lastPathComponent];
            }
            cacheURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", absoluteString, extension]];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path]) {
            [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_CacheURLAlreadyExists];
            return;
        }
    }
    
    if (JPIsSameSize(cropFrame.size, resizeContentSize) &&
        direction == JPImageresizerVerticalUpDirection &&
        isVerMirror == NO &&
        isHorMirror == NO &&
        maskImage == nil &&
        isRoundClip == NO &&
        isReverseOrder == NO &&
        rate == 1 &&
        index < 0 &&
        compressScale == 1) {
        if (cacheURL) {
            if (imageData) {
                isCacheSuccess = [imageData writeToURL:cacheURL atomically:YES];
                if (!isCacheSuccess) [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
            } else {
                if (isGIF) {
                    NSUInteger count = image.images.count;
                    NSTimeInterval duration = image.duration;
                    NSTimeInterval delay = duration / (NSTimeInterval)count;
                    if (delay < 0.02) delay = 0.1;
                    isCacheSuccess = [self __cacheGIF:image.images delays:@[@(delay)] cacheURL:cacheURL];
                } else {
                    isCacheSuccess = [self __cacheImage:image cacheURL:cacheURL];
                }
            }
        }
        [self __executeCropPictureDoneBlock:completeBlock finalImage:image cacheURL:cacheURL isCacheSuccess:isCacheSuccess];
        return;
    }
    
    CGImageSourceRef source = NULL;
    size_t count = 1;
    if (isGIF) {
        if (imageData) {
            source = CGImageSourceCreateWithData((__bridge CFTypeRef)(imageData), NULL);
            count = CGImageSourceGetCount(source);
            if ((index > 0) && (index > (count - 1))) index = count - 1;
            imageRef = CGImageSourceCreateImageAtIndex(source, (index > 0 ? index : 0), NULL);
        } else {
            count = image.images.count;
            if ((index > 0) && (index > (count - 1))) index = count - 1;
            imageRef = image.images[index > 0 ? index : 0].CGImage;
        }
    } else {
        image = [self __imageFixOrientation:image];
        imageRef = image.CGImage;
    }
    
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
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, renderRect.size.width, renderRect.size.height, 8, 0, colorSpace, bitmapInfo);
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    UIImage *finalImage;
    if (isGIF && index < 0) {
        [self __cropGIFWithGifImage:image
                             source:source
                            context:context
                               rate:rate
                              count:count
                          maskImage:maskImage
                        isRoundClip:isRoundClip
                         renderRect:renderRect
                          transform:transform
                          imageSize:imageSize
                     isReverseOrder:isReverseOrder
                           cacheURL:cacheURL
                     isCacheSuccess:&isCacheSuccess
                         finalImage:&finalImage];
    } else {
        CGImageRef newImageRef = JPCreateNewCGImage(imageRef, context, maskImage, isRoundClip, renderRect, transform, imageSize);
        finalImage = [UIImage imageWithCGImage:newImageRef];
        CGImageRelease(newImageRef);
        isCacheSuccess = [self __cacheImage:finalImage cacheURL:cacheURL];
    }
    
    if (source != NULL) CFRelease(source);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    [self __executeCropPictureDoneBlock:completeBlock finalImage:finalImage cacheURL:cacheURL isCacheSuccess:isCacheSuccess];
}

#pragma mark 裁剪GIF
+ (void)__cropGIFWithGifImage:(UIImage *)image
                       source:(CGImageSourceRef)source
                      context:(CGContextRef)context
                         rate:(float)rate
                        count:(size_t)count
                    maskImage:(UIImage *)maskImage
                  isRoundClip:(BOOL)isRoundClip
                   renderRect:(CGRect)renderRect
                    transform:(CGAffineTransform)transform
                    imageSize:(CGSize)imageSize
               isReverseOrder:(BOOL)isReverseOrder
                     cacheURL:(NSURL *)cacheURL
               isCacheSuccess:(BOOL *)isCacheSuccess
                   finalImage:(UIImage **)finalImage {
    
    __block NSTimeInterval duration = 0;
    NSMutableArray *delays = [NSMutableArray array];
    CGImageRef (^getCurrentImageRef)(size_t i);
    
    if (source != NULL) {
        getCurrentImageRef = ^(size_t i) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            NSTimeInterval delay = JPImageSourceGetGIFFrameDelayAtIndex(source, i) / rate;
            duration += delay;
            [delays addObject:@(delay)];
            
            return imageRef;
        };
    } else {
        duration = image.duration / rate;
        
        NSTimeInterval delay = duration / (NSTimeInterval)count;
        if (delay < 0.02) delay = 0.1;
        [delays addObject:@(delay)];
        
        getCurrentImageRef = ^(size_t i){
            return image.images[i].CGImage;
        };
    }
    
    NSMutableArray *images = [NSMutableArray array];
    void (^createNewImageRef)(size_t i) = ^(size_t i) {
        @autoreleasepool {
            // 将当前图形状态推入堆栈
            CGContextSaveGState(context);
            // 绘制裁剪后的图片
            CGImageRef newImageRef = JPCreateNewCGImage(getCurrentImageRef(i), context, maskImage, isRoundClip, renderRect, transform, imageSize);
            [images addObject:[UIImage imageWithCGImage:newImageRef]];
            CGImageRelease(newImageRef);
            // 清空画布
            CGContextClearRect(context, renderRect);
            // 把堆栈顶部的状态弹出，返回到之前的图形状态
            CGContextRestoreGState(context);
        }
    };
    
    if (isReverseOrder) {
        for (NSInteger i = (count - 1); i >= 0; i--) {
            createNewImageRef(i);
        }
    } else {
        for (NSInteger i = 0; i < count; i++) {
            createNewImageRef(i);
        }
    }
    
    BOOL result = [self __cacheGIF:images delays:delays cacheURL:cacheURL];
    if (isCacheSuccess) *isCacheSuccess = result;
    if (finalImage) *finalImage = images.count > 1 ? [UIImage animatedImageWithImages:images duration:duration] : images.firstObject;
}

#pragma mark - 公开方法

#pragma mark 转换成黑色轮廓的图片
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

#pragma mark 解码GIF
+ (UIImage *)decodeGIFData:(NSData *)data {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
    if (!source) return nil;
    
    size_t count = CGImageSourceGetCount(source);
    if (count <= 1) {
        CFRelease(source);
        return [UIImage imageWithData:data];
    }
    
    NSUInteger frames[count];
    double oneFrameTime = 1 / 50.0; // 50 fps
    NSTimeInterval totalTime = 0;
    NSUInteger totalFrame = 0;
    NSUInteger gcdFrame = 0;
    for (size_t i = 0; i < count; i++) {
        NSTimeInterval delay = JPImageSourceGetGIFFrameDelayAtIndex(source, i);
        totalTime += delay;
        NSInteger frame = lrint(delay / oneFrameTime);
        if (frame < 1) frame = 1;
        frames[i] = frame;
        totalFrame += frames[i];
        if (i == 0) gcdFrame = frames[i];
        else {
            NSUInteger frame = frames[i], tmp;
            if (frame < gcdFrame) {
                tmp = frame; frame = gcdFrame; gcdFrame = tmp;
            }
            while (true) {
                tmp = frame % gcdFrame;
                if (tmp == 0) break;
                frame = gcdFrame;
                gcdFrame = tmp;
            }
        }
    }
    NSMutableArray *array = [NSMutableArray new];
    for (size_t i = 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!imageRef) {
            CFRelease(source);
            return nil;
        }
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
        CGColorSpaceRelease(space);
        if (!context) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef decoded = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (!decoded) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        UIImage *image = [UIImage imageWithCGImage:decoded];
        CGImageRelease(imageRef);
        CGImageRelease(decoded);
        if (!image) {
            CFRelease(source);
            return nil;
        }
        for (size_t j = 0, max = frames[i] / gcdFrame; j < max; j++) {
            [array addObject:image];
        }
    }
    CFRelease(source);
    UIImage *image = [UIImage animatedImageWithImages:array duration:totalTime];
    return image;
}

#pragma mark 是否为GIF
+ (BOOL)isGIFData:(NSData *)data {
    if (!data) return NO;
    uint8_t c;
    [data getBytes:&c length:1];
    return c == 0x47;
}

#pragma mark - 裁剪图片

#pragma mark 裁剪图片（UIImage）
+ (void)cropPictureWithImage:(UIImage *)image
                   maskImage:(UIImage *)maskImage
                   configure:(JPCropConfigure)configure
               compressScale:(CGFloat)compressScale
                    cacheURL:(NSURL *)cacheURL
                  errorBlock:(JPImageresizerErrorBlock)errorBlock
               completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self __cropPicture:image
              imageData:nil
                  isGIF:NO
         isReverseOrder:NO
                   rate:1
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}


#pragma mark 裁剪图片（NSData）
+ (void)cropPictureWithImageData:(NSData *)imageData
                       maskImage:(UIImage *)maskImage
                       configure:(JPCropConfigure)configure
                   compressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self __cropPicture:nil
              imageData:imageData
                  isGIF:NO
         isReverseOrder:NO
                   rate:1
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}

#pragma mark - 裁剪GIF

#pragma mark 裁剪GIF（UIImage）
+ (void)cropGIFWithGifImage:(UIImage *)gifImage
             isReverseOrder:(BOOL)isReverseOrder
                       rate:(float)rate
                  maskImage:(UIImage *)maskImage
                  configure:(JPCropConfigure)configure
              compressScale:(CGFloat)compressScale
                   cacheURL:(NSURL *)cacheURL
                 errorBlock:(JPImageresizerErrorBlock)errorBlock
              completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self __cropPicture:gifImage
              imageData:nil
                  isGIF:YES
         isReverseOrder:isReverseOrder
                   rate:rate
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}

#pragma mark 裁剪GIF其中一帧（UIImage）
+ (void)cropGIFWithGifImage:(UIImage *)gifImage
                      index:(NSInteger)index
                  maskImage:(UIImage *)maskImage
                  configure:(JPCropConfigure)configure
              compressScale:(CGFloat)compressScale
                   cacheURL:(NSURL *)cacheURL
                 errorBlock:(JPImageresizerErrorBlock)errorBlock
              completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self __cropPicture:gifImage
              imageData:nil
                  isGIF:YES
         isReverseOrder:NO
                   rate:1
                  index:index
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}

#pragma mark 裁剪GIF（NSData）
+ (void)cropGIFWithGifData:(NSData *)gifData
            isReverseOrder:(BOOL)isReverseOrder
                      rate:(float)rate
                 maskImage:(UIImage *)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self __cropPicture:nil
              imageData:gifData
                  isGIF:YES
         isReverseOrder:isReverseOrder
                   rate:rate
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}

#pragma mark 裁剪GIF其中一帧（NSData）
+ (void)cropGIFWithGifData:(NSData *)gifData
                     index:(NSInteger)index
                 maskImage:(UIImage *)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropPictureDoneBlock)completeBlock {
    [self __cropPicture:nil
              imageData:gifData
                  isGIF:YES
         isReverseOrder:NO
                   rate:1
                  index:index
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}


#pragma mark - 裁剪视频

#pragma mark 裁剪视频其中一帧
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                      time:(CMTime)time
               maximumSize:(CGSize)maximumSize
                 maskImage:(UIImage *)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropPictureDoneBlock)completeBlock {
    if (!asset || compressScale <= 0) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    if (compressScale > 1) compressScale = 1;
    maximumSize = CGSizeMake(maximumSize.width * compressScale, maximumSize.height * compressScale);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        generator.maximumSize = maximumSize;
        generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:nil error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [self __cropPicture:image
                  imageData:nil
                      isGIF:NO
             isReverseOrder:NO
                       rate:1
                      index:-1
                  maskImage:maskImage
                  configure:configure
              compressScale:1
                   cacheURL:cacheURL
                 errorBlock:errorBlock
              completeBlock:completeBlock];
    });
}

#pragma mark 截取视频一小段并裁剪成GIF
+ (void)cropVideoToGIFWithAsset:(AVURLAsset *)asset
                    startSecond:(NSTimeInterval)startSecond
                       duration:(NSTimeInterval)duration
                            fps:(float)fps
                           rate:(float)rate
                    maximumSize:(CGSize)maximumSize
                      maskImage:(UIImage *)maskImage
                      configure:(JPCropConfigure)configure
                       cacheURL:(NSURL *)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                  completeBlock:(JPCropPictureDoneBlock)completeBlock {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self cropVideoToGIFWithAsset:asset
                              startSecond:startSecond
                                 duration:duration
                                      fps:fps
                                     rate:rate
                              maximumSize:maximumSize
                                maskImage:maskImage
                                configure:configure
                                 cacheURL:cacheURL
                               errorBlock:errorBlock
                            completeBlock:completeBlock];
        });
        return;
    }
    
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    if (maximumSize.width <= 0 ||
        maximumSize.height <= 0 ||
        maximumSize.width > videoTrack.naturalSize.width ||
        maximumSize.height > videoTrack.naturalSize.height) {
        maximumSize = videoTrack.naturalSize;
    }
    
    float frameRate = videoTrack.nominalFrameRate;
    if (fps <= 0 || fps > frameRate) fps = frameRate;
    
    NSTimeInterval seconds = CMTimeGetSeconds(asset.duration);
    
    if (startSecond >= seconds) {
        [self __executeCropPictureDoneBlock:completeBlock finalImage:nil cacheURL:nil isCacheSuccess:NO];
        return;
    }
    
    duration = duration * rate;
    if (startSecond < 0) startSecond = 0;
    NSTimeInterval maxSecond = startSecond + duration;
    if (maxSecond > seconds) {
        duration -= (maxSecond - seconds);
    }
    
    NSUInteger frameTotal = duration * fps;
    if (frameTotal <= 0) {
        [self __executeCropPictureDoneBlock:completeBlock finalImage:nil cacheURL:nil isCacheSuccess:NO];
        return;
    }
    
    float frameInterval = duration / (float)frameTotal;
    CMTimeScale timescale = asset.duration.timescale;
    NSMutableArray *times = [NSMutableArray array];
    for (NSInteger i = 0; i < frameTotal; i++) {
        CMTime time = CMTimeMakeWithSeconds(startSecond + i * frameInterval, timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.maximumSize = maximumSize;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    
    __block NSInteger index = 0;
    NSMutableArray *images = [NSMutableArray array];
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            [images addObject:[UIImage imageWithCGImage:imageRef]];
        }
        index += 1;
        if (index == frameTotal) {
            if (images.count) {
                if (images.count == 1) {
                    [self cropPictureWithImage:images.firstObject
                                     maskImage:maskImage
                                     configure:configure
                                 compressScale:1
                                      cacheURL:cacheURL
                                    errorBlock:errorBlock
                                 completeBlock:completeBlock];
                } else {
                    [self cropGIFWithGifImage:[UIImage animatedImageWithImages:images duration:duration]
                               isReverseOrder:NO
                                         rate:1
                                    maskImage:maskImage
                                    configure:configure
                                compressScale:1
                                     cacheURL:cacheURL
                                   errorBlock:errorBlock
                                completeBlock:completeBlock];
                }
            } else {
                [self __executeCropPictureDoneBlock:completeBlock finalImage:nil cacheURL:nil isCacheSuccess:NO];
            }
        }
    }];
}

#pragma mark 裁剪视频
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                 timeRange:(CMTimeRange)timeRange
             frameDuration:(CMTime)frameDuration
                presetName:(NSString *)presetName
                 configure:(JPCropConfigure)configure
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
                startBlock:(JPExportVideoStartBlock)startBlock
             completeBlock:(JPExportVideoCompleteBlock)completeBlock {
    if (!asset) {
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self cropVideoWithAsset:asset
                           timeRange:timeRange
                       frameDuration:frameDuration
                          presetName:presetName
                           configure:configure
                            cacheURL:cacheURL
                          errorBlock:errorBlock
                          startBlock:startBlock
                       completeBlock:completeBlock];
        });
        return;
    }
    
    // 校验缓存路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *tmpURL;
    if (cacheURL) {
        // 校验后缀
        if (!cacheURL.pathExtension.length) {
            cacheURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.mp4", cacheURL.absoluteString]];
        }
        // 判断缓存路径是否已经存在
        if ([fileManager fileExistsAtPath:cacheURL.path]) {
            [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_CacheURLAlreadyExists];
            return;
        }
        // 设置临时导出路径
        NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[cacheURL lastPathComponent]];
        tmpURL = [NSURL fileURLWithPath:tmpFilePath];
    } else {
        // 为空则设置其默认路径
        NSString *fileName = [NSString stringWithFormat:@"%.0lf.mp4", [[NSDate date] timeIntervalSince1970]];
        NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:cachePath]) {
            [fileManager removeItemAtPath:cachePath error:nil];
        }
        cacheURL = [NSURL fileURLWithPath:cachePath];
        // 设置临时导出路径
        tmpURL = cacheURL;
    }
    
    // 根据文件后缀名获取文件类型
    AVFileType fileType = [self __videoFileTypeForSuffix:cacheURL.pathExtension];
    if (!fileType) {
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NoSupportedFileType];
        return;
    }
    
    // 获取视频轨道
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!videoTrack) {
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_VideoAlreadyDamage];
        return;
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 插入音频轨道
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }
    
    // 插入视频轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    // 创建视频导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:presetName];
    if (![session.supportedFileTypes containsObject:fileType]) {
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NoSupportedFileType];
        return;
    }
    session.outputFileType = fileType;
    session.outputURL = tmpURL;
    session.shouldOptimizeForNetworkUse = YES;
    
    // 获取配置属性
    JPImageresizerRotationDirection direction = configure.direction;
    BOOL isVerMirror = configure.isVerMirror;
    BOOL isHorMirror = configure.isHorMirror;
    CGSize resizeContentSize = configure.resizeContentSize;
    CGFloat resizeWHScale = configure.resizeWHScale;
    CGRect cropFrame = configure.cropFrame;
    
    // 获取准确裁剪区域
    CGSize videoSize = videoTrack.naturalSize;
    cropFrame = JPConfirmCropFrame(cropFrame, resizeContentSize, resizeWHScale, videoSize);
    
    // 获取裁剪尺寸
    CGSize renderSize = cropFrame.size;
    // 防止绿边
    renderSize.width = floor(renderSize.width / 16.0) * 16.0;
    renderSize.height = floor(renderSize.height / 16.0) * 16.0;
    // 横竖切换
    if (direction == JPImageresizerHorizontalLeftDirection || direction == JPImageresizerHorizontalRightDirection) {
        renderSize = CGSizeMake(renderSize.height, renderSize.width);
    }
    
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    // 确定形变矩阵
    CGAffineTransform transform = JPConfirmTransform(videoSize, direction, isVerMirror, isHorMirror, NO);
    CGPoint translate = JPConfirmTranslate(cropFrame, videoSize, direction, isVerMirror, isHorMirror, NO);
    transform = CGAffineTransformTranslate(transform, translate.x, translate.y);
    [layerInstruciton setTransform:transform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *compositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    compositionInstruction.timeRange = timeRange;
    compositionInstruction.layerInstructions = @[layerInstruciton];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = @[compositionInstruction];
    videoComposition.frameDuration = frameDuration;
    videoComposition.renderScale = 1;
    videoComposition.renderSize = renderSize;
    
    session.videoComposition = videoComposition;
    
    // 开始导出
    [self __executeExportVideoStart:startBlock exportSession:session];
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = session.status;
        if (status == AVAssetExportSessionStatusCompleted) {
            if ([tmpURL isEqual:cacheURL]) {
                [self __executeExportVideoCompleteBlock:completeBlock cacheURL:cacheURL];
            } else {
                NSError *error;
                [[NSFileManager defaultManager] moveItemAtURL:tmpURL toURL:cacheURL error:&error];
                if (error) [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
                [self __executeExportVideoCompleteBlock:completeBlock cacheURL:(error ? tmpURL : cacheURL)];
            }
        } else {
            [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
            [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:(status == AVAssetExportSessionStatusCancelled ?  JPIEReason_VideoExportCancelled : JPIEReason_VideoExportFailed)];
        }
    }];
}

#pragma mark - 修正视频方向并导出
+ (void)fixOrientationVideoWithAsset:(AVURLAsset *)asset
                       fixErrorBlock:(JPImageresizerErrorBlock)fixErrorBlock
                       fixStartBlock:(JPExportVideoStartBlock)fixStartBlock
                    fixCompleteBlock:(JPExportVideoCompleteBlock)fixCompleteBlock {
    if (!asset) {
        [self __executeErrorBlock:fixErrorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fixOrientationVideoWithAsset:asset
                                 fixErrorBlock:fixErrorBlock
                                 fixStartBlock:fixStartBlock
                              fixCompleteBlock:fixCompleteBlock];
        });
        return;
    }
    
    NSURL *videoURL = asset.URL;
    CMTimeScale timescale = asset.duration.timescale;
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    // 根据文件后缀名获取文件类型
    AVFileType fileType = [self __videoFileTypeForSuffix:videoURL.pathExtension];
    if (!fileType) {
        [self __executeErrorBlock:fixErrorBlock cacheURL:nil reason:JPIEReason_NoSupportedFileType];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 为空则设置其默认路径
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"jpTmp_%@", videoURL.lastPathComponent]];
    if ([fileManager fileExistsAtPath:tmpPath]) {
        [fileManager removeItemAtPath:tmpPath error:nil];
    }
    NSURL *tmpURL = [NSURL fileURLWithPath:tmpPath];
    
    // 获取视频轨道
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!videoTrack) {
        [self __executeErrorBlock:fixErrorBlock cacheURL:nil reason:JPIEReason_VideoAlreadyDamage];
        return;
    }
    CGAffineTransform preferredTransform = videoTrack.preferredTransform;
    if (CGAffineTransformEqualToTransform(preferredTransform, CGAffineTransformIdentity)) {
        [self __executeExportVideoCompleteBlock:fixCompleteBlock cacheURL:videoURL];
        return;
    }
    CGSize renderSize = CGRectApplyAffineTransform((CGRect){CGPointZero, videoTrack.naturalSize}, preferredTransform).size;
    CMTime frameDuration = CMTimeMakeWithSeconds(1.0 / videoTrack.nominalFrameRate, timescale);
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 插入音频轨道
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }
    
    // 插入视频轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    // 创建视频导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    if (![session.supportedFileTypes containsObject:fileType]) {
        [self __executeErrorBlock:fixErrorBlock cacheURL:nil reason:JPIEReason_NoSupportedFileType];
        return;
    }
    session.outputFileType = fileType;
    session.outputURL = tmpURL;
    session.shouldOptimizeForNetworkUse = YES;
    
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [layerInstruciton setTransform:preferredTransform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *compositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    compositionInstruction.timeRange = timeRange;
    compositionInstruction.layerInstructions = @[layerInstruciton];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = @[compositionInstruction];
    videoComposition.frameDuration = frameDuration;
    videoComposition.renderScale = 1;
    videoComposition.renderSize = renderSize;
    
    session.videoComposition = videoComposition;
    
    // 开始导出
    [self __executeExportVideoStart:fixStartBlock exportSession:session];
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = session.status;
        if (status == AVAssetExportSessionStatusCompleted) {
            [self __executeExportVideoCompleteBlock:fixCompleteBlock cacheURL:tmpURL];
        } else {
            [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
            [self __executeErrorBlock:fixErrorBlock cacheURL:nil reason:(status == AVAssetExportSessionStatusCancelled ?  JPIEReason_VideoExportCancelled : JPIEReason_VideoExportFailed)];
        }
    }];
}
@end
