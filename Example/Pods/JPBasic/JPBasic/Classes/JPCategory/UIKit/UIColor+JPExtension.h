//
//  UIColor+JPExtension.h
//  Infinitee2.0-Design
//
//  Created by Jill on 16/8/9.
//  Copyright © 2016年 陈珏洁. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define JPRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define JPRandomColor JPRGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define JPRandomAColor(a) JPRGBAColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), a)

struct JPRgba {
    CGFloat jp_r;
    CGFloat jp_g;
    CGFloat jp_b;
    CGFloat jp_a;
};
typedef struct CG_BOXABLE JPRgba JPRgba;

CG_INLINE JPRgba
JPRgbaMake(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    JPRgba rgba;
    rgba.jp_r = r;
    rgba.jp_g = g;
    rgba.jp_b = b;
    rgba.jp_a = a;
    return rgba;
}

CG_INLINE bool
JPRgbaEqualToRgba(JPRgba rgba1, JPRgba rgba2) {
    return (rgba1.jp_r == rgba2.jp_r &&
            rgba1.jp_g == rgba2.jp_g &&
            rgba1.jp_b == rgba2.jp_b &&
            rgba1.jp_a == rgba2.jp_a);
}

CG_INLINE bool
JPColorEqualToColor(UIColor *color1, UIColor *color2) {
    if (!color1 && !color2) return true;
    if ((color1 && color2) && [color1 isEqual:color2]) return true;
    return false;
}

CG_INLINE JPRgba
JPDifferRgba(JPRgba sourceRgba, JPRgba targetRgba) {
    return JPRgbaMake(targetRgba.jp_r - sourceRgba.jp_r,
                      targetRgba.jp_g - sourceRgba.jp_g,
                      targetRgba.jp_b - sourceRgba.jp_b,
                      targetRgba.jp_a - sourceRgba.jp_a);
}

CG_INLINE JPRgba
JPFromSourceToTargetRgbaByDifferRgba(JPRgba sourceRgba, JPRgba differRgba, CGFloat progress) {
    return JPRgbaMake(sourceRgba.jp_r + progress * differRgba.jp_r,
                      sourceRgba.jp_g + progress * differRgba.jp_g,
                      sourceRgba.jp_b + progress * differRgba.jp_b,
                      sourceRgba.jp_a + progress * differRgba.jp_a);
}

CG_INLINE JPRgba
JPFromSourceToTargetRgba(JPRgba sourceRgba, JPRgba targetRgba, CGFloat progress) {
    JPRgba differRgba = JPDifferRgba(sourceRgba, targetRgba);
    return JPFromSourceToTargetRgbaByDifferRgba(sourceRgba, differRgba, progress);
}

@interface UIColor (JPExtension)

+ (UIColor *)jp_colorWithRgba:(JPRgba)rgba;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (JPRgba)jp_rgbaWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
+ (UIColor *)jp_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
+ (UIColor *)jp_colorWithHexString:(NSString *)hexStr;

- (JPRgba)jp_rgba;

- (BOOL)jp_isLightColor;

+ (UIColor *)jp_gradientColorWithColors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint size:(CGSize)size;

@end
