//
//  UIImage+JPExtension.h
//  Infinitee2.0
//
//  Created by guanning on 2017/1/25.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 从(image)data获取图片格式
 */
typedef NS_ENUM(NSInteger, JPImageType) {
    JPImageType_JPEG,
    JPImageType_PNG,
    JPImageType_Unknown
};

CG_INLINE JPImageType NSPUIImageTypeFromData(NSData *imageData) {
    if (imageData.length > 4) {
        const unsigned char * bytes = [imageData bytes];
        if (bytes[0] == 0xff &&
            bytes[1] == 0xd8 &&
            bytes[2] == 0xff) {
            return JPImageType_JPEG;
        }
        if (bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4e &&
            bytes[3] == 0x47) {
            return JPImageType_PNG;
        }
    }
    return JPImageType_Unknown;
}

@interface UIImage (JPExtension)

/** 修正图片的方向 */
- (UIImage *)jp_fixOrientation;
/** 按指定方向旋转图片 */
- (UIImage*)jp_rotate:(UIImageOrientation)orientation;

/** 设置圆角 */
- (UIImage *)jp_circleImageWithRadius:(CGFloat)radius andSize:(CGSize)size;
- (UIImage *)jp_circleImageWithRadius:(CGFloat)radius andSize:(CGSize)size borderW:(CGFloat)borderW borderColor:(UIColor *)borderColor;

/** 设置圆角带回调 */
- (void)jp_circleImageWithRadius:(CGFloat)radius andSize:(CGSize)size completion:(void (^)(UIImage * image))completion;

/** 裁剪图片 */
- (UIImage *)jp_clipImageInRect:(CGRect)rect scale:(CGFloat)scale;

/** 通过颜色生成图片 */
+ (UIImage *)jp_createImageWithColor:(UIColor *)color;

+ (UIImage *)jp_createImageWithColor:(UIColor *)color
                                size:(CGSize)size;

+ (UIImage *)jp_createImageWithColor:(UIColor *)color
                                size:(CGSize)size
                        cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *)jp_createImageWithColor:(UIColor *)color
                                size:(CGSize)size
                        cornerRadius:(CGFloat)cornerRadius
                   byRoundingCorners:(UIRectCorner)corners;

/** 通过渐变生成图片 */
+ (UIImage *)jp_gradientImageWithColors:(NSArray *)colors
                              locations:(NSArray *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
                                   size:(CGSize)size;

+ (UIImage *)jp_gradientImageWithColors:(NSArray *)colors
                              locations:(NSArray *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
                                   size:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *)jp_gradientImageWithColors:(NSArray *)colors
                              locations:(NSArray *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
                                   size:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius
                      byRoundingCorners:(UIRectCorner)corners;

- (UIColor *)jp_colorAtPixel:(CGPoint)point;
- (UIColor *)jp_mostColor;

+ (UIImage *)jp_getLauchImage;

- (UIImage *)jp_imageWithTintColor:(UIColor *)tintColor size:(CGSize)size;
- (UIImage *)jp_imageWithGradientTintColor:(UIColor *)tintColor size:(CGSize)size;
- (UIImage *)jp_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode size:(CGSize)size;

+ (UIImage *)jp_bundlePngImageWithPrefixName:(NSString *)prefixName;

+ (UIImage *)jp_createNonInterpolatedUiimageFormCIImage:(CIImage *)image size:(CGFloat)size;

+ (UIImage *)jp_QRCodeImageWithInputMessage:(NSString *)inputMessage foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor;

- (NSData *)jp_image2DataWithIsPNG:(BOOL *)isPNG maxPixelWidth:(CGFloat)maxPixelWidth;

/** UI缩略（按比例缩略） */
- (UIImage *)jp_uiResizeImageWithScale:(CGFloat)scale;
/** UI缩略（按逻辑宽度缩略） */
- (UIImage *)jp_uiResizeImageWithLogicWidth:(CGFloat)logicWidth;
/** UI缩略（按像素宽度缩略） */
- (UIImage *)jp_uiResizeImageWithPixelWidth:(CGFloat)pixelWidth;

/** CG缩略（按比例缩略） */
- (UIImage *)jp_cgResizeImageWithScale:(CGFloat)scale;
/** CG缩略（按逻辑宽度缩略） */
- (UIImage *)jp_cgResizeImageWithLogicWidth:(CGFloat)logicWidth;
/** CG缩略（按像素宽度缩略） */
- (UIImage *)jp_cgResizeImageWithPixelWidth:(CGFloat)pixelWidth;

/** IO缩略（按比例缩略） */
- (UIImage *)jp_ioResizeImageWithScale:(CGFloat)scale isPNGType:(BOOL)isPNGType;
/** IO缩略（按逻辑宽度缩略） */
- (UIImage *)jp_ioResizeImageWithLogicWidth:(CGFloat)logicWidth isPNGType:(BOOL)isPNGType;
/** IO缩略（按像素宽度缩略） */
- (UIImage *)jp_ioResizeImageWithPixelWidth:(CGFloat)pixelWidth isPNGType:(BOOL)isPNGType;

/** 图片宽高比 */
- (CGFloat)jp_whRatio;
/** 图片高宽比 */
- (CGFloat)jp_hwRatio;

/** 图片中间区域切圆 */
- (UIImage *)jp_imageByRoundWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
@end
