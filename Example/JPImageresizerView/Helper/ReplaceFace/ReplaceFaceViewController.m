//
//  ReplaceFaceViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/6/20.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "ReplaceFaceViewController.h"
#import <JPImageresizerView_Example-Swift.h>

@implementation ReplaceFaceViewController

- (instancetype)initWithPersonImage:(UIImage *)personImage faceImages:(NSArray<UIImage *> *)faceImages {
    if (self = [super init]) {
        self.personImage = personImage;
        self.faceImages = faceImages;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupNavigationBar];
    [self __setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
#pragma clang diagnostic pop
    
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    JPLog(@"%@ is dead", self.class);
}

#pragma mark - 初始布局

- (void)__setupNavigationBar {
    UIButton *replaceImgBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setTitle:@"替换背景" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(__replacePersonImage) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    UIButton *synthesizeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setTitle:@"合成" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(__synthesizeImages) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithCustomView:synthesizeBtn],
        [[UIBarButtonItem alloc] initWithCustomView:replaceImgBtn]
    ];
}

- (void)__setupSubviews {
    self.view.backgroundColor = UIColor.blackColor;
    
    if (self.personImage) {
        CGFloat w = JPPortraitScreenWidth;
        CGFloat h = w * (self.personImage.size.height / self.personImage.size.width);
        CGFloat x = 0;
        CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight, h);
        UIImageView *personView = ({
            UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
            aImgView.image = self.personImage;
            aImgView;
        });
        [self.view addSubview:personView];
        self.personView = personView;
        
        if (self.faceImages.count > 0) {
            CGFloat scale = JPPortraitScreenWidth / self.personImage.size.width;
            w = (567.0 - 152.0 - 166.0) * scale;
            h = w * (300.0 / 263.0);
            x = self.personView.jp_x + JPHalfOfDiff(self.personView.jp_width, w);
            y = self.personView.jp_y + JPHalfOfDiff(self.personView.jp_height, h);
            
            NSMutableArray *faceViews = [NSMutableArray array];
            @jp_weakify(self);
            for (UIImage *faceImage in self.faceImages) {
                FaceView *faceView = [[FaceView alloc] initWithFrame:CGRectMake(x, y, w, h) image:faceImage longPressAction:^(UIImage *image) {
                    @jp_strongify(self);
                    if (!self) return;
                    [self __saveFaceImage:image];
                }];
                [self.view addSubview:faceView];
                [faceViews addObject:faceView];
                x += 10;
                y += 10;
            }
            self.faceViews = faceViews.copy;
        }
    }
}

#pragma mark - 保存脸模图片

- (void)__saveFaceImage:(UIImage *)faceImage {
    UIAlertController *alertCtr = [UIAlertController build:UIAlertControllerStyleActionSheet title:@"是否保存脸模到相册" message:nil];
    [alertCtr addAction:@"保存" handler:^{
        [JPProgressHUD show];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *folderPath = NSTemporaryDirectory();
            NSString *fileName = [NSString stringWithFormat:@"%.0lf.png", [[NSDate date] timeIntervalSince1970]];
            NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            
            // 📢 注意：苹果保存时默认使用占用磁盘空间小的图片格式（有损且不含alpha通道的jpeg格式）。
            // 想保存有透明度的图片，需要手动用代码将图片转化为png格式后（这样苹果才不进行此优化）再保存。
            NSData *imageData = UIImagePNGRepresentation(faceImage);
            if (!imageData || ![imageData writeToURL:fileURL atomically:YES]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [JPProgressHUD showErrorWithStatus:@"保存失败" userInteractionEnabled:YES];
                });
                return;
            }
            
            [JPPhotoToolSI saveFileToAppAlbumWithFileURL:fileURL successHandle:^(NSString *assetID) {
                [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
                [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
            } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
                [JPProgressHUD showErrorWithStatus:@"保存失败" userInteractionEnabled:YES];
            }];
        });
    }];
    [alertCtr addCancel:@"取消" handler:nil];
    [alertCtr presentFrom:self];
}

#pragma mark - 合成图片

- (void)__synthesizeImages {
    [JPProgressHUD show];
    
    UIImage *personImage = self.personView.image;
    CGRect rect = CGRectMake(0, 0, floorl(self.personView.frame.size.width), floorl(self.personView.frame.size.height));
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, JPScreenScale);
        [personImage drawInRect:rect];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        for (FaceView *faceView in self.faceViews) {
            UIImage *faceImage = faceView.faceImage;
            if (!faceImage) continue;
            
            CGImageRef faceImageRef = [self __imageDownMirrored:faceImage].CGImage;
            
            // 将当前图形状态推入堆栈
            CGContextSaveGState(context);
            
            __block CGFloat faceRadian;
            __block CGFloat faceScale;
            __block CGRect faceBounds;
            __block CGPoint faceOrigin;
            dispatch_sync(dispatch_get_main_queue(), ^{
                faceRadian = faceView.layer.jp_radian;
                faceScale = faceView.layer.jp_scaleX;
                faceBounds = faceView.layer.bounds;
                faceOrigin = [faceView convertPoint:CGPointZero toView:self.personView];
            });
            
            // 要先进行位移，确定好位置后再进行其他的形变操作，否则位置错乱。
            CGContextTranslateCTM(context, faceOrigin.x, faceOrigin.y);
            CGContextScaleCTM(context, faceScale, faceScale);
            CGContextRotateCTM(context, faceRadian);
            
            CGContextDrawImage(context, faceBounds, faceImageRef);
            
            // 把堆栈顶部的状态弹出，返回到之前的图形状态
            CGContextRestoreGState(context);
        }
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];
            JPPreviewViewController *vc = [JPPreviewViewController buildWithResult:[[JPImageresizerResult alloc] initWithImage:resultImage cacheURL:nil]];
            [self.navigationController pushViewController:vc animated:YES];
        });
    });
}

#pragma mark - 私有方法

- (UIImage *)__imageDownMirrored:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    CGRect bounds = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(0.0, bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -bounds.size.height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), bounds, imageRef);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)__replacePersonImage {
    __weak typeof(self) wSelf = self;
    [self.class openAlbumForImageWithCompletion:^(UIImage *image) {
        if (!wSelf || image == nil) return;
        __strong typeof(wSelf) sSelf = wSelf;
        
        sSelf.personImage = image;
        
        CGFloat w = JPPortraitScreenWidth;
        CGFloat h = w * (image.size.height / image.size.width);
        CGFloat x = 0;
        CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight, h);
        
        [UIView transitionWithView:sSelf.personView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            sSelf.personView.image = image;
        } completion:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            sSelf.personView.frame = CGRectMake(x, y, w, h);
        }];
    }];
}

@end
