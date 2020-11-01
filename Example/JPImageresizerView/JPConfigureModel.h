//
//  JPConfigureModel.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/11/1.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPConfigureModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) JPImageresizerConfigure *configure;

+ (NSArray<JPConfigureModel *> *)examplesModels;

+ (UIImage *)stretchBorderImage;
+ (CGPoint)stretchBorderImageRectInset;

+ (UIImage *)tileBorderImage;
+ (CGPoint)tileBorderImageRectInset;
@end

