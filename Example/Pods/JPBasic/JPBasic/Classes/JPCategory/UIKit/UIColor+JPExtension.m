//
//  UIColor+JPExtension.m
//  Infinitee2.0-Design
//
//  Created by Jill on 16/8/9.
//  Copyright © 2016年 陈珏洁. All rights reserved.
//

#import "UIColor+JPExtension.h"
#import "UIImage+JPExtension.h"

@implementation UIColor (JPExtension)

+ (UIColor *)jp_colorWithRgba:(JPRgba)rgba {
    return [UIColor colorWithRed:(rgba.jp_r / 255.0f) green:(rgba.jp_g / 255.0f) blue:(rgba.jp_b / 255.0f) alpha:rgba.jp_a];
}

+ (JPRgba)jp_rgbaWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
    
    JPRgba rgba = JPRgbaMake(0, 0, 0, 0);
    
    //删除字符串中的空格
    NSString *cString = [[hexStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return rgba;
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return rgba;
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    rgba.jp_r = r;
    rgba.jp_g = g;
    rgba.jp_b = b;
    rgba.jp_a = alpha;
    return rgba;
}

+ (UIColor *)jp_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
    return [self jp_colorWithRgba:[self jp_rgbaWithHexString:hexStr alpha:alpha]];
}

//默认alpha值为1
+ (UIColor *)jp_colorWithHexString:(NSString *)hexStr {
    return [self jp_colorWithHexString:hexStr alpha:1.0f];
}

- (JPRgba)jp_rgba {
    CGFloat r = 0.0;
    CGFloat g = 0.0;
    CGFloat b = 0.0;
    CGFloat a = 0.0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    r *= 255.0;
    g *= 255.0;
    b *= 255.0;
    return JPRgbaMake(r, g, b, a);
}

// 判断颜色是不是亮色
- (BOOL)jp_isLightColor {
    CGFloat components[3];
    [self getRGBComponents:components forColor:self];
//    NSLog(@"%f %f %f", components[0], components[1], components[2]);
    
    CGFloat num = components[0] + components[1] + components[2];
    if(num < 382)
        return NO;
    else
        return YES;
}

//获取RGB值
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 bitmapInfo);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component];
    }
}

+ (UIColor *)jp_gradientColorWithColors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint size:(CGSize)size {
    if (colors.count == 0) return nil;
    if (colors.count == 1) {
        CGColorRef cgColor = (__bridge CGColorRef)(colors.firstObject);
        return [UIColor colorWithCGColor:cgColor];
    }
    UIImage *patternImage = [UIImage jp_gradientImageWithColors:colors locations:locations startPoint:startPoint endPoint:endPoint size:size];
    return [UIColor colorWithPatternImage:patternImage];
}

@end
