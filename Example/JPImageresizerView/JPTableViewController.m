//
//  JPTableViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2017/12/25.
//  Copyright © 2017年 ZhouJianPing. All rights reserved.
//

#import "JPTableViewController.h"
#import "JPViewController.h"
#import "JPPhotoViewController.h"
#import "UIAlertController+JPImageresizer.h"

@interface JPConfigureModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) JPImageresizerConfigure *configure;
+ (NSArray<JPConfigureModel *> *)testModels;
@end

@implementation JPConfigureModel
+ (NSArray<JPConfigureModel *> *)testModels {
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
    model4.title = @"其他样式";
    model4.statusBarStyle = UIStatusBarStyleDefault;
    model4.configure = [JPImageresizerConfigure defaultConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_maskAlpha(0.5)
        .jp_strokeColor(JPRandomColor)
        .jp_frameType(JPClassicFrameType)
        .jp_bgColor(JPRandomColor)
        .jp_isClockwiseRotation(YES)
        .jp_animationCurve(JPAnimationCurveEaseOut);
    }];
    
    JPConfigureModel *model5 = [self new];
    model5.title = @"自定义边框图片（拉伸模式）";
    model5.statusBarStyle = UIStatusBarStyleDefault;
    model5.configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_strokeColor([UIColor colorWithRed:(205.0 / 255.0) green:(107.0 / 255.0) blue:(153.0 / 255.0) alpha:1.0])
        .jp_borderImage([JPViewController stretchBorderImage])
        .jp_borderImageRectInset([JPViewController stretchBorderImageRectInset]);
    }];
    
    JPConfigureModel *model6 = [self new];
    model6.title = @"自定义边框图片（平铺模式）";
    model6.statusBarStyle = UIStatusBarStyleLightContent;
    model6.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_frameType(JPClassicFrameType)
        .jp_borderImage([JPViewController tileBorderImage])
        .jp_borderImageRectInset([JPViewController tileBorderImageRectInset]);
    }];
    
    JPConfigureModel *model7 = [self new];
    model7.title = @"自定义蒙版图片（固定比例）";
    model7.statusBarStyle = UIStatusBarStyleLightContent;
    model7.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure.jp_maskImage([UIImage imageNamed:@"supreme.png"]);
    }];
    
    JPConfigureModel *model8 = [self new];
    model8.title = @"自定义蒙版图片（任意比例）";
    model8.statusBarStyle = UIStatusBarStyleLightContent;
    model8.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_frameType(JPClassicFrameType)
        .jp_maskImage([UIImage imageNamed:@"love.png"])
        .jp_isArbitrarilyMask(YES);
    }];
    
    NSString *videoPath = JPMainBundleResourcePath(@"yaorenmao.mov", nil);
    JPConfigureModel *model9 = [self new];
    model9.title = @"裁剪本地视频";
    model9.statusBarStyle = UIStatusBarStyleDefault;
    model9.configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithVideoURL:[NSURL fileURLWithPath:videoPath] make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_borderImage([JPViewController stretchBorderImage])
        .jp_borderImageRectInset([JPViewController stretchBorderImageRectInset]);
    } startFixBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
    
    NSString *gifPath = JPMainBundleResourcePath(@"Gem.gif", nil);
    JPConfigureModel *model10 = [self new];
    model10.title = @"裁剪本地GIF";
    model10.statusBarStyle = UIStatusBarStyleLightContent;
    model10.configure = [JPImageresizerConfigure defaultConfigureWithImageData:[NSData dataWithContentsOfFile:gifPath] make:^(JPImageresizerConfigure *configure) {
        configure.jp_frameType(JPClassicFrameType);
    }];
    
    return @[model1, model2, model3, model4, model5, model6, model7, model8, model9, model10];
}
@end

@interface JPTableViewController ()
@property (nonatomic, copy) NSArray<JPConfigureModel *> *models;
@property (nonatomic, weak) AVAssetExportSession *exporterSession;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, copy) JPVideoExportProgressBlock progressBlock;
@end

@implementation JPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Example";
    self.models = [JPConfigureModel testModels];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    [self __removeProgressTimer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.models.count;
    } else if (section == 2) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        JPConfigureModel *model = self.models[indexPath.row];
        cell.textLabel.text = model.title;
    } else {
        if (indexPath.section == 1) {
            cell.textLabel.text = @"用户相册";
        } else {
            if (indexPath.item == 0) {
                cell.textLabel.text = @"成为吴彦祖";
            } else {
                cell.textLabel.text = @"暂停选老婆";
            }
        }
    }
    return cell;
}

#pragma mark - Table view delegate

static JPImageresizerConfigure *gifConfigure_;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        JPConfigureModel *model = self.models[indexPath.row];
        if (!model.configure.image && !model.configure.imageData && !model.configure.videoURL) {
            model.configure.image = [self __randomImage];
        }
        [self __startImageresizer:model.configure statusBarStyle:model.statusBarStyle];
    } else {
        if (indexPath.section == 1) {
            [self __openAlbum:NO];
        } else if (indexPath.section == 2) {
            if (indexPath.item == 0) {
                [self __openAlbum:YES];
            } else {
                if (!gifConfigure_) {
                    [JPProgressHUD show];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        gifConfigure_ = [JPImageresizerConfigure defaultConfigureWithImage:[self __createGIFImage] make:^(JPImageresizerConfigure *configure) {
                            configure.jp_isLoopPlaybackGIF(YES);
                        }];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [JPProgressHUD dismiss];
                            [self __startImageresizer:gifConfigure_ statusBarStyle:UIStatusBarStyleLightContent];
                        });
                    });
                    return;
                }
                [self __startImageresizer:gifConfigure_ statusBarStyle:UIStatusBarStyleLightContent];
            }
        }
    }
}

#pragma mark - 随机图片
- (UIImage *)__randomImage {
    NSString *imageName;
    NSInteger index = 1 + arc4random() % 9;
    if (index > 7) {
        if (index == 8) {
            imageName = @"Kobe.jpg";
        } else {
            imageName = @"Flowers.jpg";
        }
    } else {
        imageName = [NSString stringWithFormat:@"Girl%zd.jpg", index];
    }
    return [UIImage imageWithContentsOfFile:JPMainBundleResourcePath(imageName, nil)];
}

#pragma mark - 生成GIF图片
- (UIImage *)__createGIFImage {
    NSMutableArray *images = [NSMutableArray array];
    CGSize size = CGSizeMake(500, 500);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, bitmapInfo);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    for (NSInteger i = 1; i <= 7; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Girl%zd.jpg", i];
        UIImage *image = [UIImage imageWithContentsOfFile:JPMainBundleResourcePath(imageName, nil)];
        
        CGContextSaveGState(context);
        
        CGImageRef cgImage = image.CGImage;
        CGFloat width;
        CGFloat height;
        if (image.size.width >= image.size.height) {
            width = size.width;
            height = width * (image.size.height / image.size.width);
        } else {
            height = size.height;
            width = height * (image.size.width / image.size.height);
        }
        CGFloat x = (size.width - width) * 0.5;
        CGFloat y = (size.height - height) * 0.5;
        
        CGContextDrawImage(context, CGRectMake(x, y, width, height), cgImage);
        CGImageRef resizedCGImage = CGBitmapContextCreateImage(context);
        [images addObject:[UIImage imageWithCGImage:resizedCGImage]];
        CGImageRelease(resizedCGImage);
        
        CGContextClearRect(context, (CGRect){CGPointZero, size});
        CGContextRestoreGState(context);
    }
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return [UIImage animatedImageWithImages:images duration:JPGIFDuration];
}

#pragma mark - 打开相册
- (void)__openAlbum:(BOOL)isBecomeDanielWu {
    if (isBecomeDanielWu) {
        @jp_weakify(self);
        [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            JPPhotoViewController *vc = [[JPPhotoViewController alloc] init];
            vc.isBecomeDanielWu = isBecomeDanielWu;
            [self.navigationController pushViewController:vc animated:YES];
        } refuseAccessAuthorityHandler:nil alreadyRefuseAccessAuthorityHandler:nil canNotAccessAuthorityHandler:nil isRegisterChange:NO];
        return;
    }
    
    [UIAlertController openAlbum:^(UIImage *image, NSData *imageData, NSURL *videoURL) {
        if (image) {
            JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImage:image make:nil];
            [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
        } else if (imageData) {
            JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImageData:imageData make:nil];
            [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
        } else if (videoURL) {
            [self __confirmVideo:videoURL isConfirmOutSide:YES];
        }
    } fromVC:self];
}

#pragma mark - 判断视频是否需要修正方向
- (void)__confirmVideo:(NSURL *)videoURL isConfirmOutSide:(BOOL)isConfirmOutSide {
    
    
    @jp_weakify(self);
    if (!isConfirmOutSide) {
        
#pragma mark 内部修正（进入页面后修正）
        JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoURL:videoURL make:nil startFixBlock:^{
            [JPProgressHUD show];
        } fixProgressBlock:^(float progress) {
            [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"修正方向中...%.0lf%%", progress * 100]];
        } fixCompleteBlock:^(NSURL *videoURL, BOOL isCanceled) {
            if (videoURL) {
                [JPProgressHUD dismiss];
            } else {
                if (isCanceled) {
                    [JPProgressHUD showInfoWithStatus:@"视频导出已取消" userInteractionEnabled:YES];
                } else {
                    [JPProgressHUD showErrorWithStatus:@"视频修正失败" userInteractionEnabled:YES];
                }
                
                @jp_strongify(self);
                if (!self) return;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
        return;
    }
    
#pragma mark 外部修正（进入页面前修正）
    [JPProgressHUD show];
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
    [videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
        if ([videoAsset statusOfValueForKey:@"duration" error:nil] &&
            [videoAsset statusOfValueForKey:@"tracks" error:nil]) {
            AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (CGAffineTransformEqualToTransform(videoTrack.preferredTransform, CGAffineTransformIdentity)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [JPProgressHUD dismiss];
                    @jp_strongify(self);
                    if (!self) return;
                    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset make:nil startFixBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
                    [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
                });
                return;
            }
            [JPImageresizerTool exportFixOrientationVideoWithAsset:videoAsset exportSessionBlock:^(AVAssetExportSession *exportSession) {
                [weak_self __addProgressTimer:^(float progress) {
                    [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"修正方向中...%.0lf%%", progress * 100]];
                } exporterSession:exportSession];
            } errorBlock:^(NSURL *cacheURL, JPCropErrorReason reason) {
                [JPProgressHUD showErrorWithStatus:@"视频方向修正失败" userInteractionEnabled:YES];
            } completeBlock:^(NSURL *cacheURL) {
                [JPProgressHUD dismiss];
                @jp_strongify(self);
                if (!self) return;
                JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:[AVURLAsset assetWithURL:cacheURL] make:nil startFixBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
                [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [JPProgressHUD showErrorWithStatus:@"视频获取失败" userInteractionEnabled:YES];
            });
        }
    }];
}

#pragma mark - 开始裁剪
- (void)__startImageresizer:(JPImageresizerConfigure *)configure statusBarStyle:(UIStatusBarStyle)statusBarStyle {
    JPViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPViewController"];
    vc.statusBarStyle = statusBarStyle;
    vc.configure = configure;
    
    CATransition *cubeAnim = [CATransition animation];
    cubeAnim.duration = 0.45;
    cubeAnim.type = @"cube";
    cubeAnim.subtype = kCATransitionFromRight;
    cubeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.navigationController.view.layer addAnimation:cubeAnim forKey:@"cube"];
    
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - 监听视频导出进度的定时器

- (void)__addProgressTimer:(JPVideoExportProgressBlock)progressBlock exporterSession:(AVAssetExportSession *)exporterSession {
    [self __removeProgressTimer];
    if (progressBlock == nil || exporterSession == nil) return;
    self.exporterSession = exporterSession;
    self.progressBlock = progressBlock;
    self.progressTimer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(__progressTimerHandle) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)__removeProgressTimer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    self.progressBlock = nil;
    self.exporterSession = nil;
}

- (void)__progressTimerHandle {
    if (self.progressBlock && self.exporterSession) self.progressBlock(self.exporterSession.progress);
}

@end
