//
//  UIImage+JPExtension.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JPExtension)

/** 修正图片的方向 */
- (UIImage *)jp_fixOrientation;
/** 按指定方向旋转图片 */
- (UIImage*)jp_rotate:(UIImageOrientation)orientation;

/** 沿Y轴翻转 */
- (UIImage *)jp_verticalityMirror;
/** 沿X轴翻转 */
- (UIImage *)jp_horizontalMirror;

// 压缩图片：https://www.jianshu.com/p/c8e94ab5b50e
/** 按比例压缩 */
- (UIImage *)jp_resizeImageWithScale:(CGFloat)scale;
/** 按逻辑宽度压缩 */
- (UIImage *)jp_resizeImageWithLogicWidth:(CGFloat)logicWidth;
/** 按像素宽度压缩 */
- (UIImage *)jp_resizeImageWithPixelWidth:(CGFloat)pixelWidth;

@end
