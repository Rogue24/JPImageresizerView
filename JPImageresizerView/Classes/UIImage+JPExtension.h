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

@end
