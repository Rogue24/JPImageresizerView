//
//  JPPhotoViewModel.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPPhotoViewModel.h"

@implementation JPPhotoViewModel

- (instancetype)initWithAsset:(PHAsset *)asset {
    if (self = [super init]) {
        self.asset = asset;
    }
    return self;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    _jp_whScale = 1.0 * asset.pixelWidth / asset.pixelHeight;
    
    CGFloat bigWidth = [UIScreen mainScreen].bounds.size.width;
    _bigPhotoSize = CGSizeMake(bigWidth, bigWidth / _jp_whScale);
    
    CGFloat originWidth = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
    _originPhotoSize = CGSizeMake(originWidth, originWidth / _jp_whScale);
}

- (void)setJp_itemFrame:(CGRect)jp_itemFrame {
    _jp_itemFrame = jp_itemFrame;
    CGFloat width = jp_itemFrame.size.width * 2;
    _abbPhotoSize = CGSizeMake(width, width / _jp_whScale);
}

@end
