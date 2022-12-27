//
//  UIImagePickerController+JPImageresizer.h
//  JPImageresizerView_Example
//
//  Created by aa on 2022/2/10.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImagePickerController (JPImageresizer)

+ (void)openAlbum:(void(^)(UIImage *image, NSData *imageData, NSURL *videoURL))handler;

@end

NS_ASSUME_NONNULL_END
