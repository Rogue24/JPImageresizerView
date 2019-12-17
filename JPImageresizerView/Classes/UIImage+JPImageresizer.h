//
//  UIImage+JPImageresizer.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JPImageresizer)

+ (UIImage *)jpir_resultImageWithImage:(UIImage *)originImage
                             cropFrame:(CGRect)cropFrame
                         relativeWidth:(CGFloat)relativeWidth
                           isVerMirror:(BOOL)isVerMirror
                           isHorMirror:(BOOL)isHorMirror
                     rotateOrientation:(UIImageOrientation)orientation
                           isRoundClip:(BOOL)isRoundClip
                         compressScale:(CGFloat)scale;

@end
