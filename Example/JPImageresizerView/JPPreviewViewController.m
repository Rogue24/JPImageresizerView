//
//  JPPreviewViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2018/1/2.
//  Copyright © 2018年 ZhouJianPing. All rights reserved.
//

#import "JPPreviewViewController.h"
#import "JPImageresizerResult.h"
#import "JPPhotoTool.h"
#import "JPImageresizerSlider.h"
#import "JPDynamicPage.h"

@interface JPPreviewViewController ()
@property (nonatomic, weak) JPDynamicPage *dp;

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, copy) NSArray<UIImageView *> *fragmentImageViews;

@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id timeObserver;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) JPImageresizerSlider *slider;

@property (nonatomic, copy) NSArray<JPImageresizerResult *> *results;
@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, assign) NSInteger rowCount;
@end

@implementation JPPreviewViewController
{
    BOOL _isDidAppear;
    NSInteger _changeOrientationTag;
}

- (void)setColumnCount:(NSInteger)columnCount {
    _columnCount = columnCount <= 0 ? 1 : columnCount;
}

- (void)setRowCount:(NSInteger)rowCount {
    _rowCount = rowCount <= 0 ? 1 : rowCount;
}

#pragma mark - 工厂

+ (instancetype)buildWithResult:(JPImageresizerResult *)result {
    return [self buildWithResults:@[result] columnCount:1 rowCount:1];
}

+ (instancetype)buildWithResults:(NSArray<JPImageresizerResult *> *)results
                     columnCount:(NSInteger)columnCount
                        rowCount:(NSInteger)rowCount {
    JPPreviewViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JPPreviewViewController"];
    vc.results = results;
    vc.columnCount = columnCount;
    vc.rowCount = rowCount;
    return vc;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Finish";
    self.view.backgroundColor = JPRandomColor;
    
    [self __setupNavigationBar];
    [self __setupDynamicPage];
    [self __changBgColor];
    
    if (self.results.count > 0) {
        if (self.results.firstObject.type == JPImageresizerResult_Video) {
            [self __setupPlayerLayer];
            [self __setupSlider];
        } else {
            [self __setupImageView];
        }
    }
    
    JPObserveNotification(self, @selector(__didChangeStatusBarOrientation), UIApplicationDidChangeStatusBarOrientationNotification, nil);
    [self __didChangeStatusBarOrientation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
#pragma clang diagnostic pop
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.dp startAnimation];
    
    if (_isDidAppear) return;
    _isDidAppear = YES;
    
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dp stopAnimation];
    [self __removeFragmentAnimation];
}

- (void)dealloc {
    JPLog(@"imageViewController is dead");
    
    if (self.playerLayer) {
        JPRemoveNotification(self);
        [self.playerLayer removeFromSuperlayer];
        if (self.timeObserver) {
            [self.player removeTimeObserver:self.timeObserver];
            self.timeObserver = nil;
        }
    }

    NSArray *results = self.results.copy;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < results.count; i++) {
            JPImageresizerResult *result = results[i];
            NSString *typeName;
            switch (result.type) {
                case JPImageresizerResult_Image:
                    typeName = @"图片";
                    break;
                case JPImageresizerResult_GIF:
                    typeName = @"GIF";
                    break;
                case JPImageresizerResult_Video:
                    typeName = @"视频";
                    break;
            }
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtURL:result.cacheURL error:&error];
            if (error) {
                JPLog(@"删除%@文件失败 %zd: %@ --- %@", typeName, i, result.cacheURL.absoluteString, error);
            } else {
                JPLog(@"已删除%@文件 %zd", typeName, i);
            }
        }
    });
}

#pragma mark - 初始布局

- (void)__setupNavigationBar {
    UIButton *camceraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    camceraBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [camceraBtn setTitle:@"保存相册" forState:UIControlStateNormal];
    [camceraBtn addTarget:self action:@selector(__savePhotoToAppAlbum) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:camceraBtn];
}

- (void)__setupDynamicPage {
    JPDynamicPage *dp = [JPDynamicPage dynamicPage];
    [self.view insertSubview:dp atIndex:0];
    self.dp = dp;
}

- (void)__setupPlayerLayer {
    JPImageresizerResult *result = self.results.firstObject;
    AVURLAsset *asset = [AVURLAsset assetWithURL:result.cacheURL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    self.playerLayer = playerLayer;
    self.player = player;
    
    @jp_weakify(self);
    self.timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @jp_strongify(self);
        if (!self) return;
        self.slider.second = CMTimeGetSeconds(time);
    }];
    
    JPObserveNotification(self, @selector(__playDidEnd), AVPlayerItemDidPlayToEndTimeNotification, item);
}

- (void)__setupSlider {
    @jp_weakify(self);
    JPImageresizerSlider *slider = [JPImageresizerSlider imageresizerSlider:CMTimeGetSeconds(self.player.currentItem.asset.duration) second:0];
    slider.sliderBeginBlock = ^(float second, float totalSecond) {
        @jp_strongify(self);
        if (!self) return;
        [self.player pause];
    };
    slider.sliderDragingBlock = ^(float second, float totalSecond) {
        @jp_strongify(self);
        if (!self) return;
        [self.player seekToTime:CMTimeMakeWithSeconds(second, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    };
    slider.sliderEndBlock = ^(float second, float totalSecond) {
        @jp_strongify(self);
        if (!self) return;
        [self.player play];
    };
    [self.view addSubview:slider];
    self.slider = slider;
}

- (void)__setupImageView {
    self.toolbar.hidden = YES;
    
    if (self.results.count == 0) return;
    
    if (self.results.count == 1) {
        JPImageresizerResult *result = self.results.firstObject;
        
        NSData *data = [NSData dataWithContentsOfURL:result.cacheURL];
        UIImage *image = result.image;
        if (!image) image = [UIImage imageWithData:data];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        self.imageView = imageView;
        
        if (data && [JPImageresizerTool isGIFData:data]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [JPImageresizerTool decodeGIFData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView transitionWithView:self.imageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        self.imageView.image = image;
                    } completion:nil];
                });
            });
        }
        return;
    }
    
    NSMutableArray<UIImageView *> *fragmentImageViews = [NSMutableArray array];
    for (NSInteger i = 1; i < self.results.count; i++) {
        JPImageresizerResult *result = self.results[i];
        
        UIImage *image = result.image;
        if (!image) image = [UIImage imageWithData:[NSData dataWithContentsOfURL:result.cacheURL]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.view addSubview:imageView];
        [fragmentImageViews addObject:imageView];
    }
    
    self.fragmentImageViews = fragmentImageViews;
}

#pragma mark - 通知方法

- (void)__didChangeStatusBarOrientation {
    _changeOrientationTag += 1;
    
    [self.dp updateFrame:JPScreenBounds];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(JPNavBarH + JPMargin, JPMargin, JPDiffTabBarH + JPMargin, JPMargin);
    BOOL isLandscape = JPScreenWidth > JPScreenHeight;
    if (isLandscape) {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
            contentInsets.left += JPStatusBarH;
            contentInsets.right += JPDiffTabBarH;
        } else {
            contentInsets.left += JPDiffTabBarH;
            contentInsets.right += JPStatusBarH;
        }
    } else {
        contentInsets.top += JPStatusBarH;
    }
    CGFloat x = contentInsets.left;
    CGFloat y = contentInsets.top;
    CGFloat w = JPScreenWidth - contentInsets.left - contentInsets.right;
    CGFloat h = JPScreenHeight - contentInsets.top - contentInsets.bottom;
    
    if (self.playerLayer) {
        if (!isLandscape) h -= JPNavBarH;
        [self.slider setImageresizerFrame:CGRectMake(x, y, w, h) isRoundResize:NO];
        h -= [JPImageresizerSlider viewHeight];
        self.playerLayer.frame = CGRectMake(x, y, w, h);
        return;
    }
    
    if (self.imageView) {
        self.imageView.frame = CGRectMake(x, y, w, h);
        return;
    }
    
    [self __removeFragmentAnimation];
    if (self.fragmentImageViews.count == 0) return;
    
    JPImageresizerResult *result = self.results.firstObject;
    UIImage *image = result.image;
    if (!image) image = [UIImage imageWithData:[NSData dataWithContentsOfURL:result.cacheURL]];
    
    CGFloat imgViewX = x;
    CGFloat imgViewY = y;
    CGFloat imgViewW = w;
    CGFloat imgViewH = h;
    
    if (isLandscape) {
        imgViewW = h * (image.size.width / image.size.height);
        if (imgViewW > w) {
            imgViewW = w;
            imgViewH = w * (image.size.height / image.size.width);
            imgViewY += JPHalfOfDiff(h, imgViewH);
        } else {
            imgViewX += JPHalfOfDiff(w, imgViewW);
        }
    } else {
        imgViewH = w * (image.size.height / image.size.width);
        if (imgViewH > h) {
            imgViewH = h;
            imgViewW = h * (image.size.width / image.size.height);
            imgViewX += JPHalfOfDiff(w, imgViewW);
        } else {
            imgViewY += JPHalfOfDiff(h, imgViewH);
        }
    }
    
    imgViewW /= (CGFloat)self.columnCount;
    imgViewH /= (CGFloat)self.rowCount;
    
    for (NSInteger i = 0; i < self.fragmentImageViews.count; i++) {
        CGFloat x = imgViewX + (i % self.columnCount) * imgViewW;
        CGFloat y = imgViewY + (i / self.columnCount) * imgViewH;
        UIImageView *imageView = self.fragmentImageViews[i];
        imageView.frame = CGRectMake(x, y, imgViewW, imgViewH);
    }
    
    NSInteger changeOrientationTag = _changeOrientationTag;
    @jp_weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @jp_strongify(self);
        if (!self || changeOrientationTag != self->_changeOrientationTag) return;
        [self __addFragmentAnimation];
    });
}

- (void)__playDidEnd {
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player pause];
}

#pragma mark - 私有方法

- (void)__changBgColor {
    @jp_weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @jp_strongify(self);
        if (!self) return;
        [self.view jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewBackgroundColor toValue:JPRandomColor duration:2.0 completionBlock:^(POPAnimation *anim, BOOL finished) {
            @jp_strongify(self);
            if (!self) return;
            [self __changBgColor];
        }];
    });
}

- (void)__removeFragmentAnimation {
    for (NSInteger i = 0; i < self.fragmentImageViews.count; i++) {
        UIImageView *imageView = self.fragmentImageViews[i];
        [imageView.layer pop_removeAllAnimations];
        imageView.layer.transform = CATransform3DIdentity;
    }
}

- (void)__addFragmentAnimation {
    CGFloat d = JPMargin * 0.5;
    for (NSInteger i = 0; i < self.fragmentImageViews.count; i++) {
        if (i == 4) continue;
        
        CGFloat tx = 0;
        CGFloat ty = 0;
        switch (i) {
            case 0:
                tx = -d;
                ty = -d;
                break;
            case 1:
                ty = -d;
                break;
            case 2:
                tx = d;
                ty = -d;
                break;
                
            case 3:
                tx = -d;
                break;
            case 5:
                tx = d;
                break;
                
            case 6:
                tx = -d;
                ty = d;
                break;
            case 7:
                ty = d;
                break;
            case 8:
                tx = d;
                ty = d;
                break;
                
            default:
                break;
        }
        
        POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
        anim.toValue = @(CGPointMake(tx, ty));
        anim.duration = 1;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.autoreverses = YES;
        anim.repeatForever = YES;
        
        UIImageView *imageView = self.fragmentImageViews[i];
        [imageView.layer pop_addAnimation:anim forKey:kPOPLayerTranslationXY];
    }
}

#pragma mark - 事件触发方法

- (void)__savePhotoToAppAlbum {
    if (self.results.count == 0) return;
    
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    dispatch_queue_t serialQueue = dispatch_queue_create("save_queue", DISPATCH_QUEUE_SERIAL);
    __block NSInteger successCount = 0;
    
    [JPProgressHUD show];
    for (NSInteger i = 0; i < self.results.count; i++) {
        JPImageresizerResult *result = self.results[i];
        dispatch_async(serialQueue, ^{
            if (result.cacheURL) {
                if (result.type == JPImageresizerResult_Video) {
                    [JPPhotoToolSI saveVideoToAppAlbumWithFileURL:result.cacheURL successHandle:^(NSString *assetID) {
                        successCount += 1;
                        dispatch_semaphore_signal(lock);
                    } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                        dispatch_semaphore_signal(lock);
                    }];
                } else {
                    [JPPhotoToolSI saveFileToAppAlbumWithFileURL:result.cacheURL successHandle:^(NSString *assetID) {
                        successCount += 1;
                        dispatch_semaphore_signal(lock);
                    } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                        dispatch_semaphore_signal(lock);
                    }];
                }
                dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            } else if (result.image) {
                [JPPhotoToolSI savePhotoToAppAlbumWithImage:result.image successHandle:^(NSString *assetID) {
                    successCount += 1;
                    dispatch_semaphore_signal(lock);
                } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                    dispatch_semaphore_signal(lock);
                }];
                dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            }
        });
    }
    
    dispatch_async(serialQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successCount == self.results.count) {
                [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled: YES];
            } else if (successCount == 0) {
                [JPProgressHUD showErrorWithStatus:@"保存失败" userInteractionEnabled:YES];
            } else {
                [JPProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"保存成功：%zd，保存失败：%zd", successCount, self.results.count - successCount] userInteractionEnabled:YES];
            }
        });
    });
}

- (IBAction)play:(id)sender {
    [self.player play];
}

- (IBAction)pause:(id)sender {
    [self.player pause];
}

@end
