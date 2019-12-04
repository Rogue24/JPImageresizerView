//
//  UIImage+JPImageresizer.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JPImageresizer)

/** 修正图片的方向 */
- (UIImage *)jpir_fixOrientation;
/** 按指定方向旋转图片 */
- (UIImage*)jpir_rotate:(UIImageOrientation)orientation;

/** 沿Y轴翻转 */
- (UIImage *)jpir_verticalityMirror;
/** 沿X轴翻转 */
- (UIImage *)jpir_horizontalMirror;

// 压缩图片：https://www.jianshu.com/p/c8e94ab5b50e
/** 按比例压缩 */
- (UIImage *)jpir_resizeImageWithScale:(CGFloat)scale;
/** 按逻辑宽度压缩 */
- (UIImage *)jpir_resizeImageWithLogicWidth:(CGFloat)logicWidth;
/** 按像素宽度压缩 */
- (UIImage *)jpir_resizeImageWithPixelWidth:(CGFloat)pixelWidth;

@end
