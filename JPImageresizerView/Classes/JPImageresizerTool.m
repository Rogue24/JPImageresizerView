//
//  JPImageresizerTool.m
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/13.
//

#import "JPImageresizerTool.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "JPImageresizer+Extension.h"
#import "JPImageresizerResult.h"

@implementation JPImageresizerTool

#pragma mark - 计算函数

static BOOL JPIsHasAlpha(CGImageRef imageRef) {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) return YES;
    return NO;
}

static BOOL JPIsSameSize(CGSize size1, CGSize size2) {
    return (fabs(size1.width - size2.width) < 0.5 && fabs(size1.height - size2.height) < 0.5);
}

static inline void JPGetGrayscaleAtPixel(const UInt8 *bytePtr, size_t byteIndex, BOOL byteOrderNormal, CGImageAlphaInfo alphaInfo, CGFloat *white, CGFloat *alpha) {
    CGFloat w = 0, a = 255.0;
    switch (alphaInfo) {
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaFirst:
        {
            if (byteOrderNormal) {
                // AW
                a = (CGFloat)bytePtr[byteIndex];
                w = (CGFloat)bytePtr[byteIndex + 1];
            } else {
                // WA
                w = (CGFloat)bytePtr[byteIndex];
                a = (CGFloat)bytePtr[byteIndex + 1];
            }
            break;
        }
            
        case kCGImageAlphaPremultipliedLast:
        case kCGImageAlphaLast:
        {
            if (byteOrderNormal) {
                // WA
                w = (CGFloat)bytePtr[byteIndex];
                a = (CGFloat)bytePtr[byteIndex + 1];
            } else {
                // AW
                a = (CGFloat)bytePtr[byteIndex];
                w = (CGFloat)bytePtr[byteIndex + 1];
            }
            break;
        }
            
        case kCGImageAlphaNone:
        {
            // W
            w = (CGFloat)bytePtr[byteIndex];
            break;
        }
            
        case kCGImageAlphaNoneSkipLast:
        {
            if (byteOrderNormal) {
                // WX
                w = (CGFloat)bytePtr[byteIndex];
            } else {
                // XW
                a = (CGFloat)bytePtr[byteIndex + 1];
            }
            break;
        }
            
        case kCGImageAlphaNoneSkipFirst:
        {
            if (byteOrderNormal) {
                // XW
                a = (CGFloat)bytePtr[byteIndex + 1];
            } else {
                // WX
                a = (CGFloat)bytePtr[byteIndex];
            }
            break;
        }
            
        case kCGImageAlphaOnly:
        {
            // A
            a = (CGFloat)bytePtr[byteIndex];
            break;
        }
            
        default:
            break;
    }
    
    if (white) *white = w;
    if (alpha) *alpha = a;
}

static void JPGetRGBAAtPixel(const UInt8 *bytePtr, size_t byteIndex, BOOL byteOrderNormal, CGImageAlphaInfo alphaInfo, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
    CGFloat r = 0, g = 0, b = 0, a = 255.0;
    switch (alphaInfo) {
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaFirst:
        {
            if (byteOrderNormal) {
                // ARGB
                a = (CGFloat)bytePtr[byteIndex];
                r = (CGFloat)bytePtr[byteIndex + 1];
                g = (CGFloat)bytePtr[byteIndex + 2];
                b = (CGFloat)bytePtr[byteIndex + 3];
            } else {
                // BGRA
                b = (CGFloat)bytePtr[byteIndex];
                g = (CGFloat)bytePtr[byteIndex + 1];
                r = (CGFloat)bytePtr[byteIndex + 2];
                a = (CGFloat)bytePtr[byteIndex + 3];
            }
            break;
        }
            
        case kCGImageAlphaPremultipliedLast:
        case kCGImageAlphaLast:
        {
            if (byteOrderNormal) {
                // RGBA
                r = (CGFloat)bytePtr[byteIndex];
                g = (CGFloat)bytePtr[byteIndex + 1];
                b = (CGFloat)bytePtr[byteIndex + 2];
                a = (CGFloat)bytePtr[byteIndex + 3];
            } else {
                // ABGR
                a = (CGFloat)bytePtr[byteIndex];
                b = (CGFloat)bytePtr[byteIndex + 1];
                g = (CGFloat)bytePtr[byteIndex + 2];
                r = (CGFloat)bytePtr[byteIndex + 3];
            }
            break;
        }
            
        case kCGImageAlphaNone:
        {
            if (byteOrderNormal) {
                // RGB
                r = (CGFloat)bytePtr[byteIndex];
                g = (CGFloat)bytePtr[byteIndex + 1];
                b = (CGFloat)bytePtr[byteIndex + 2];
            } else {
                // BGR
                b = (CGFloat)bytePtr[byteIndex];
                g = (CGFloat)bytePtr[byteIndex + 1];
                r = (CGFloat)bytePtr[byteIndex + 2];
            }
            break;
        }
            
        case kCGImageAlphaNoneSkipLast:
        {
            if (byteOrderNormal) {
                // RGBX
                r = (CGFloat)bytePtr[byteIndex];
                g = (CGFloat)bytePtr[byteIndex + 1];
                b = (CGFloat)bytePtr[byteIndex + 2];
            } else {
                // XBGR
                b = (CGFloat)bytePtr[byteIndex + 1];
                g = (CGFloat)bytePtr[byteIndex + 2];
                r = (CGFloat)bytePtr[byteIndex + 3];
            }
            break;
        }
            
        case kCGImageAlphaNoneSkipFirst:
        {
            if (byteOrderNormal) {
                // XRGB
                r = (CGFloat)bytePtr[byteIndex + 1];
                g = (CGFloat)bytePtr[byteIndex + 2];
                b = (CGFloat)bytePtr[byteIndex + 3];
            } else {
                // BGRX
                b = (CGFloat)bytePtr[byteIndex];
                g = (CGFloat)bytePtr[byteIndex + 1];
                r = (CGFloat)bytePtr[byteIndex + 2];
            }
            break;
        }
            
        case kCGImageAlphaOnly:
        {
            // A
            a = (CGFloat)bytePtr[byteIndex];
            break;
        }
            
        default:
            break;
    }
    
    if (red) *red = r;
    if (green) *green = g;
    if (blue) *blue = b;
    if (alpha) *alpha = a;
}

static CGFloat JPGetAlphaFromGrayscaleAtPixel(const UInt8 *bytePtr, size_t byteIndex, BOOL byteOrderNormal, CGImageAlphaInfo alphaInfo) {
    CGFloat a = 255.0;
    switch (alphaInfo) {
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaFirst:
        {
            if (byteOrderNormal) {
                // AW
                a = (CGFloat)bytePtr[byteIndex];
            } else {
                // WA
                a = (CGFloat)bytePtr[byteIndex + 1];
            }
            break;
        }
            
        case kCGImageAlphaPremultipliedLast:
        case kCGImageAlphaLast:
        {
            if (byteOrderNormal) {
                // WA
                a = (CGFloat)bytePtr[byteIndex + 1];
            } else {
                // AW
                a = (CGFloat)bytePtr[byteIndex];
            }
            break;
        }
            
        case kCGImageAlphaNone: // W
            break;
            
        case kCGImageAlphaNoneSkipLast:
        {
            if (!byteOrderNormal) {
                // XW
                a = (CGFloat)bytePtr[byteIndex + 1];
            }
            break;
        }
            
        case kCGImageAlphaNoneSkipFirst:
        {
            if (byteOrderNormal) {
                // XW
                a = (CGFloat)bytePtr[byteIndex + 1];
            } else {
                // WX
                a = (CGFloat)bytePtr[byteIndex];
            }
            break;
        }
            
        case kCGImageAlphaOnly:
        {
            // A
            a = (CGFloat)bytePtr[byteIndex];
            break;
        }
            
        default:
            break;
    }
    
    return a;
}

static CGFloat JPGetAlphaFromRGBAAtPixel(const UInt8 *bytePtr, size_t byteIndex, BOOL byteOrderNormal, CGImageAlphaInfo alphaInfo) {
    CGFloat a = 255.0;
    switch (alphaInfo) {
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaFirst:
        {
            if (byteOrderNormal) {
                // ARGB
                a = (CGFloat)bytePtr[byteIndex];
            } else {
                // BGRA
                a = (CGFloat)bytePtr[byteIndex + 3];
            }
            break;
        }
            
        case kCGImageAlphaPremultipliedLast:
        case kCGImageAlphaLast:
        {
            if (byteOrderNormal) {
                // RGBA
                a = (CGFloat)bytePtr[byteIndex + 3];
            } else {
                // ABGR
                a = (CGFloat)bytePtr[byteIndex];
            }
            break;
        }
            
        case kCGImageAlphaNone:
        case kCGImageAlphaNoneSkipLast:
        case kCGImageAlphaNoneSkipFirst:
            break;
            
        case kCGImageAlphaOnly:
        {
            // A
            a = (CGFloat)bytePtr[byteIndex];
            break;
        }
            
        default:
            break;
    }
    
    return a;
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

static CGImageRef _Nullable JPCreateNewCGImage(CGImageRef imageRef, CGContextRef context, UIImage *maskImage, BOOL isRoundClip, CGRect renderRect, CGAffineTransform transform, CGSize imageSize) {
    if (!imageRef || !context) {
        return NULL;
    }
    
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
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    if (!newImageRef) {
        return NULL;
    }
    return newImageRef;
}

static void JPDrawOutlineStroke(CGImageRef imageRef, CGContextRef context, size_t outlineStrokeWidth, CGColorRef outlineStrokeColor, CGFloat diffX, CGFloat diffY) {
    if (!imageRef || !context) {
        return;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return;
    
    // 每一行的总字节数
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    if (bytesPerRow == 0) return;
    
    // 每个像素包含的颜色通道数 = 一个像素的总位数 / 每个颜色通道使用的位数
    // 在32位像素格式下，每个颜色通道固定占8位，所以算出的「每个像素包含的颜色通道数」相当于「每个像素占用的字节数」
    size_t components = CGImageGetBitsPerPixel(imageRef) / CGImageGetBitsPerComponent(imageRef);
    // greyscale有2个，RGB有3个，RGBA有4个，其他则是无法识别的颜色空间了
    if (components != 2 && components != 3 && components != 4) return;
    
    // 获取指向图像对象的字节数据的指针
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    if (!dataProvider) return;
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    if (!data) return;
    const UInt8 *bytePtr = CFDataGetBytePtr(data);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    // 获取透明信息
    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
    // 获取字节排序（大端or小端）
    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
    BOOL byteOrderNormal = NO;
    switch (byteOrderInfo) {
        case kCGBitmapByteOrderDefault:
        case kCGBitmapByteOrder32Big:
            byteOrderNormal = YES;
            break;
        default:
            break;
    }
    
    // 渲染一个像素的大小：以像素点为中点，线宽为外边距，向外扩展
    CGFloat fillWH = (CGFloat)outlineStrokeWidth + 1 + (CGFloat)outlineStrokeWidth;
    /**
     * 🌰🌰🌰 其中🟩为像素点，🟦为`outlineStrokeWidth`，
     * 假设`outlineStrokeWidth = 2`，那么渲染的大小为：
         🟦 🟦 🟦 🟦 🟦
         🟦 🟦 🟦 🟦 🟦
         🟦 🟦 🟩 🟦 🟦
         🟦 🟦 🟦 🟦 🟦
         🟦 🟦 🟦 🟦 🟦
     */
    
    // 渲染所有非透明的像素点
    CGContextSetFillColorWithColor(context, outlineStrokeColor);
    for (size_t x = 0; x < width; x++) {
        for (size_t y = 0; y < height; y++) {
            // 像素下标 = 第几行 * 每一行的总字节数 + 第几列 * 每个像素占用的字节数
            size_t byteIndex = y * bytesPerRow + x * components;
            
            // 获取透明度
//            CGFloat alpha = ((CGFloat)bytePtr[byteIndex + 3]) / 255.0;
            CGFloat alpha = 255.0;
            if (components == 2) { // greyscale
                alpha = JPGetAlphaFromGrayscaleAtPixel(bytePtr, byteIndex, byteOrderNormal, alphaInfo);
            } else if (components == 3 || components == 4) { // RGB || RGBA
                alpha = JPGetAlphaFromRGBAAtPixel(bytePtr, byteIndex, byteOrderNormal, alphaInfo);
            }
            alpha /= 255.0;
            
            // 非透明的地方就涂色（注意：这里的xy是基于图像的坐标，需要适配成context的坐标进行填充）
            if (alpha > 0.1) { // 透明度0.1以下人眼【几乎】看不见，直接忽略吧
                CGFloat fillX = (CGFloat)x - (CGFloat)outlineStrokeWidth;
                
                CGFloat fillY = (CGFloat)y - (CGFloat)outlineStrokeWidth;
                // 此处的y轴跟UIKit的上下颠倒，y = h - maxY
                CGFloat fillMaxY = fillY + fillWH;
                fillY = (CGFloat)height - fillMaxY;
                
                fillX += diffX;
                fillY += diffY;
                
                CGContextFillRect(context, CGRectMake(fillX, fillY, fillWH, fillWH));
            }
        }
    }
    
    // 释放内存
    CFRelease(data);
}

static CGImageRef _Nullable JPProcessImage(CGImageRef imageRef, size_t cornerRadius, CGColorRef backgroundColor, size_t borderWidth, CGColorRef borderColor, size_t outlineStrokeWidth, CGColorRef outlineStrokeColor, UIEdgeInsets padding, BOOL isOnlyDrawOutline) {
    if (!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL;
    
    // 优化计算：取整
    cornerRadius = floor(cornerRadius);
    borderWidth = floor(borderWidth);
    outlineStrokeWidth = floor(outlineStrokeWidth);
    padding = UIEdgeInsetsMake(floor(padding.top), floor(padding.left), floor(padding.bottom), floor(padding.right));
    
    size_t renderWidth = borderWidth + padding.left + width + padding.right + borderWidth;
    size_t renderHeight = borderWidth + padding.top + height + padding.bottom + borderWidth;
    
    BOOL isHasAlpha = JPIsHasAlpha(imageRef);
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    if (!isHasAlpha && cornerRadius > 0) {
        bitmapInfo = kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 renderWidth,
                                                 renderHeight,
                                                 bitsPerComponent,
                                                 0, // 这里不能用CGImageGetBytesPerRow(imageRef)，
                                                 // →→ 因为`renderWidth`跟`width`可能不一样，
                                                 // →→ 要么重新计算`(renderWidth * 4)`、要么传0交给系统自动计算。
                                                 colorSpace,
                                                 bitmapInfo);
    if (!context) return NULL;
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGFloat diffX = borderWidth + padding.left;
    CGFloat diffY = borderWidth + padding.bottom; // 此处的y轴跟UIKit的上下颠倒，所以是bottom
    
    // 0.生成绘制路径
    CGRect renderRect = CGRectMake(0, 0, renderWidth, renderHeight);
    UIBezierPath *renderPath = [UIBezierPath bezierPathWithRoundedRect:renderRect cornerRadius:cornerRadius];
    
    // JP_Test：用于查看边距设置是否正确
//    CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
//    CGContextFillRect(context, renderRect);
//    CGContextSetFillColorWithColor(context, UIColor.yellowColor.CGColor);
//    CGContextFillRect(context, CGRectMake(diffX, diffY, width, height));
    
    // 1.裁剪圆角
    if (cornerRadius > 0) {
        CGContextAddPath(context, renderPath.CGPath);
        CGContextClip(context);
    }
    
    // 2.填充背景色
    if (backgroundColor) {
        CGContextSetFillColorWithColor(context, backgroundColor);
        CGContextFillRect(context, renderRect);
    }
    
    // 3.给图像内容添加轮廓描边（填充非透明部分）
    if (outlineStrokeColor && (outlineStrokeWidth > 0 || isOnlyDrawOutline)) {
        if (isHasAlpha) {
            JPDrawOutlineStroke(imageRef, context, outlineStrokeWidth, outlineStrokeColor, diffX, diffY);
        } else {
            CGContextSetFillColorWithColor(context, outlineStrokeColor);
            CGFloat fillX = diffX - (CGFloat)outlineStrokeWidth;
            CGFloat fillY = diffY - (CGFloat)outlineStrokeWidth;
            CGFloat fillW = (CGFloat)(outlineStrokeWidth + width + outlineStrokeWidth);
            CGFloat fillH = (CGFloat)(outlineStrokeWidth + height + outlineStrokeWidth);
            CGContextFillRect(context, CGRectMake(fillX, fillY, fillW, fillH));
        }
    }
    
    // 4.绘制原图像（盖在轮廓描边上）
    if (!isOnlyDrawOutline) {
        CGContextDrawImage(context, CGRectMake(diffX, diffY, width, height), imageRef);
    }
    
    // 5.绘制边框
    if (borderWidth > 0 && borderColor) {
        CGContextAddPath(context, renderPath.CGPath);
        CGContextSetStrokeColorWithColor(context, borderColor);
        CGContextSetLineWidth(context, borderWidth * 2);
        CGContextStrokePath(context);
    }
    
    // 6.取出新图像
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    
    // 7.释放内存
    CGContextRelease(context);
    
    if (!newImageRef) {
        return NULL;
    }
    return newImageRef;
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
    if (!ctx) return image;
    
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
    UIImage *img = image;
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    if (cgimg) {
        img = [UIImage imageWithCGImage:cgimg];
        CGImageRelease(cgimg);
    }
    CGContextRelease(ctx);
    return img;
}

#pragma mark 执行回调的Block
+ (void)__executeErrorBlock:(JPImageresizerErrorBlock)block cacheURL:(NSURL *)cacheURL reason:(JPImageresizerErrorReason)reason {
    if (!block) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        block(cacheURL, reason);
    });
}
+ (void)__executeCropDoneBlock:(JPCropDoneBlock)block image:(UIImage *)image cacheURL:(NSURL *)cacheURL {
    if (!block) return;
    JPImageresizerResult *result = [[JPImageresizerResult alloc] initWithImage:image cacheURL:cacheURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(result);
    });
}
+ (void)__executeCropDoneBlock:(JPCropDoneBlock)block gifImage:(UIImage *)gifImage cacheURL:(NSURL *)cacheURL {
    if (!block) return;
    JPImageresizerResult *result = [[JPImageresizerResult alloc] initWithGifImage:gifImage cacheURL:cacheURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(result);
    });
}
+ (void)__executeCropDoneBlock:(JPCropDoneBlock)block videoCacheURL:(NSURL *)videoCacheURL {
    if (!block) return;
    JPImageresizerResult *result = [[JPImageresizerResult alloc] initWithVideoCacheURL:videoCacheURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(result);
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

#pragma mark 修正图片/GIF缓存路径的后缀名
+ (NSURL *)__fixExtensionForImageCacheURL:(NSURL *)cacheURL
                                    isGIF:(BOOL)isGIF
                                 hasAlpha:(BOOL)hasAlpha
                                imageData:(NSData *)imageData {
    NSString *extension;
    if (isGIF) {
        extension = @"gif";
    } else if (hasAlpha) {
        extension = @"png";
    } else if (imageData != nil) {
        extension = [self __contentTypeSuffixForImageData:imageData];
        if ([extension isEqualToString:@"gif"]) extension = hasAlpha ? @"png" : @"jpeg";
    } else {
        extension = @"jpeg";
    }
    
    NSString *pathExtension = cacheURL.pathExtension;
    if (!pathExtension.length) {
        cacheURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", cacheURL.absoluteString, extension]];
    }
    else if (![extension isEqualToString:pathExtension]) {
        cacheURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", cacheURL.jpir_filePathWithoutExtension, extension]];
    }
    
    return cacheURL;
}

#pragma mark 缓存图片
+ (BOOL)__cacheImage:(UIImage *)image cacheURL:(NSURL *)cacheURL {
    if (!cacheURL || !image) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cacheURL.path]) {
        [fileManager removeItemAtURL:cacheURL error:nil];
    }
    
    CGFloat quality;
    CFStringRef imageType = [self __contentTypeForSuffix:cacheURL.pathExtension quality:&quality];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)cacheURL, imageType, 1, NULL);
    if (destination == NULL) return NO;
    
    NSDictionary *frameProperty = @{(id)kCGImageDestinationLossyCompressionQuality: @(quality)};
    CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)frameProperty);
    
    BOOL isCacheSuccess = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    if (!isCacheSuccess) [fileManager removeItemAtURL:cacheURL error:nil];
    return isCacheSuccess;
}

#pragma mark 缓存GIF文件
+ (BOOL)__cacheGIF:(NSArray<UIImage *> *)images delays:(NSArray *)delays cacheURL:(NSURL *)cacheURL {
    if (!cacheURL || images.count == 0) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cacheURL.path]) {
        [fileManager removeItemAtURL:cacheURL error:nil];
    }
    
    size_t count = images.count;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)cacheURL, kUTTypeGIF, count, NULL);
    if (destination == NULL) return NO;
    
    NSDictionary *gifProperty =
    @{
        (__bridge id)kCGImagePropertyGIFDictionary:
          @{(__bridge id)kCGImagePropertyGIFHasGlobalColorMap: @YES,
            (__bridge id)kCGImagePropertyColorModel: (NSString *)kCGImagePropertyColorModelRGB,
            (__bridge id)kCGImagePropertyDepth: @8,
            (__bridge id)kCGImagePropertyGIFLoopCount: @0}
    };
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
    if (!isCacheSuccess) [fileManager removeItemAtURL:cacheURL error:nil];
    return isCacheSuccess;
}

#pragma mark 裁剪图片&GIF
+ (void)__cropPicture:(UIImage *)image
            imageData:(NSData *)imageData
           isCropGird:(BOOL)isCropGird
                isGIF:(BOOL)isGIF
       isReverseOrder:(BOOL)isReverseOrder
                 rate:(float)rate
                index:(NSInteger)index // -1 代表裁剪整个Gif全部
            maskImage:(UIImage *)maskImage
            configure:(JPCropConfigure)configure
        compressScale:(CGFloat)compressScale
        otherSettings:(JPImageProcessingSettings *)settings
             cacheURL:(NSURL *)cacheURL
           errorBlock:(JPImageresizerErrorBlock)errorBlock
        completeBlock:(JPCropDoneBlock)completeBlock {
    
    if ((!image && !imageData) || compressScale <= 0) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self __cropPicture:image
                      imageData:imageData
                     isCropGird:isCropGird
                          isGIF:isGIF
                 isReverseOrder:isReverseOrder
                           rate:rate
                          index:index
                      maskImage:maskImage
                      configure:configure
                  compressScale:compressScale
                  otherSettings:settings
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
    
    CGImageRef imageRef = image.CGImage;
    
    // 是否带透明度
    BOOL hasAlpha = NO;
    if (maskImage || isRoundClip) {
        hasAlpha = YES;
    } else {
        hasAlpha = JPIsHasAlpha(imageRef);
    }
    
    if (cacheURL) {
        cacheURL = [self __fixExtensionForImageCacheURL:cacheURL
                                                  isGIF:(isGIF && index < 0)
                                               hasAlpha:hasAlpha
                                              imageData:imageData];
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
        compressScale == 1 &&
        (settings == nil || settings.isNeedProcessing == NO)) {
        if (cacheURL) {
            if (imageData) {
                BOOL isCacheSuccess = [imageData writeToURL:cacheURL atomically:YES];
                if (!isCacheSuccess) [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
            } else {
                if (isGIF) {
                    NSUInteger count = image.images.count;
                    NSTimeInterval duration = image.duration;
                    NSTimeInterval delay = duration / (NSTimeInterval)count;
                    if (delay < 0.02) delay = 0.1;
                    [self __cacheGIF:image.images delays:@[@(delay)] cacheURL:cacheURL];
                } else {
                    [self __cacheImage:image cacheURL:cacheURL];
                }
            }
        }
        if (isGIF) {
            [self __executeCropDoneBlock:completeBlock gifImage:image cacheURL:cacheURL];
        } else {
            // 修正方向再抛出
            image = [self __imageFixOrientation:image];
            if (isCropGird) {
                if (!completeBlock) return;
                JPImageresizerResult *result = [[JPImageresizerResult alloc] initWithImage:image cacheURL:cacheURL];
                completeBlock(result);
            } else {
                [self __executeCropDoneBlock:completeBlock image:image cacheURL:cacheURL];
            }
        }
        return;
    }
    
    CGImageSourceRef source = NULL;
    size_t count = 1;
    if (isGIF) {
        isGIF = index < 0;
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
    
    // 优化计算：宽高取整（可能会导致0.x的误差，如果不能接受就注释吧）
    imageSize = CGSizeMake(floor(imageSize.width), floor(imageSize.height));
    renderRect.size = CGSizeMake(floor(renderRect.size.width), floor(renderRect.size.height));
    
    CGContextRef context = CGBitmapContextCreate(NULL, renderRect.size.width, renderRect.size.height, 8, 0, colorSpace, bitmapInfo);
    if (!context) {
        if (source != NULL) CFRelease(source);
        CGColorSpaceRelease(colorSpace);
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    UIImage *finalImage;
    if (isGIF) {
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
                      otherSettings:settings
                           cacheURL:cacheURL
                         finalImage:&finalImage];
    } else {
        CGImageRef newImageRef = JPCreateNewCGImage(imageRef, context, maskImage, isRoundClip, renderRect, transform, imageSize);
        if (source != NULL) {
            CGImageRelease(imageRef);
        }
        
        if (newImageRef) {
            finalImage = [UIImage imageWithCGImage:newImageRef];
            CGImageRelease(newImageRef);
            [self __cacheImage:finalImage cacheURL:cacheURL];
        }
    }
    
    if (source != NULL) CFRelease(source);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if (!finalImage) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if (isGIF) {
        [self __executeCropDoneBlock:completeBlock gifImage:finalImage cacheURL:cacheURL];
    } else {
        if (isCropGird) {
            if (!completeBlock) return;
            JPImageresizerResult *result = [[JPImageresizerResult alloc] initWithImage:finalImage cacheURL:cacheURL];
            completeBlock(result);
        } else {
            [self __executeCropDoneBlock:completeBlock image:finalImage cacheURL:cacheURL];
        }
    }
}

#pragma mark 裁剪N宫格图片（在子线程调起）
+ (void)__cropGirdPicturesWithOriginResult:(JPImageresizerResult *)originResult
                               columnCount:(NSInteger)columnCount
                                  rowCount:(NSInteger)rowCount
                                   bgColor:(UIColor *)bgColor
                             completeBlock:(JPCropNGirdDoneBlock)completeBlock {
    if (columnCount <= 0) columnCount = 1;
    if (rowCount <= 0) rowCount = 1;
    
    if (!originResult) {
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(nil, nil, columnCount, rowCount);
            });
        }
        return;
    }
    
    NSInteger total = columnCount * rowCount;
    if (total == 1) {
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(originResult, @[], columnCount, rowCount);
            });
        }
        return;
    }
    
    CGImageRef imageRef = originResult.image.CGImage;
    CGFloat imageWidth = CGImageGetWidth(imageRef);
    CGFloat imageHeight = CGImageGetHeight(imageRef);
    CGFloat renderWidth = imageWidth / (CGFloat)columnCount;
    CGFloat renderHeight = imageHeight / (CGFloat)rowCount;
    CGRect renderRect = CGRectMake(0, 0, renderWidth, renderHeight);
    
    BOOL hasAlpha = NO;
    if (bgColor && ![bgColor isEqual:UIColor.clearColor]) {
        hasAlpha = NO;
    } else {
        hasAlpha = JPIsHasAlpha(imageRef);
    }
    if (!bgColor && hasAlpha) {
        bgColor = UIColor.clearColor;
    }
    
    NSString *cacheFilePath;
    NSString *cacheExtension;
    if (originResult.isCacheSuccess) {
        NSURL *fixedCacheURL = [self __fixExtensionForImageCacheURL:originResult.cacheURL isGIF:NO hasAlpha:hasAlpha imageData:nil];
        cacheFilePath = fixedCacheURL.jpir_filePathWithoutExtension;
        cacheExtension = fixedCacheURL.pathExtension;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, renderWidth, renderHeight, 8, 0, colorSpace, bitmapInfo);
    if (!context) {
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(originResult, @[], columnCount, rowCount);
            });
        }
        return;
    }
    
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    NSMutableArray<JPImageresizerResult *> *fragmentsResults = [NSMutableArray array];
    NSInteger lastIndex = total - 1;
    for (NSInteger i = 0; i < total; i++) {
        @autoreleasepool {
            CGContextSaveGState(context);
            
            if (bgColor) {
                CGContextSetFillColorWithColor(context, bgColor.CGColor);
                CGContextFillRect(context, renderRect);
            }
            
            // 从左上角开始裁剪：从左往右，从上而下
            CGFloat x = -renderWidth * (i % columnCount);
            CGFloat y = -renderHeight * ((lastIndex - i) / columnCount); // CoreGraphics的坐标系y轴是从底部开始的，所以y从最后一个开始算起
            
            CGContextDrawImage(context, CGRectMake(x, y, imageWidth, imageHeight), imageRef);
            CGImageRef singleCGImage = CGBitmapContextCreateImage(context);
            UIImage *singleImage = [UIImage imageWithCGImage:singleCGImage];
            
            NSURL *singleCacheURL;
            if (originResult.isCacheSuccess) {
                singleCacheURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_%zd.%@", cacheFilePath, i, cacheExtension]];
                [self __cacheImage:singleImage cacheURL:singleCacheURL];
            }
            
            JPImageresizerResult *singleResult = [[JPImageresizerResult alloc] initWithImage:singleImage cacheURL:singleCacheURL];
            [fragmentsResults addObject:singleResult];
            
            if (singleCGImage) CGImageRelease(singleCGImage);
            CGContextRestoreGState(context);
            CGContextClearRect(context, renderRect);
        }
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if (completeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(originResult, fragmentsResults, columnCount, rowCount);
        });
    }
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
                otherSettings:(JPImageProcessingSettings *)settings
                     cacheURL:(NSURL *)cacheURL
                   finalImage:(UIImage **)finalImage {
    if (!image || !context) return;
    
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
    
    BOOL isNeedProcessing = settings && settings.isNeedProcessing;
    
    NSMutableArray *images = [NSMutableArray array];
    void (^createNewImageRef)(size_t i) = ^(size_t i) {
        @autoreleasepool {
            // 将当前图形状态推入堆栈
            CGContextSaveGState(context);
            
            // 绘制裁剪后的图片
            CGImageRef imageRef = getCurrentImageRef(i);
            CGImageRef newImageRef = JPCreateNewCGImage(imageRef, context, maskImage, isRoundClip, renderRect, transform, imageSize);
            if (source != NULL) {
                CGImageRelease(imageRef);
            }
            
            // 图片额外加工
            if (newImageRef && isNeedProcessing) {
                CGImageRef processedImageRef = JPProcessImage(newImageRef,
                                                              settings.cornerRadius,
                                                              settings.backgroundColor.CGColor,
                                                              settings.borderWidth,
                                                              settings.borderColor.CGColor,
                                                              settings.outlineStrokeWidth,
                                                              settings.outlineStrokeColor.CGColor,
                                                              settings.padding,
                                                              settings.isOnlyDrawOutline);
                if (processedImageRef) {
                    CGImageRelease(newImageRef);
                    newImageRef = processedImageRef;
                }
            }
            
            if (newImageRef) {
                UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
                [images addObject:newImage];
                CGImageRelease(newImageRef);
            }
            
            // 把堆栈顶部的状态弹出，返回到之前的图形状态
            CGContextRestoreGState(context);
            // 清空画布（要在`RestoreGState`之后才清空，否则清空区域会受到`transform`的影响，导致清理不干净）
            CGContextClearRect(context, renderRect);
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
    
    [self __cacheGIF:images delays:delays cacheURL:cacheURL];
    if (finalImage) *finalImage = images.count > 1 ? [UIImage animatedImageWithImages:images duration:duration] : images.firstObject;
}

#pragma mark - 公开方法

#pragma mark 转换成黑色轮廓的图片（镂空图片区域：透明->黑色+不透明->透明）
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

#pragma mark 是否为GIF
+ (BOOL)isGIFData:(NSData *)data {
    if (!data) return NO;
    uint8_t c;
    [data getBytes:&c length:1];
    return c == 0x47;
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
            CGImageRelease(imageRef);
            return nil;
        }
        
        BOOL hasAlpha = JPIsHasAlpha(imageRef);
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
        CGColorSpaceRelease(space);
        if (!context) {
            CFRelease(source);
            CGImageRelease(imageRef);
            return nil;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef decoded = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        if (!decoded) {
            CFRelease(source);
            CGImageRelease(imageRef);
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

#pragma mark - 裁剪图片

#pragma mark 裁剪图片（UIImage）
+ (void)cropPictureWithImage:(UIImage *)image
                   maskImage:(UIImage *)maskImage
                   configure:(JPCropConfigure)configure
               compressScale:(CGFloat)compressScale
                    cacheURL:(NSURL *)cacheURL
                  errorBlock:(JPImageresizerErrorBlock)errorBlock
               completeBlock:(JPCropDoneBlock)completeBlock {
    [self __cropPicture:image
              imageData:nil
             isCropGird:NO
                  isGIF:NO
         isReverseOrder:NO
                   rate:1
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
          otherSettings:nil
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
                   completeBlock:(JPCropDoneBlock)completeBlock {
    [self __cropPicture:nil
              imageData:imageData
             isCropGird:NO
                  isGIF:NO
         isReverseOrder:NO
                   rate:1
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
          otherSettings:nil
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}

#pragma mark 裁剪N宫格图片（UIImage）
+ (void)cropGirdPicturesWithImage:(UIImage *)image
                      columnCount:(NSInteger)columnCount
                         rowCount:(NSInteger)rowCount
                          bgColor:(UIColor *)bgColor
                        maskImage:(UIImage *)maskImage
                        configure:(JPCropConfigure)configure
                    compressScale:(CGFloat)compressScale
                         cacheURL:(NSURL *)cacheURL
                       errorBlock:(JPImageresizerErrorBlock)errorBlock
                    completeBlock:(JPCropNGirdDoneBlock)completeBlock {
    [self __cropPicture:image
              imageData:nil
             isCropGird:YES
                  isGIF:NO
         isReverseOrder:NO
                   rate:1
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
          otherSettings:nil
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:^(JPImageresizerResult *result) {
        [self __cropGirdPicturesWithOriginResult:result
                                     columnCount:columnCount
                                        rowCount:rowCount
                                         bgColor:bgColor
                                   completeBlock:completeBlock];
    }];
}

#pragma mark 裁剪N宫格图片（NSData）
+ (void)cropGirdPicturesWithImageData:(NSData *)imageData
                          columnCount:(NSInteger)columnCount
                             rowCount:(NSInteger)rowCount
                              bgColor:(UIColor *)bgColor
                            maskImage:(UIImage *)maskImage
                            configure:(JPCropConfigure)configure
                        compressScale:(CGFloat)compressScale
                             cacheURL:(NSURL *)cacheURL
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
                        completeBlock:(JPCropNGirdDoneBlock)completeBlock {
    [self __cropPicture:nil
              imageData:imageData
             isCropGird:YES
                  isGIF:NO
         isReverseOrder:NO
                   rate:1
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale 
          otherSettings:nil
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:^(JPImageresizerResult *result) {
        [self __cropGirdPicturesWithOriginResult:result
                                     columnCount:columnCount
                                        rowCount:rowCount
                                         bgColor:bgColor
                                   completeBlock:completeBlock];
    }];
}

#pragma mark - 裁剪GIF

#pragma mark 裁剪GIF（UIImage）
+ (void)cropGIFWithGifImage:(UIImage *)gifImage
             isReverseOrder:(BOOL)isReverseOrder
                       rate:(float)rate
                  maskImage:(UIImage *)maskImage
                  configure:(JPCropConfigure)configure
              compressScale:(CGFloat)compressScale
              otherSettings:(JPImageProcessingSettings *)settings
                   cacheURL:(NSURL *)cacheURL
                 errorBlock:(JPImageresizerErrorBlock)errorBlock
              completeBlock:(JPCropDoneBlock)completeBlock {
    [self __cropPicture:gifImage
              imageData:nil
             isCropGird:NO
                  isGIF:YES
         isReverseOrder:isReverseOrder
                   rate:rate
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
          otherSettings:settings
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
              completeBlock:(JPCropDoneBlock)completeBlock {
    [self __cropPicture:gifImage
              imageData:nil
             isCropGird:NO
                  isGIF:YES
         isReverseOrder:NO
                   rate:1
                  index:index
              maskImage:maskImage
              configure:configure
          compressScale:compressScale 
          otherSettings:nil
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
             otherSettings:(JPImageProcessingSettings *)settings
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropDoneBlock)completeBlock {
    [self __cropPicture:nil
              imageData:gifData
             isCropGird:NO
                  isGIF:YES
         isReverseOrder:isReverseOrder
                   rate:rate
                  index:-1
              maskImage:maskImage
              configure:configure
          compressScale:compressScale
          otherSettings:settings
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
             completeBlock:(JPCropDoneBlock)completeBlock {
    [self __cropPicture:nil
              imageData:gifData
             isCropGird:NO
                  isGIF:YES
         isReverseOrder:NO
                   rate:1
                  index:index
              maskImage:maskImage
              configure:configure
          compressScale:compressScale 
          otherSettings:nil
               cacheURL:cacheURL
             errorBlock:errorBlock
          completeBlock:completeBlock];
}


#pragma mark - 裁剪视频

#pragma mark 裁剪视频其中一帧
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                  atSecond:(NSTimeInterval)second
                 maskImage:(UIImage *)maskImage
                 configure:(JPCropConfigure)configure
             compressScale:(CGFloat)compressScale
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
             completeBlock:(JPCropDoneBlock)completeBlock {
    if (!asset || compressScale <= 0) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        CGSize videoSize = videoTrack.naturalSize;
        
        CGFloat scale = compressScale > 1 ? 1 : compressScale;
        CGSize maximumSize = CGSizeMake(videoSize.width * scale, videoSize.height * scale);
        CMTime toleranceTime = CMTimeMake(0, asset.duration.timescale);
        
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        generator.maximumSize = maximumSize;
        generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceAfter = toleranceTime;
        generator.requestedTimeToleranceBefore = toleranceTime;
        
        CMTime time = CMTimeMakeWithSeconds(second, asset.duration.timescale);
        CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:nil error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        [self __cropPicture:image
                  imageData:nil
                 isCropGird:NO
                      isGIF:NO
             isReverseOrder:NO
                       rate:1
                      index:-1
                  maskImage:maskImage
                  configure:configure
              compressScale:1
              otherSettings:nil
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
                  completeBlock:(JPCropDoneBlock)completeBlock {
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
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NilObject];
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
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NilObject];
        return;
    }
    
    float frameInterval = duration / (float)frameTotal;
    CMTimeScale timescale = asset.duration.timescale;
    CMTime toleranceTime = CMTimeMake(0, timescale);
    
    NSMutableArray *times = [NSMutableArray array];
    for (NSInteger i = 0; i < frameTotal; i++) {
        CMTime time = CMTimeMakeWithSeconds(startSecond + i * frameInterval, timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.maximumSize = maximumSize;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceAfter = toleranceTime;
    generator.requestedTimeToleranceBefore = toleranceTime;
    
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
                                otherSettings:nil
                                     cacheURL:cacheURL
                                   errorBlock:errorBlock
                                completeBlock:completeBlock];
                }
            } else {
                [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NilObject];
            }
        }
    }];
}

#pragma mark 裁剪视频
+ (void)cropVideoWithAsset:(AVURLAsset *)asset
                presetName:(NSString *)presetName
                 configure:(JPCropConfigure)configure
                  cacheURL:(NSURL *)cacheURL
                errorBlock:(JPImageresizerErrorBlock)errorBlock
                startBlock:(JPExportVideoStartBlock)startBlock
             completeBlock:(JPCropDoneBlock)completeBlock {
    if (!asset) {
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self cropVideoWithAsset:asset
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
    
    CMTimeScale timescale = asset.duration.timescale;
    CMTime frameDuration = CMTimeMakeWithSeconds(1.0 / videoTrack.nominalFrameRate, timescale);
    CMTime zeroTime = CMTimeMake(0, timescale);
    CMTimeRange timeRange = CMTimeRangeMake(zeroTime, asset.duration);
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 插入音频轨道
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVMutableAudioMix *audioMix;
    if (audioTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:zeroTime error:nil];
        
        AVMutableAudioMixInputParameters *inputParameter = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack: audioCompositionTrack];
        [inputParameter setVolume:1 atTime:zeroTime];
        
        audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = @[inputParameter];
    }
    
    // 插入视频轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:zeroTime error:nil];
    
    // 创建视频导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:presetName];
    if (![session.supportedFileTypes containsObject:fileType]) {
        [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_NoSupportedFileType];
        return;
    }
    session.outputFileType = fileType;
    session.outputURL = tmpURL;
    session.shouldOptimizeForNetworkUse = YES;
    session.audioMix = audioMix;
    
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
    [layerInstruciton setTransform:transform atTime:zeroTime];
    
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
                [self __executeCropDoneBlock:completeBlock videoCacheURL:cacheURL];
            } else {
                NSError *error;
                [[NSFileManager defaultManager] moveItemAtURL:tmpURL toURL:cacheURL error:&error];
                if (error) [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
                [self __executeCropDoneBlock:completeBlock videoCacheURL:(error ? tmpURL : cacheURL)];
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
    
    CMTimeScale timescale = asset.duration.timescale;
    CMTime zeroTime = CMTimeMake(0, timescale);
    CMTimeRange timeRange = CMTimeRangeMake(zeroTime, asset.duration);
    
    // 获取视频修正方向（默认为摄像头方向）
    // preferredTransform：摄像头方向 -需要修改-> 屏幕方向 的transform
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
    AVMutableAudioMix *audioMix;
    if (audioTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:zeroTime error:nil];
        
        AVMutableAudioMixInputParameters *inputParameter = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack: audioCompositionTrack];
        [inputParameter setVolume:1 atTime:zeroTime];
        
        audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = @[inputParameter];
    }
    
    // 插入视频轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:zeroTime error:nil];
    
    // 创建视频导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    if (![session.supportedFileTypes containsObject:fileType]) {
        [self __executeErrorBlock:fixErrorBlock cacheURL:nil reason:JPIEReason_NoSupportedFileType];
        return;
    }
    session.outputFileType = fileType;
    session.outputURL = tmpURL;
    session.shouldOptimizeForNetworkUse = YES;
    session.audioMix = audioMix;
    
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    
    // 直接使用 preferredTransform 只能旋转角度，视频画面旋转后会在裁剪区域外面，因此旋转后还得进行位移
    CGFloat radian = atan2f(preferredTransform.b, preferredTransform.a);
    CGFloat angle = (radian * 180.0) / M_PI;
    // 获取旋转方向，换算成CGFloat会有些许误差，这里做范围差值判断：-0.1 ~ +0.1
    JPImageresizerRotationDirection dircetion = JPImageresizerVerticalUpDirection;
    if ((angle >= 89.9 && angle <= 90.1) ||
        (angle <= -269.9 && angle >= -270.1)) {
        dircetion = JPImageresizerHorizontalRightDirection;
    }
    else if ((angle >= 179.9 && angle <= 180.1) ||
             (angle <= -179.9 && angle >= -180.1)) {
        dircetion = JPImageresizerVerticalDownDirection;
    }
    else if ((angle >= 269.9 && angle <= 270.1) ||
             (angle <= -89.9 && angle >= -90.1)) {
        dircetion = JPImageresizerHorizontalLeftDirection;
    }
    // 获取完整的transform
    CGAffineTransform transform = JPConfirmTransform(videoTrack.naturalSize, dircetion, NO, NO, NO);
    [layerInstruciton setTransform:transform atTime:zeroTime];
    
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






#pragma mark - 给图像内容添加轮廓描边
+ (void)processImageWithImageData:(NSData *)imageData
                         settings:(JPImageProcessingSettings *)settings
                         cacheURL:(NSURL *_Nullable)cacheURL
                       errorBlock:(JPImageresizerErrorBlock)errorBlock
                    completeBlock:(JPCropDoneBlock)completeBlock {
    if (!imageData) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self __processImageWithImageData:imageData
                                     settings:settings
                                     cacheURL:cacheURL
                                   errorBlock:errorBlock
                                completeBlock:completeBlock];
        });
        return;
    }
    
    [self __processImageWithImageData:imageData
                             settings:settings
                             cacheURL:cacheURL
                           errorBlock:errorBlock
                        completeBlock:completeBlock];
}

+ (void)processImageWithImage:(UIImage *)image
                     settings:(JPImageProcessingSettings *)settings
                     cacheURL:(NSURL *_Nullable)cacheURL
                   errorBlock:(JPImageresizerErrorBlock)errorBlock
                completeBlock:(JPCropDoneBlock)completeBlock {
    if (!image) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self __processImageWithImage:image
                                 settings:settings
                                 cacheURL:cacheURL
                               errorBlock:errorBlock
                            completeBlock:completeBlock];
        });
        return;
    }
    
    [self __processImageWithImage:image
                         settings:settings
                         cacheURL:cacheURL
                       errorBlock:errorBlock
                    completeBlock:completeBlock];
}

+ (void)makeGIFWithImages:(NSArray<UIImage *> *)images
                 duration:(NSTimeInterval)duration
                 settings:(JPImageProcessingSettings *_Nullable)settings
                 cacheURL:(NSURL *_Nullable)cacheURL
               errorBlock:(JPImageresizerErrorBlock)errorBlock
            completeBlock:(JPCropDoneBlock)completeBlock {
    if (images.count == 0) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self __makeGIFWithImages:images
                             duration:duration
                             settings:settings
                             cacheURL:cacheURL
                           errorBlock:errorBlock
                        completeBlock:completeBlock];
        });
        return;
    }
    
    [self __makeGIFWithImages:images
                     duration:duration
                     settings:settings
                     cacheURL:cacheURL
                   errorBlock:errorBlock
                completeBlock:completeBlock];
}


+ (void)__processImageWithImageData:(NSData *)imageData
                           settings:(JPImageProcessingSettings *)settings
                           cacheURL:(NSURL *_Nullable)cacheURL
                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                      completeBlock:(JPCropDoneBlock)completeBlock {
    if (![self isGIFData:imageData]) {
        [self __processImageWithImage:[UIImage imageWithData:imageData]
                             settings:settings
                             cacheURL:cacheURL
                           errorBlock:errorBlock
                        completeBlock:completeBlock];
        return;
    }
    
    if (cacheURL) {
        cacheURL = [self __fixExtensionForImageCacheURL:cacheURL
                                                  isGIF:YES
                                               hasAlpha:NO
                                              imageData:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path]) {
            [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_CacheURLAlreadyExists];
            return;
        }
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(imageData), NULL);
    if (!source) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    BOOL isNeedProcessing = settings && settings.isNeedProcessing;
    
    NSTimeInterval duration = 0;
    NSMutableArray *delays = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];
    size_t count = CGImageSourceGetCount(source);
    for (NSInteger i = 0; i < count; i++) {
        @autoreleasepool {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!imageRef) continue;
            
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if (isNeedProcessing) {
                CGImageRef processedImageRef = JPProcessImage(imageRef,
                                                              settings.cornerRadius,
                                                              settings.backgroundColor.CGColor,
                                                              settings.borderWidth,
                                                              settings.borderColor.CGColor,
                                                              settings.outlineStrokeWidth,
                                                              settings.outlineStrokeColor.CGColor,
                                                              settings.padding,
                                                              settings.isOnlyDrawOutline);
                if (processedImageRef) {
                    image = [UIImage imageWithCGImage:processedImageRef];
                    CGImageRelease(processedImageRef);
                }
            }
            CGImageRelease(imageRef);
            [images addObject:image];
            
            NSTimeInterval delay = JPImageSourceGetGIFFrameDelayAtIndex(source, i);
            [delays addObject:@(delay)];
            duration += delay;
        }
    }
    CFRelease(source);
    
    UIImage *finalImage = images.count > 1 ? [UIImage animatedImageWithImages:images duration:duration] : images.firstObject;
    
    [self __cacheGIF:images delays:delays cacheURL:cacheURL];
    [self __executeCropDoneBlock:completeBlock image:finalImage cacheURL:cacheURL];
}

+ (void)__processImageWithImage:(UIImage *)image
                       settings:(JPImageProcessingSettings *)settings
                       cacheURL:(NSURL *_Nullable)cacheURL
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                  completeBlock:(JPCropDoneBlock)completeBlock {
    if (!image) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if (image.images && image.images.count > 1) {
        [self __makeGIFWithImages:image.images
                         duration:image.duration
                         settings:settings
                         cacheURL:cacheURL
                       errorBlock:errorBlock
                    completeBlock:completeBlock];
        return;
    }
    
    image = [self __imageFixOrientation:image];
    CGImageRef imageRef = image.CGImage;
    
    if (cacheURL) {
        cacheURL = [self __fixExtensionForImageCacheURL:cacheURL
                                                  isGIF:NO
                                               hasAlpha:JPIsHasAlpha(imageRef)
                                              imageData:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path]) {
            [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_CacheURLAlreadyExists];
            return;
        }
    }
    
    UIImage *finalImage = image;
    if (settings && settings.isNeedProcessing) {
        CGImageRef processedImageRef = JPProcessImage(imageRef,
                                                      settings.cornerRadius,
                                                      settings.backgroundColor.CGColor,
                                                      settings.borderWidth,
                                                      settings.borderColor.CGColor,
                                                      settings.outlineStrokeWidth,
                                                      settings.outlineStrokeColor.CGColor,
                                                      settings.padding,
                                                      settings.isOnlyDrawOutline);
        if (processedImageRef) {
            finalImage = [UIImage imageWithCGImage:processedImageRef];
            CGImageRelease(processedImageRef);
        }
    }
    
    [self __cacheImage:finalImage cacheURL:cacheURL];
    [self __executeCropDoneBlock:completeBlock image:finalImage cacheURL:cacheURL];
}

+ (void)__makeGIFWithImages:(NSArray<UIImage *> *)images
                   duration:(NSTimeInterval)duration
                   settings:(JPImageProcessingSettings *)settings
                   cacheURL:(NSURL *)cacheURL
                 errorBlock:(JPImageresizerErrorBlock)errorBlock
              completeBlock:(JPCropDoneBlock)completeBlock {
    NSInteger count = images.count;
    if (count == 0) {
        [self __executeErrorBlock:errorBlock cacheURL:nil reason:JPIEReason_NilObject];
        return;
    }
    
    if (count == 1) {
        [self __processImageWithImage:images.firstObject 
                             settings:settings
                             cacheURL:cacheURL
                           errorBlock:errorBlock
                        completeBlock:completeBlock];
        return;
    }
    
    if (cacheURL) {
        cacheURL = [self __fixExtensionForImageCacheURL:cacheURL
                                                  isGIF:YES
                                               hasAlpha:NO
                                              imageData:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path]) {
            [self __executeErrorBlock:errorBlock cacheURL:cacheURL reason:JPIEReason_CacheURLAlreadyExists];
            return;
        }
    }
    
    BOOL isNeedProcessing = settings && settings.isNeedProcessing;
    
    NSMutableArray *newImages = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        @autoreleasepool {
            UIImage *newImage = images[i];
            if (isNeedProcessing) {
                CGImageRef processedImageRef = JPProcessImage(newImage.CGImage,
                                                              settings.cornerRadius, 
                                                              settings.backgroundColor.CGColor,
                                                              settings.borderWidth,
                                                              settings.borderColor.CGColor,
                                                              settings.outlineStrokeWidth,
                                                              settings.outlineStrokeColor.CGColor,
                                                              settings.padding,
                                                              settings.isOnlyDrawOutline);
                if (processedImageRef) {
                    newImage = [UIImage imageWithCGImage:processedImageRef];
                    CGImageRelease(processedImageRef);
                }
            }
            [newImages addObject:newImage];
        }
    }
    
    NSTimeInterval delay = duration / (NSTimeInterval)count;
    if (delay < 0.02) delay = 0.1;
    
    UIImage *finalImage = newImages.count > 1 ? [UIImage animatedImageWithImages:newImages duration:duration] : newImages.firstObject;
    
    [self __cacheGIF:newImages delays:@[@(delay)] cacheURL:cacheURL];
    [self __executeCropDoneBlock:completeBlock image:finalImage cacheURL:cacheURL];
}

+ (BOOL)getRGBAFromImage:(UIImage *)image atPoint:(CGPoint)point red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    BOOL isSuccess = NO;
    
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) return isSuccess;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return isSuccess;
    
    if (point.x < 0 || point.y < 0 || point.x >= width || point.y >= height) return isSuccess;
    
    // 每一行的总字节数
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    if (bytesPerRow == 0) return isSuccess;
    
    // 每个像素包含的颜色通道数 = 一个像素的总位数 / 每个颜色通道使用的位数
    // 在32位像素格式下，每个颜色通道固定占8位，所以算出的「每个像素包含的颜色通道数」相当于「每个像素占用的字节数」
    size_t components = CGImageGetBitsPerPixel(imageRef) / CGImageGetBitsPerComponent(imageRef);
    // greyscale有2个，RGB有3个，RGBA有4个，其他则是无法识别的颜色空间了
    if (components != 2 && components != 3 && components != 4) return isSuccess;
    
    // 获取指向图像对象的字节数据的指针
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    if (!dataProvider) return isSuccess;
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    if (!data) return isSuccess;
    const UInt8 *bytePtr = CFDataGetBytePtr(data);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    // 获取透明信息
    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
    // 获取字节排序（大端or小端）
    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
    BOOL byteOrderNormal = NO;
    switch (byteOrderInfo) {
        case kCGBitmapByteOrderDefault:
        case kCGBitmapByteOrder32Big:
            byteOrderNormal = YES;
            break;
        default:
            break;
    }
    
    // 像素下标 = 第几行 * 每一行的总字节数 + 第几列 * 每个像素占用的字节数
    size_t byteIndex = (size_t)point.y * bytesPerRow + (size_t)point.x * components;
    
    if (components == 2) { // greyscale
        CGFloat w = 0, a = 255.0;
        JPGetGrayscaleAtPixel(bytePtr, byteIndex, byteOrderNormal, alphaInfo, &w, &a);
        if (red) *red = w;
        if (green) *green = w;
        if (blue) *blue = w;
        if (alpha) *alpha = a / 255.0;
        isSuccess = YES;
    } else if (components == 3 || components == 4) { // RGB || RGBA
        CGFloat r = 0, g = 0, b = 0, a = 255.0;
        JPGetRGBAAtPixel(bytePtr, byteIndex, byteOrderNormal, alphaInfo, &r, &g, &b, &a);
        if (red) *red = r;
        if (green) *green = g;
        if (blue) *blue = b;
        if (alpha) *alpha = a / 255.0;
        isSuccess = YES;
    }
    
    // 释放内存
    CFRelease(data);
    return isSuccess;
}

+ (UIColor *)getColorFromImage:(UIImage *)image atPoint:(CGPoint)point {
    CGFloat r = 0, g = 0, b = 0, a = 1;
    if ([self getRGBAFromImage:image atPoint:point red:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
    }
    return nil;
}


static CFDataRef data_;
static const UInt8 *bytePtr_;
static CGImageAlphaInfo alphaInfo_;
static BOOL byteOrderNormal_;
static size_t bytesPerRow_;
static size_t components_;
static size_t width_;
static size_t height_;

+ (void)beginRetrievalImage:(UIImage *)image {
    [self endRetrievalImage];
    
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) return;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return;
    
    // 每一行的总字节数
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    if (bytesPerRow == 0) return;
    
    // 每个像素包含的颜色通道数 = 一个像素的总位数 / 每个颜色通道使用的位数
    // 在32位像素格式下，每个颜色通道固定占8位，所以算出的「每个像素包含的颜色通道数」相当于「每个像素占用的字节数」
    size_t components = CGImageGetBitsPerPixel(imageRef) / CGImageGetBitsPerComponent(imageRef);
    // greyscale有2个，RGB有3个，RGBA有4个，其他则是无法识别的颜色空间了
    if (components != 2 && components != 3 && components != 4) return;
    
    // 获取指向图像对象的字节数据的指针
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    if (!dataProvider) return;
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    if (!data) return;
    const UInt8 *bytePtr = CFDataGetBytePtr(data);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    // 获取透明信息
    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
    // 获取字节排序（大端or小端）
    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
    BOOL byteOrderNormal = NO;
    switch (byteOrderInfo) {
        case kCGBitmapByteOrderDefault:
        case kCGBitmapByteOrder32Big:
            byteOrderNormal = YES;
            break;
        default:
            break;
    }
    
    data_ = data;
    bytePtr_ = bytePtr;
    alphaInfo_ = alphaInfo;
    byteOrderNormal_ = byteOrderNormal;
    bytesPerRow_ = bytesPerRow;
    components_ = components;
    width_ = width;
    height_ = height;
}

+ (BOOL)getColorFromRetrievingImageAtPoint:(CGPoint)point red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    BOOL isSuccess = NO;
    if (!data_) return isSuccess;
    if (point.x < 0 || point.y < 0 || point.x >= width_ || point.y >= height_) return isSuccess;
    
    // 像素下标 = 第几行 * 每一行的总字节数 + 第几列 * 每个像素占用的字节数
    size_t byteIndex = (size_t)point.y * bytesPerRow_ + (size_t)point.x * components_;
    
    if (components_ == 2) { // greyscale
        CGFloat w = 0, a = 255.0;
        JPGetGrayscaleAtPixel(bytePtr_, byteIndex, byteOrderNormal_, alphaInfo_, &w, &a);
        if (red) *red = w;
        if (green) *green = w;
        if (blue) *blue = w;
        if (alpha) *alpha = a / 255.0;
        isSuccess = YES;
    } else if (components_ == 3 || components_ == 4) { // RGB || RGBA
        CGFloat r = 0, g = 0, b = 0, a = 255.0;
        JPGetRGBAAtPixel(bytePtr_, byteIndex, byteOrderNormal_, alphaInfo_, &r, &g, &b, &a);
        if (red) *red = r;
        if (green) *green = g;
        if (blue) *blue = b;
        if (alpha) *alpha = a / 255.0;
        isSuccess = YES;
    }
    
    return isSuccess;
}

+ (UIColor *)getColorFromRetrievingImageAtPoint:(CGPoint)point {
    CGFloat r = 0, g = 0, b = 0, a = 1;
    if ([self getColorFromRetrievingImageAtPoint:point red:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
    }
    return nil;
}

+ (void)endRetrievalImage {
    CFDataRef data = data_;
    data_ = NULL;
    if (data) {
        CFRelease(data);
    }
}

@end
