//
//  UIImage+JPImageresizer.m
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "UIImage+JPImageresizer.h"

@implementation UIImage (JPImageresizer)

#pragma mark - 获取图像的黑色轮廓

- (UIImage *)jpir_destinationOutImage {
    if (!self) return nil;
    CGRect rect = (CGRect){CGPointZero, self.size};
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    [UIColor.blackColor setFill];
    UIRectFill(rect);
    [self drawInRect:rect blendMode:kCGBlendModeDestinationOut alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 修正方向

- (UIImage *)jpir_fixOrientation {
    
    UIImageOrientation orientation = self.imageOrientation;
    if (orientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (orientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (orientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

#pragma mark - 旋转并切圆

CG_INLINE CGRect
JPRectSwapWH(CGRect rect) {
    CGFloat tmp = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = tmp;
    return rect;
}

- (UIImage *)jpir_rotate:(UIImageOrientation)orientation isRoundClip:(BOOL)isRoundClip {
    
    CGImageRef imageRef = self.CGImage;
    CGRect bounds = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect rect = bounds;
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (orientation)
    {
        case UIImageOrientationUp:
            if (!isRoundClip) return self;
            break;
            
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(rect.size.width, rect.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bounds = JPRectSwapWH(bounds);
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bounds = JPRectSwapWH(bounds);
            transform = CGAffineTransformMakeTranslation(rect.size.height, rect.size.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bounds = JPRectSwapWH(bounds);
            transform = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bounds = JPRectSwapWH(bounds);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            if (!isRoundClip) return self;
            break;
    }
    
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    switch (orientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctx, -1.0, 1.0);
            CGContextTranslateCTM(ctx, -rect.size.height, 0.0);
            break;
        default:
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextTranslateCTM(ctx, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctx, transform);
    
    if (isRoundClip) {
        CGRect clipRect = rect;
        CGFloat radius;
        if (clipRect.size.width >= clipRect.size.height) {
            clipRect.origin.x = (clipRect.size.width - clipRect.size.height) * 0.5;
            clipRect.size.width = clipRect.size.height;
            radius = clipRect.size.height;
        } else {
            clipRect.origin.y = (clipRect.size.height - clipRect.size.width) * 0.5;
            clipRect.size.height = clipRect.size.width;
            radius = clipRect.size.width;
        }
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:clipRect cornerRadius:radius];
        CGContextAddPath(ctx, path.CGPath);
        CGContextClip(ctx);
    }
    
    CGContextDrawImage(ctx, rect, imageRef);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - 压缩并蒙版

- (UIImage *)jpir_resizeImageWithScale:(CGFloat)scale maskImage:(UIImage *)maskImage {
    if (scale <= 0 || scale > 1) scale = 1;
    if (scale == 1 && maskImage == nil) return self;
    
    CGImageRef imageRef = self.CGImage;
    
    CGFloat pixelWidth = CGImageGetWidth(imageRef) * scale;
    CGFloat pixelHeight = CGImageGetHeight(imageRef) * scale;
    CGRect rect = CGRectMake(0, 0, pixelWidth, pixelHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    if (maskImage) {
        bitmapInfo |= kCGImageAlphaPremultipliedLast;
    } else {
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    }
    CGContextRef context = CGBitmapContextCreate(NULL, pixelWidth, pixelHeight, 8, 0, colorSpace, bitmapInfo);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    if (maskImage != nil) {
        CGImageRef maskImageRef = maskImage.CGImage;
        CGContextClipToMask(context, rect, maskImageRef);
    }
    CGContextDrawImage(context, rect, imageRef);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(newImageRef);
    
    return newImage;
}

@end
