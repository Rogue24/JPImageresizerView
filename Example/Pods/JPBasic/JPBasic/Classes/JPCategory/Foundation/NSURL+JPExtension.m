//
//  NSURL+JPExtension.m
//  JPBasic
//
//  Created by 周健平 on 2020/10/5.
//

#import "NSURL+JPExtension.h"

#define JPRandomImageBaseURL @"https://picsum.photos"

@implementation NSURL (JPExtension)

+ (NSURL *)jp_randomImageURLWithSize:(CGSize)size {
    return [self jp_randomImageURLWithWidth:size.width height:size.height];
}

+ (NSURL *)jp_randomImageURLWithWidth:(CGFloat)width whScale:(CGFloat)whScale {
    return [self jp_randomImageURLWithWidth:width height:(width / whScale)];
}

+ (NSURL *)jp_randomImageURLWithHeight:(CGFloat)height whScale:(CGFloat)whScale {
    return [self jp_randomImageURLWithWidth:(height * whScale) height:height];
}

+ (NSURL *)jp_randomImageURLWithWidth:(CGFloat)width height:(CGFloat)height {
    NSString *urlStr = JPRandomImageBaseURL;
    if (width <= 0 && height <= 0) {
        urlStr = [urlStr stringByAppendingString:@"/0"];
    } else {
        if (width > 0) urlStr = [urlStr stringByAppendingFormat:@"/%.0lf", width];
        if (height > 0) urlStr = [urlStr stringByAppendingFormat:@"/%.0lf", height];
    }
    return [NSURL URLWithString:urlStr];
}

@end
