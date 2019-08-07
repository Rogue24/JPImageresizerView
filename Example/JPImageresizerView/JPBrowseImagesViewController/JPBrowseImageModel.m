//
//  JPBrowseImageModel.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImageModel.h"

@implementation JPBrowseImageModel

- (instancetype)init {
    if (self = [super init]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.maximumScale = 1.0;
    }
    return self;
}

- (void)setPictureFrame:(CGRect)pictureFrame {
    _pictureFrame = pictureFrame;
    if (pictureFrame.size.width <= 0 || pictureFrame.size.height <= 0) {
        self.maximumScale = 2;
    } else {
        if (pictureFrame.size.width > pictureFrame.size.height) {
            self.maximumScale = [UIScreen mainScreen].bounds.size.height / pictureFrame.size.height;
        } else {
            self.maximumScale = [UIScreen mainScreen].bounds.size.width / pictureFrame.size.width;
        }
        if (self.maximumScale < 2) self.maximumScale = 2;
    }
}

@end

@implementation JPPictureInfoModel

@end
