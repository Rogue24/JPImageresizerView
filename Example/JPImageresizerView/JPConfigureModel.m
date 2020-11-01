//
//  JPConfigureModel.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/11/1.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPConfigureModel.h"

@implementation JPConfigureModel

+ (NSArray<JPConfigureModel *> *)examplesModels {
    static NSArray<JPConfigureModel *> *examplesModels_;
    if (examplesModels_) return examplesModels_;
    
    JPConfigureModel *model1 = [self new];
    model1.title = @"默认样式";
    model1.statusBarStyle = UIStatusBarStyleLightContent;
    model1.configure = [JPImageresizerConfigure defaultConfigureWithImage:nil make:nil];
    
    JPConfigureModel *model2 = [self new];
    model2.title = @"深色毛玻璃遮罩";
    model2.statusBarStyle = UIStatusBarStyleLightContent;
    model2.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:nil];
    
    JPConfigureModel *model3 = [self new];
    model3.title = @"浅色毛玻璃遮罩";
    model3.statusBarStyle = UIStatusBarStyleDefault;
    model3.configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithImage:nil make:nil];
    
    JPConfigureModel *model4 = [self new];
    model4.title = @"拉伸样式的边框图片";
    model4.statusBarStyle = UIStatusBarStyleDefault;
    model4.configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_strokeColor([UIColor colorWithRed:(205.0 / 255.0) green:(107.0 / 255.0) blue:(153.0 / 255.0) alpha:1.0])
        .jp_borderImage(self.class.stretchBorderImage)
        .jp_borderImageRectInset(self.class.stretchBorderImageRectInset);
    }];
    
    JPConfigureModel *model5 = [self new];
    model5.title = @"平铺样式的边框图片";
    model5.statusBarStyle = UIStatusBarStyleLightContent;
    model5.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_frameType(JPClassicFrameType)
        .jp_borderImage(self.class.tileBorderImage)
        .jp_borderImageRectInset(self.class.tileBorderImageRectInset);
    }];
    
    JPConfigureModel *model6 = [self new];
    model6.title = @"圆切样式";
    model6.statusBarStyle = UIStatusBarStyleDefault;
    model6.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_strokeColor(JPRGBColor(250, 250, 250))
        .jp_frameType(JPClassicFrameType)
        .jp_isClockwiseRotation(YES)
        .jp_animationCurve(JPAnimationCurveEaseOut)
        .jp_isRoundResize(YES)
        .jp_isArbitrarily(NO);
    }];
    
    JPConfigureModel *model7 = [self new];
    model7.title = @"蒙版样式";
    model7.statusBarStyle = UIStatusBarStyleLightContent;
    model7.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_frameType(JPClassicFrameType)
        .jp_maskImage([UIImage imageNamed:@"love.png"])
        .jp_isArbitrarily(NO);
    }];
    
    examplesModels_ = @[model1, model2, model3, model4, model5, model6, model7];
    return examplesModels_;
}

+ (UIImage *)stretchBorderImage {
    static UIImage *stretchBorderImage_;
    if (!stretchBorderImage_) {
        UIImage *stretchBorderImage = [UIImage imageNamed:@"real_line"];
        // 裁剪掉上下多余的空白部分
        CGFloat inset = 1.5 * stretchBorderImage.scale;
        CGImageRef sbImageRef = stretchBorderImage.CGImage;
        sbImageRef = CGImageCreateWithImageInRect(sbImageRef, CGRectMake(0, inset, CGImageGetWidth(sbImageRef), CGImageGetHeight(sbImageRef) - 2 * inset));
        stretchBorderImage = [UIImage imageWithCGImage:sbImageRef scale:stretchBorderImage.scale orientation:stretchBorderImage.imageOrientation];
        CGImageRelease(sbImageRef);
        // 设定拉伸区域
        stretchBorderImage_ = [stretchBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    }
    return stretchBorderImage_;
}
+ (CGPoint)stretchBorderImageRectInset {
    return CGPointMake(-2, -2);
}

+ (UIImage *)tileBorderImage {
    static UIImage *tileBorderImage_;
    if (!tileBorderImage_) {
        UIImage *tileBorderImage = [UIImage imageNamed:@"dotted_line"];
        // 设定平铺区域
        tileBorderImage_ = [tileBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];
    }
    return tileBorderImage_;
}
+ (CGPoint)tileBorderImageRectInset {
    return CGPointMake(-1.75, -1.75);
}

@end
