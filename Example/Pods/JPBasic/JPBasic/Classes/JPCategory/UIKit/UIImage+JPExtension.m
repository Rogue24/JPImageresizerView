//
//  UIImage+JPExtension.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/25.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "UIImage+JPExtension.h"

@implementation UIImage (JPExtension)

- (UIImage *)jp_fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
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
        default:
            break;
    }
    
    switch (self.imageOrientation) {
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
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage*)jp_rotate:(UIImageOrientation)orientation {
    
    CGImageRef imageRef = self.CGImage;
    CGRect bounds = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect rect = bounds;
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (orientation)
    {
        case UIImageOrientationUp:
            return self;
            
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
            bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
            transform = CGAffineTransformMakeTranslation(rect.size.height, rect.size.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
            transform = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            return self;
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
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imageRef);
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)jp_circleImageWithRadius:(CGFloat)radius andSize:(CGSize)size {
    return [self jp_circleImageWithRadius:radius andSize:size borderW:0 borderColor:nil];
}

- (UIImage *)jp_circleImageWithRadius:(CGFloat)radius andSize:(CGSize)size borderW:(CGFloat)borderW borderColor:(UIColor *)borderColor {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    CGFloat minSize = MIN(size.width, size.height);
    BOOL isHasBorder = NO;
    if (borderColor && borderW > 0 && borderW < minSize * 0.5) {
        isHasBorder = YES;
        rect = CGRectInset(rect, borderW * 0.5, borderW * 0.5);
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, isHasBorder ? borderW : radius)];
    
    [path closePath];
    
    if (isHasBorder) {
        path.lineWidth = borderW;
        [borderColor setStroke];
        [path stroke];
    }
    
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)jp_circleImageWithRadius:(CGFloat)radius andSize:(CGSize)size completion:(void (^)(UIImage * image))completion {
    
    @autoreleasepool {
        if (completion) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                CGRect rect = CGRectMake(0, 0, size.width, size.height);
                UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
                CGContextAddPath(ctx,path.CGPath);
                CGContextClip(ctx);
                [self drawInRect:rect];
                CGContextDrawPath(ctx, kCGPathFillStroke);
                UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(newImage);
                });
                
            });
        }
    }
    
}

+ (UIImage *)jp_createImageWithColor:(UIColor *)color {
    return [self jp_createImageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)jp_createImageWithColor:(UIColor *)color
                                size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)jp_createImageWithColor:(UIColor *)color
                                size:(CGSize)size
                        cornerRadius:(CGFloat)cornerRadius {
    return [self jp_createImageWithColor:color
                                    size:size
                            cornerRadius:cornerRadius
                       byRoundingCorners:UIRectCornerAllCorners];
}

+ (UIImage *)jp_createImageWithColor:(UIColor *)color
                                size:(CGSize)size
                        cornerRadius:(CGFloat)cornerRadius
                   byRoundingCorners:(UIRectCorner)corners {
    if (cornerRadius == 0) {
        return [self jp_createImageWithColor:color size:size];
    }
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, size.width, size.height);
    layer.backgroundColor = color.CGColor;
    layer.masksToBounds = YES;
    if (cornerRadius > 0) {
        if (corners == UIRectCornerAllCorners) {
            layer.cornerRadius = cornerRadius;
        } else {
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:layer.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
            layer.mask = maskLayer;
        }
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)jp_gradientImageWithColors:(NSArray *)colors
                              locations:(NSArray *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
                                   size:(CGSize)size {
    return [self jp_gradientImageWithColors:colors
                                  locations:locations
                                 startPoint:startPoint
                                   endPoint:endPoint
                                       size:size
                               cornerRadius:0];
}

+ (UIImage *)jp_gradientImageWithColors:(NSArray *)colors
                              locations:(NSArray *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
                                   size:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius {
    return [self jp_gradientImageWithColors:colors
                                  locations:locations
                                 startPoint:startPoint
                                   endPoint:endPoint
                                       size:size
                               cornerRadius:cornerRadius
                          byRoundingCorners:UIRectCornerAllCorners];
}

+ (UIImage *)jp_gradientImageWithColors:(NSArray *)colors
                              locations:(NSArray *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
                                   size:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius
                      byRoundingCorners:(UIRectCorner)corners {
    if (colors.count == 0) return nil;
    UIImage *gradientImage;
    if (colors.count == 1) {
        UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)(colors.firstObject)];
        gradientImage = [self jp_createImageWithColor:color
                                                 size:size
                                         cornerRadius:cornerRadius
                                    byRoundingCorners:corners];
    } else {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CAGradientLayer *gLayer = [CAGradientLayer layer];
        gLayer.masksToBounds = YES;
        gLayer.bounds = CGRectMake(0, 0, size.width, size.height);
        gLayer.startPoint = startPoint;
        gLayer.endPoint = endPoint;
        gLayer.colors = colors;
        if (locations) gLayer.locations = locations;
        if (cornerRadius > 0) {
            if (corners == UIRectCornerAllCorners) {
                gLayer.cornerRadius = cornerRadius;
            } else {
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:gLayer.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
                gLayer.mask = maskLayer;
            }
        }
        [gLayer renderInContext:UIGraphicsGetCurrentContext()];
        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return gradientImage;
}

/** 裁剪Image */
- (UIImage *)jp_clipImageInRect:(CGRect)rect scale:(CGFloat)scale {
    
    CGFloat x = rect.origin.x * scale;
    CGFloat y = rect.origin.y * scale;
    CGFloat w = rect.size.width * scale;
    CGFloat h = rect.size.height * scale;
    CGRect cgRect = CGRectMake(x, y, w, h);
    
    @autoreleasepool {
        CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cgRect);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return image;
    }
    
}

+ (UIColor*)getPixelColorAtLocation:(CGPoint)point inImage:(UIImage *)image {
    
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:
                          inImage];
    
    if (cgctx == NULL) { return nil; /* error */ }
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    if (data != NULL) {
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        //        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,
        //              blue,alpha);
        //
        //        NSLog(@"x:%f y:%f", point.x, point.y);
        
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:
                 (blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    CGContextRelease(cgctx);
    
    if (data) { free(data); }
    
    return color;
    
}

+ (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL){
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL){
        
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL){
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    CGColorSpaceRelease( colorSpace );
    
    return context;
    
}



//获取图片某一点的颜色
- (UIColor *)jp_colorAtPixel:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
}

- (UIColor *)jp_mostColor {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize = CGSizeMake(40, 40);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width * 4,
                                                 colorSpace,
                                                 bitmapInfo);
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    //    CGSize thumbSize = self.size;
    //    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //    CGContextRef context = CGBitmapContextCreate(NULL,
    //                                                 thumbSize.width,
    //                                                 thumbSize.height,
    //                                                 8,//bits per component
    //                                                 thumbSize.width * 4,
    //                                                 colorSpace,
    //                                                 bitmapInfo);
    //    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    //    CGContextDrawImage(context, drawRect, self.CGImage);
    //    CGColorSpaceRelease(colorSpace);
    
    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
    
    if (data == NULL) return nil;
    NSArray *MaxColor=nil;
    // NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];
    float maxScore=0;
    for (int x = 0; x < thumbSize.width * thumbSize.height; x++) {
        
        int offset = 4*x;
        int red = data[offset];
        int green = data[offset+1];
        int blue = data[offset+2];
        int alpha =  data[offset+3];
        
        if (alpha<25)continue;
        
        float h,s,v;
        
        RGBtoHSV(red, green, blue, &h, &s, &v);
        
        float y = MIN(abs(red*2104+green*4130+blue*802+4096+131072)>>13, 235);
        y= (y-16)/(235-16);
        if (y>0.9) continue;
        
        float score = (s+0.1)*x;
        if (score>maxScore) {
            maxScore = score;
        }
        MaxColor=@[@(red),@(green),@(blue),@(alpha)];
        
    }
    
    CGContextRelease(context);
    return [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
}

+ (UIImage *)jp_getLauchImage {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSString *viewOrientation = (orientation == UIInterfaceOrientationPortraitUpsideDown || orientation == UIInterfaceOrientationPortrait) ? @"Portrait" : @"Landscape";
    
    NSArray* imageDicts = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* imageDict in imageDicts) {
        CGSize imageSize = CGSizeFromString(imageDict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) &&
            [viewOrientation isEqualToString:imageDict[@"UILaunchImageOrientation"]]) {
            UIImage *launchImage = [UIImage imageNamed:imageDict[@"UILaunchImageName"]];
            if (launchImage.scale == [UIScreen mainScreen].scale) {
                return launchImage;
            }
        }
    }
    
    return nil;
}


- (UIImage *)jp_imageWithTintColor:(UIColor *)tintColor size:(CGSize)size {
    return [self jp_imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn size:size];
}

- (UIImage *)jp_imageWithGradientTintColor:(UIColor *)tintColor size:(CGSize)size {
    return [self jp_imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay size:size];
}

- (UIImage *)jp_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode size:(CGSize)size {
    
    if (!self) {
        return nil;
    }
    
    @autoreleasepool {
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        [tintColor setFill];
        
        CGRect bounds = CGRectMake(0, 0, size.width, size.height);
        UIRectFill(bounds);
        
        //        CGImageRef imageRef = self.CGImage;
        //        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //        CGContextSetBlendMode(ctx, blendMode);
        //        CGContextDrawImage(ctx, bounds, imageRef);
        
        // Draw the tinted image in context
        [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
        
        if (blendMode != kCGBlendModeDestinationIn) {
            [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        }
        
        UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return tintedImage;
    }
    
}

+ (UIImage *)jp_bundlePngImageWithPrefixName:(NSString *)prefixName {
    NSInteger screenScale = (NSInteger)[UIScreen mainScreen].scale;
    if (screenScale < 2) screenScale = 2;
    if (screenScale > 3) screenScale = 3;
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%zdx", prefixName, screenScale] ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)jp_createNonInterpolatedUiimageFormCIImage:(CIImage *)image size:(CGFloat)size {
    
    CGRect extent = CGRectIntegral(image.extent);
    size_t width = CGRectGetWidth(extent);
    size_t height = CGRectGetHeight(extent);
    
    CGFloat scale = MIN(size / width, size / height);
    
    //1.创建bitmap
    width *= scale;
    height *= scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //2.保存bitmap图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGColorSpaceRelease(cs);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}

+ (UIImage *)jp_QRCodeImageWithInputMessage:(NSString *)inputMessage foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor {
    
    // 创建滤镜对象
    CIFilter *fiter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [fiter setDefaults];
    [fiter setValue:[inputMessage dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    CIImage *outputImage = [fiter outputImage];
    
    if (!foregroundColor) foregroundColor = UIColor.blackColor;
    if (!backgroundColor) backgroundColor = UIColor.whiteColor;
    
    // 创建颜色过滤器
    /*
     inputImage,     需要设定颜色的图片
     inputColor0,    前景色 - 二维码的颜色
     inputColor1     背景色 - 二维码背景的颜色
     */
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setDefaults];
    [colorFilter setValue:outputImage forKey:@"inputImage"];
    [colorFilter setValue:[CIColor colorWithCGColor:foregroundColor.CGColor] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor colorWithCGColor:backgroundColor.CGColor] forKey:@"inputColor1"];
    // 获取图片
    outputImage = colorFilter.outputImage;
    
    // 放大图片的比例
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(9, 9)];
    
    UIImage *qrCodeImage = [UIImage imageWithCIImage:outputImage];
    return qrCodeImage;
}

- (NSData *)jp_image2DataWithIsPNG:(BOOL *)isPNG maxPixelWidth:(CGFloat)maxPixelWidth {
    if (self.size.width < self.size.height) maxPixelWidth = self.jp_whRatio * maxPixelWidth;
    UIImage *resizeImage = [self jp_cgResizeImageWithPixelWidth:maxPixelWidth];
    if (!resizeImage) {
        return nil;
    }
    NSData *imageData = UIImageJPEGRepresentation(resizeImage, 1.0);
    if (imageData) {
        if (isPNG) *isPNG = NO;
    } else {
        imageData = UIImagePNGRepresentation(resizeImage);
        if (isPNG) *isPNG = YES;
    }
    return imageData;
}

/** UI缩略（按比例缩略） */
- (UIImage *)jp_uiResizeImageWithScale:(CGFloat)scale {
    return [self jp_uiResizeImageWithLogicWidth:(self.size.width * scale)];
}

/** UI缩略（按逻辑宽度缩略） */
- (UIImage *)jp_uiResizeImageWithLogicWidth:(CGFloat)logicWidth {
    if (logicWidth >= self.size.width) return self;
    CGFloat w = logicWidth;
    CGFloat h = w * self.jp_hwRatio;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, self.scale);
        [self drawInRect:CGRectMake(0, 0, w, h)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage;
    }
}

/** UI缩略（按像素宽度缩略） */
- (UIImage *)jp_uiResizeImageWithPixelWidth:(CGFloat)pixelWidth {
    return [self jp_uiResizeImageWithLogicWidth:(pixelWidth / self.scale)];
}

/** CG缩略（按比例缩略） */
- (UIImage *)jp_cgResizeImageWithScale:(CGFloat)scale {
    return [self jp_cgResizeImageWithLogicWidth:(self.size.width * scale)];
}

/** CG缩略（按逻辑宽度缩略） */
- (UIImage *)jp_cgResizeImageWithLogicWidth:(CGFloat)logicWidth {
    return [self jp_cgResizeImageWithPixelWidth:(logicWidth * self.scale)];
}

/** CG缩略（按像素宽度缩略） */
- (UIImage *)jp_cgResizeImageWithPixelWidth:(CGFloat)pixelWidth {
    CGImageRef cgImage = self.CGImage;
    if (!cgImage) return self;
    
    if (pixelWidth >= (self.size.width * self.scale)) return self;
    CGFloat pixelHeight = pixelWidth * self.jp_hwRatio;
    
//    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
//    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
//    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
//    CGContextRef context = CGBitmapContextCreate(NULL, pixelWidth, pixelHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    /**
     * 在某些手机快捷键屏幕截图生成的图片，通过上面方式创建的 context 为空
     * 因为生成的图片的 CGBitmapInfo 为 kCGImageAlphaLast 或 kCGImageByteOrder16Little，iOS不支持这种格式。
     * 参考：https://www.jianshu.com/p/2e45a2ea7b62
     * 解决方法：context 的创建采用了 YYKit 的方式。
     */
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, pixelWidth, pixelHeight, 8, 0, colorSpace, bitmapInfo);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, pixelWidth, pixelHeight), cgImage);
    CGImageRef resizedCGImage = CGBitmapContextCreateImage(context);
    
    UIImage *resizedImage = [UIImage imageWithCGImage:resizedCGImage scale:self.scale orientation:self.imageOrientation];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(resizedCGImage);
    
    return resizedImage;
}

/** IO缩略（按比例缩略） */
- (UIImage *)jp_ioResizeImageWithScale:(CGFloat)scale isPNGType:(BOOL)isPNGType {
    return [self jp_ioResizeImageWithLogicWidth:(self.size.width * scale) isPNGType:isPNGType];
}

/** IO缩略（按逻辑宽度缩略） */
- (UIImage *)jp_ioResizeImageWithLogicWidth:(CGFloat)logicWidth isPNGType:(BOOL)isPNGType {
    return [self jp_ioResizeImageWithPixelWidth:(logicWidth * self.scale) isPNGType:isPNGType];
}

/** IO缩略（按像素宽度缩略） */
- (UIImage *)jp_ioResizeImageWithPixelWidth:(CGFloat)pixelWidth isPNGType:(BOOL)isPNGType {
    if (pixelWidth >= (self.size.width * self.scale)) return self;
    
    NSData *data = isPNGType ? UIImagePNGRepresentation(self) : UIImageJPEGRepresentation(self, 1);
    if (!data) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    
    CGFloat maxPixelValue = (self.jp_hwRatio > 1.0) ? (pixelWidth * self.jp_hwRatio) : pixelWidth;
    // 因为kCGImageSourceCreateThumbnailFromImageAlways会一直创建缩略图，造成内存浪费
    // 所以使用kCGImageSourceCreateThumbnailFromImageIfAbsent
    NSDictionary *options = @{(id)kCGImageSourceCreateThumbnailWithTransform : @(YES),
                              (id)kCGImageSourceCreateThumbnailFromImageIfAbsent : @(YES),
                              (id)kCGImageSourceThumbnailMaxPixelSize : @(maxPixelValue)};
    
    CGImageRef resizedCGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)options);
    UIImage *resizedImage = [UIImage imageWithCGImage:resizedCGImage scale:self.scale orientation:self.imageOrientation];
    
    CFRelease(imageSource);
    CGImageRelease(resizedCGImage);
    
    return resizedImage;
}

- (CGFloat)jp_whRatio {
    return (self.size.width / self.size.height);
}

- (CGFloat)jp_hwRatio {
    return (self.size.height / self.size.width);
}

/** 图片中间区域切圆 */
- (UIImage *)jp_imageByRoundWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    CGFloat minSide = MIN(w, h);
    CGFloat cornerRadius = minSide * 0.5;
    CGSize size = CGSizeMake(minSide, minSide);
    
    if (borderWidth >= cornerRadius) return self;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    
    UIRectCorner corners = UIRectCornerAllCorners;
    CGRect roundRect = (CGRect){CGPointZero, size};
    
    UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:roundRect byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, 0)];
    [roundPath closePath];
    [roundPath addClip];
    
    CGRect rect = (CGRect){CGPointMake((size.width - w) * 0.5, (size.height - h) * 0.5), self.size};
    CGContextDrawImage(context, rect, self.CGImage);
    
    if (borderWidth > 0 && borderColor) {
        CGFloat strokeInset = borderWidth * 0.5;
        CGRect strokeRect = CGRectInset(roundRect, strokeInset, strokeInset);
        CGFloat strokeRadius = strokeRect.size.width * 0.5;
        
        UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect byRoundingCorners:corners cornerRadii:CGSizeMake(strokeRadius, 0)];
        [strokePath closePath];
        strokePath.lineWidth = borderWidth;
        
        [borderColor setStroke];
        [strokePath stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
