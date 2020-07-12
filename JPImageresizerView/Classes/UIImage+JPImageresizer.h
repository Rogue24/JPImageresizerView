//
//  UIImage+JPImageresizer.h
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JPImageresizer)
- (UIImage *)jpir_destinationOutImage;
- (UIImage *)jpir_fixOrientation;
- (UIImage *)jpir_rotate:(UIImageOrientation)orientation isRoundClip:(BOOL)isRoundClip;
- (UIImage *)jpir_resizeImageWithScale:(CGFloat)scale maskImage:(UIImage *)maskImage;
@end
