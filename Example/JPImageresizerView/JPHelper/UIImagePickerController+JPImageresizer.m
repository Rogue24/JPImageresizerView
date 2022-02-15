//
//  UIImagePickerController+JPImageresizer.m
//  JPImageresizerView_Example
//
//  Created by aa on 2022/2/10.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

#import "UIImagePickerController+JPImageresizer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

@interface JPObject : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, copy) void (^replaceHandler)(UIImage *image, NSData *imageData, NSURL *videoURL);
@end

static JPObject *obj_;

@implementation JPObject

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image;
    NSData *imageData;
    NSURL *videoURL;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        if (@available(iOS 11.0, *)) {
            NSURL *url = info[UIImagePickerControllerImageURL];
            imageData = [NSData dataWithContentsOfURL:url];
        } else {
            image = info[UIImagePickerControllerOriginalImage];
        }
    } else {
        videoURL = info[UIImagePickerControllerMediaURL];
        if (!videoURL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            videoURL = info[UIImagePickerControllerReferenceURL];
#pragma clang diagnostic pop
        }
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        if ((image || imageData || videoURL) && self.replaceHandler) self.replaceHandler(image, imageData, videoURL);
        obj_ = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        obj_ = nil;
    }];
}

@end

@implementation UIImagePickerController (JPImageresizer)

+ (void)openAlbum:(void(^)(UIImage *image, NSData *imageData, NSURL *videoURL))handler {
    if (!handler) return;
    obj_ = [JPObject new];
    obj_.replaceHandler = handler;
    
    UIImagePickerController *picker = [self init];
    picker.delegate = obj_;
    NSMutableArray *mediaTypes = @[(NSString *)kUTTypeMovie,
                                   (NSString *)kUTTypeVideo,
                                   (NSString *)kUTTypeImage].mutableCopy;
//    if (@available(iOS 9.0, *)) {
//        [mediaTypes addObject:(NSString *)kUTTypeLivePhoto];
//    }
    picker.mediaTypes = mediaTypes;
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [JPKeyWindow.jp_topViewController presentViewController:picker animated:YES completion:nil];
}

@end



