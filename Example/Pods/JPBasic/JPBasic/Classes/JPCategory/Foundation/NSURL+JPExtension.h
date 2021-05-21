//
//  NSURL+JPExtension.h
//  JPBasic
//
//  Created by 周健平 on 2020/10/5.
//

#import <UIKit/UIKit.h>

#define JPRandomImageURL(w, h) [NSURL jp_randomImageURLWithWidth:w height:h]
#define JPRandomSquareImageURL(wh) [NSURL jp_randomImageURLWithWidth:wh height:wh] // 矩形图片
#define JPRandomOriginImageURL [NSURL jp_randomImageURLWithWidth:0 height:0] // 原图

@interface NSURL (JPExtension)

// 目前这里宽高采用的单位是【像素】
// 显示的尺寸 = 实际的像素 / 缩放比例 ==> imageSize = pixelSize / imageScale
// 默认 imageScale = [UIScreen mainScreen].scale

+ (NSURL *)jp_randomImageURLWithSize:(CGSize)size;
+ (NSURL *)jp_randomImageURLWithWidth:(CGFloat)width whScale:(CGFloat)whScale;
+ (NSURL *)jp_randomImageURLWithHeight:(CGFloat)height whScale:(CGFloat)whScale;
+ (NSURL *)jp_randomImageURLWithWidth:(CGFloat)width height:(CGFloat)height;

@end

