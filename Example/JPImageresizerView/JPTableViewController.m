//
//  JPTableViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2017/12/25.
//  Copyright © 2017年 ZhouJianPing. All rights reserved.
//

#import "JPTableViewController.h"
#import "JPImageresizerViewController.h"
#import "JPPhotoViewController.h"
#import "UIAlertController+JPImageresizer.h"

@interface JPTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSURL *tmpURL;
@property (nonatomic, weak) AVAssetExportSession *exporterSession;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, copy) JPExportVideoProgressBlock progressBlock;
@property (nonatomic, assign) BOOL isExporting;
@property (nonatomic, weak) UIButton *openHistoryBtn;
@end

@implementation JPTableViewController

static JPImageresizerConfigure *savedConfigure_ = nil;
+ (void)setSavedConfigure:(JPImageresizerConfigure *)savedConfigure {
    savedConfigure_ = savedConfigure;
}
+ (JPImageresizerConfigure *)savedConfigure {
    return savedConfigure_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Example";
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cameraBtn setImage:[UIImage imageNamed:@"photograph_icon"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(__camera) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
    
    UIButton *openHistoryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    openHistoryBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [openHistoryBtn setTitle:@"继续上次裁剪" forState:UIControlStateNormal];
    [openHistoryBtn addTarget:self action:@selector(__openHistory) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:openHistoryBtn];
    self.openHistoryBtn = openHistoryBtn;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.openHistoryBtn.hidden = self.class.savedConfigure == nil || !self.class.savedConfigure.isSavedHistory;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tmpURL) {
        NSURL *tmpURL = self.tmpURL;
        self.tmpURL = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
        });
    }
}

- (void)dealloc {
    [self __removeProgressTimer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return JPConfigureModel.examplesModels.count;
    } else if (section == 1 || section == 2) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        JPConfigureModel *model = JPConfigureModel.examplesModels[indexPath.row];
        cell.textLabel.text = model.title;
    } else if (indexPath.section == 1) {
        if (indexPath.item == 0) {
            cell.textLabel.text = @"裁剪本地GIF";
        } else {
            cell.textLabel.text = @"裁剪本地视频";
        }
    } else if (indexPath.section == 2) {
        if (indexPath.item == 0) {
            cell.textLabel.text = @"成为吴彦祖";
        } else {
            cell.textLabel.text = @"暂停选老婆";
        }
    } else if (indexPath.section == 3) {
        cell.textLabel.text = @"从系统相册选择";
    } else {
        cell.textLabel.text = @"小红书";
    }
    return cell;
}

#pragma mark - Table view delegate

static JPImageresizerConfigure *gifConfigure_;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        JPConfigureModel *model = JPConfigureModel.examplesModels[indexPath.row];
        model.configure.image = [self __randomImage];
        [self __startImageresizer:model.configure statusBarStyle:model.statusBarStyle];
    } else if (indexPath.section == 1) {
        JPConfigureModel *model = [JPConfigureModel new];
        if (indexPath.item == 0) {
            NSString *gifPath =(arc4random() % 2) ? JPMainBundleResourcePath(@"Gem.gif", nil) : JPMainBundleResourcePath(@"Dilraba.gif", nil);
            BOOL isLoopPlaybackGIF = arc4random() % 2;
            model.title = @"裁剪本地GIF";
            model.statusBarStyle = UIStatusBarStyleLightContent;
            model.configure = [JPImageresizerConfigure defaultConfigureWithImageData:[NSData dataWithContentsOfFile:gifPath] make:^(JPImageresizerConfigure *configure) {
                configure.jp_frameType(JPClassicFrameType);
                configure.jp_isLoopPlaybackGIF(isLoopPlaybackGIF);
            }];
        } else {
            NSString *videoPath = JPMainBundleResourcePath(@"yaorenmao.mov", nil);
            model.title = @"裁剪本地视频";
            model.statusBarStyle = UIStatusBarStyleDefault;
            model.configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithVideoURL:[NSURL fileURLWithPath:videoPath] make:^(JPImageresizerConfigure *configure) {
                configure
                .jp_borderImage(JPConfigureModel.stretchBorderImage)
                .jp_borderImageRectInset(JPConfigureModel.stretchBorderImageRectInset);
            } fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
        }
        [self __startImageresizer:model.configure statusBarStyle:model.statusBarStyle];
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
    } else if (indexPath.section == 3) {
        [self __openAlbum:NO];
    }
}

#pragma mark - 随机图片
- (UIImage *)__randomImage {
    NSString *imageName;
    NSInteger index = 1 + arc4random() % (GirlCount + 2);
    if (index > GirlCount) {
        if (index == GirlCount + 1) {
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
    for (NSInteger i = 1; i <= GirlCount; i++) {
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
            [self __confirmVideo:videoURL];
        }
    } fromVC:self];
}

#pragma mark - 判断视频是否需要修正方向（内部or外部修正）
- (void)__confirmVideo:(NSURL *)videoURL {
    // 校验视频信息
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    // 方向没被修改过，无需修正，直接进入
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (CGAffineTransformEqualToTransform(videoTrack.preferredTransform, CGAffineTransformIdentity)) {
        JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
        [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
        return;
    }
    
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"该视频方向需要先修正" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
#pragma mark 内部修正
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"先进页面再修正" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @jp_weakify(self);
        JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoURL:videoURL make:nil fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
            [JPImageresizerViewController showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
            @jp_strongify(self);
            if (!self) return;
            [self.navigationController popViewControllerAnimated:YES];
        } fixStartBlock:^{
            [JPProgressHUD show];
        } fixProgressBlock:^(float progress) {
            [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"修正方向中...%.0lf%%", progress * 100]];
        } fixCompleteBlock:^(NSURL *cacheURL) {
            [JPProgressHUD dismiss];
        }];
        [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
    }]];
    
#pragma mark 外部修正
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"先修正再进页面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [JPProgressHUD show];
        @jp_weakify(self);
        [JPImageresizerTool fixOrientationVideoWithAsset:videoAsset fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
            
            [JPImageresizerViewController showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
            
            @jp_strongify(self);
            if (!self) return;
            self.isExporting = NO;
            
        } fixStartBlock:^(AVAssetExportSession *exportSession) {
            
            @jp_strongify(self);
            if (!self) return;
            self.isExporting = YES;
            
            [self __addProgressTimer:^(float progress) {
                [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"修正方向中...%.0lf%%", progress * 100] userInteractionEnabled:YES];
            } exporterSession:exportSession];
            
        } fixCompleteBlock:^(NSURL *cacheURL) {
            [JPProgressHUD dismiss];
            
            @jp_strongify(self);
            if (!self) return;
            self.isExporting = NO;
            self.tmpURL = cacheURL; // 保存该路径，裁剪后删除视频。
            
            JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:[AVURLAsset assetWithURL:cacheURL] make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
            [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
        }];
    }]];
    
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)setIsExporting:(BOOL)isExporting {
    if (_isExporting == isExporting) return;
    _isExporting = isExporting;
    if (isExporting) {
        @jp_weakify(self);
        [JPExportCancelView showWithCancelHandler:^{
            @jp_strongify(self);
            if (!self) return;
            [self.exporterSession cancelExport];
        }];
    } else {
        [JPExportCancelView hide];
    }
}

#pragma mark - 开始裁剪
- (void)__startImageresizer:(JPImageresizerConfigure *)configure statusBarStyle:(UIStatusBarStyle)statusBarStyle {
    JPImageresizerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPImageresizerViewController"];
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

- (void)__addProgressTimer:(JPExportVideoProgressBlock)progressBlock exporterSession:(AVAssetExportSession *)exporterSession {
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

#pragma mark - 打开缓存

- (void)__openHistory {
    JPImageresizerConfigure *savedConfigure = self.class.savedConfigure;
    if (!savedConfigure || !savedConfigure.isSavedHistory) {
        self.class.savedConfigure = nil;
        self.openHistoryBtn.hidden = YES;
        return;
    }
    if (!CGRectEqualToRect(savedConfigure.history.viewFrame, [UIScreen mainScreen].bounds)) {
        [JPProgressHUD showInfoWithStatus:@"保存的界面尺寸跟当前不一致" userInteractionEnabled:YES];
        return;
    }
    [self __startImageresizer:savedConfigure statusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - 拍照
- (void)__camera {
    @jp_weakify(self);
    [JPPhotoToolSI cameraAuthorityWithAllowAccessAuthorityHandler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __photograph];
    } refuseAccessAuthorityHandler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __photograph];
    } alreadyRefuseAccessAuthorityHandler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __photograph];
    } canNotAccessAuthorityHandler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __photograph];
    }];
}

- (void)__photograph {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController相关逻辑

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (picker.sourceType != UIImagePickerControllerSourceTypeCamera) return;
    
    // 获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) {
        if (@available(iOS 13.0, *)) {
            NSURL *url = info[UIImagePickerControllerImageURL];
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        }
    }
    
    if (!image) {
        [JPProgressHUD showErrorWithStatus:@"照片获取失败" userInteractionEnabled:YES];
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    @jp_weakify(self);
    [JPPhotoToolSI savePhotoToAppAlbumWithImage:image successHandle:^(NSString *assetID) {
        @jp_strongify(self);
        if (!self) return;
        [picker dismissViewControllerAnimated:YES completion:^{
            JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImage:image make:nil];
            [self __startImageresizer:configure statusBarStyle:UIStatusBarStyleLightContent];
        }];
    } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
        [JPProgressHUD showErrorWithStatus:@"照片获取失败" userInteractionEnabled:YES];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
}


@end
