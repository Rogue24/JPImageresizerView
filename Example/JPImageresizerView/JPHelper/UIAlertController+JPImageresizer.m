//
//  UIAlertController+JPImageresizer.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/1/23.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "UIAlertController+JPImageresizer.h"
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
    NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
    if (!mediaURL) {
        if (@available(iOS 11.0, *)) {
            NSURL *url = info[UIImagePickerControllerImageURL];
            imageData = [NSData dataWithContentsOfURL:url];
        } else {
            image = info[UIImagePickerControllerOriginalImage];
        }
    } else {
        videoURL = mediaURL;
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

@implementation UIAlertController (JPImageresizer)

+ (void)changeResizeWHScale:(void(^)(CGFloat resizeWHScale))handler isArbitrarily:(BOOL)isArbitrarily isRoundResize:(BOOL)isRoundResize fromVC:(UIViewController *)fromVC {
    if (!handler) return;
    UIAlertController *alertCtr = [self alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"使用%@", isArbitrarily ? @"固定比例" : @"任意比例"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(-1);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@圆切", isRoundResize ? @"取消" : @""] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(0);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"1 : 1" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(1);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"2 : 3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(2.0 / 3.0);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"3 : 5" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(3.0 / 5.0);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"9 : 16" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(9.0 / 16.0);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"7 : 3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(7.0 / 3.0);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"16 : 9" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(16.0 / 9.0);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [fromVC presentViewController:alertCtr animated:YES completion:nil];
}

+ (void)changeBlurEffect:(void(^)(UIBlurEffect *blurEffect))handler fromVC:(UIViewController *)fromVC {
    if (!handler) return;
    UIAlertController *alertCtr = [self alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"移除模糊效果" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(nil);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"ExtraLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Light" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Dark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]);
    }]];
    if (@available(iOS 10, *)) {
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"Regular" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]);
        }]];
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"Prominent" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]);
        }]];
        
        if (@available(iOS 13, *)) {
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThinMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThickMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemChromeMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThinMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialLight]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialLight]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThickMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialLight]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemChromeMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThinMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThickMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialDark]);
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemChromeMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark]);
            }]];
        }
    }
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [fromVC presentViewController:alertCtr animated:YES completion:nil];
}

+ (void)replaceObj:(void(^)(UIImage *image, NSData *imageData, NSURL *videoURL))handler fromVC:(UIViewController *)fromVC {
    if (!handler) return;
    UIAlertController *alertCtr = [self alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Girl" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger index = 1 + arc4random() % GirlCount;
        NSString *girlImageName = [NSString stringWithFormat:@"Girl%zd.jpg", index];
        handler([UIImage imageNamed:girlImageName], nil, nil);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Kobe" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIImage imageNamed:@"Kobe.jpg"], nil, nil);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Flowers" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIImage imageNamed:@"Flowers.jpg"], nil, nil);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"咬人猫舞蹈节选（视频）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(nil, nil, [NSURL fileURLWithPath:JPMainBundleResourcePath(@"yaorenmao.mov", nil)]);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Gem（GIF）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(nil, [NSData dataWithContentsOfFile:JPMainBundleResourcePath(@"Gem.gif", nil)], nil);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Dilraba（GIF）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(nil, [NSData dataWithContentsOfFile:JPMainBundleResourcePath(@"Dilraba.gif", nil)], nil);
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"系统相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbum:handler fromVC:fromVC];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [fromVC presentViewController:alertCtr animated:YES completion:nil];
}

+ (void)openAlbum:(void (^)(UIImage *, NSData *, NSURL *))handler fromVC:(UIViewController *)fromVC {
    obj_ = [JPObject new];
    obj_.replaceHandler = handler;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = obj_;
    NSMutableArray *mediaTypes = @[(NSString *)kUTTypeMovie,
                                   (NSString *)kUTTypeVideo,
                                   (NSString *)kUTTypeImage].mutableCopy;
//    if (@available(iOS 9.0, *)) {
//        [mediaTypes addObject:(NSString *)kUTTypeLivePhoto];
//    }
    picker.mediaTypes = mediaTypes;
    picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [[UIWindow jp_topViewControllerFromDelegateWindow] presentViewController:picker animated:YES completion:nil];
}

@end
