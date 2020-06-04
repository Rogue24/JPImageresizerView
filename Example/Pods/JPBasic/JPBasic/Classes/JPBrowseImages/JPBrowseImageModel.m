//
//  JPBrowseImageModel.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImageModel.h"
#import "JPInline.h"

@implementation JPBrowseImageModel

- (instancetype)init {
    if (self = [super init]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.imageSize = CGSizeZero;
    }
    return self;
}

- (void)setImageSize:(CGSize)imageSize {
    _imageSize = imageSize;
    
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        _imageWhScale = 1;
        _contentSize = CGSizeMake(JPPortraitScreenWidth, JPPortraitScreenWidth);
        CGFloat verInset = JPHalfOfDiff(JPPortraitScreenHeight, JPPortraitScreenWidth);
        _contentInset = UIEdgeInsetsMake(verInset, 0, verInset, 0);
        _maximumScale = 1;
    } else {
        _imageWhScale = imageSize.width / imageSize.height;
        _contentSize = CGSizeMake(JPPortraitScreenWidth, JPPortraitScreenWidth / _imageWhScale);
        
        CGFloat topInset = JPHalfOfDiff(JPPortraitScreenHeight, _contentSize.height);
        CGFloat bottomInset = topInset;
        if (topInset < JPStatusBarH) topInset = JPStatusBarH;
        if (bottomInset < JPDiffTabBarH) bottomInset = JPDiffTabBarH;
        _contentInset = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
        
        _maximumScale = (JPPortraitScreenHeight - JPStatusBarH - JPDiffTabBarH) / _contentSize.height;
        if (_maximumScale < 2) _maximumScale = 2;
    }
}

@end
