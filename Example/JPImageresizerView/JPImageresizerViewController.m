//
//  JPImageresizerViewController.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPImageresizerViewController.h"
#import "UIAlertController+JPImageresizer.h"
#import "JPPreviewViewController.h"
#import "DanielWuViewController.h"
#import "ShapeListViewController.h"
#import "JPTableViewController.h"

@interface JPImageresizerViewController ()
@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientation;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *processBtns;
@property (weak, nonatomic) IBOutlet UIButton *recoveryBtn;
@property (weak, nonatomic) IBOutlet UIButton *resizeBtn;
@property (weak, nonatomic) IBOutlet UIButton *horMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *verMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;

@property (nonatomic, assign) JPImageresizerFrameType frameType;
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic, assign) BOOL isToBeArbitrarily;

@property (weak, nonatomic) IBOutlet UIButton *replaceMaskImgBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnPortraitBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resizeBtnRightConstraint;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *portraitConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeConstraints;

@property (nonatomic, assign) BOOL isExporting;
@end

@implementation JPImageresizerViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupBase];
    [self __setupConstraints];
    [self __setupImageresizerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:(self.statusBarStyle == UIStatusBarStyleDefault ? UIStatusBarStyleDarkContent : UIStatusBarStyleLightContent) animated:YES];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:YES];
    }
}

- (void)dealloc {
    JPLog(@"viewController is dead");
    JPRemoveNotification(self);
}

#pragma mark - 初始化

- (void)__setupBase {
    self.view.backgroundColor = self.configure.bgColor;
    
    // 注意：iOS11以下的系统，所在的controller最好设置automaticallyAdjustsScrollViewInsets为NO，不然就会随导航栏或状态栏的变化产生偏移
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.frameType = self.configure.frameType;
    self.maskImage = self.configure.maskImage;
    self.recoveryBtn.enabled = NO;
}

- (void)__setupConstraints {
    self.bottomBtnWidthConstraint.constant = (JPPortraitScreenWidth - JPMargin * 2 - PortraitHorBtnSpace * 3) / 4.0;
    self.bottomBtnPortraitBottomConstraints.constant = JPis_iphoneX ? JPDiffTabBarH : JPStatusBarH;
    
    self.backBtnLeftConstraint.constant = JPMargin;
    self.backBtnTopConstraint.constant = JPStatusBarH;
    
    self.statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    JPObserveNotification(self, @selector(didChangeStatusBarOrientation), UIApplicationDidChangeStatusBarOrientationNotification, nil);
}

- (void)__setupImageresizerView {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(JPMargin, JPMargin, JPMargin, JPMargin);
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        contentInsets.left += 96;
        contentInsets.right += self.bottomBtnWidthConstraint.constant;
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
            contentInsets.left += JPStatusBarH;
            contentInsets.right += JPDiffTabBarH;
        } else {
            contentInsets.left += JPDiffTabBarH;
            contentInsets.right += JPStatusBarH;
        }
        contentInsets.top = JPDiffTabBarH;
        contentInsets.bottom = JPDiffTabBarH;
    } else {
        contentInsets.top += JPStatusBarH + ButtonHeight;
        contentInsets.bottom += ButtonHeight * 2 + 15 + (JPis_iphoneX ? JPDiffTabBarH : JPStatusBarH);
    }
    self.configure.contentInsets = contentInsets;
    self.configure.viewFrame = [UIScreen mainScreen].bounds;
    
    __weak typeof(self) wSelf = self;
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:self.configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        // 当不需要重置设置按钮不可点
        sSelf.recoveryBtn.enabled = isCanRecovery;
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        // 当预备缩放设置按钮不可点，结束后可点击
        BOOL enabled = !isPrepareToScale;
        sSelf.rotateBtn.enabled = enabled;
        sSelf.resizeBtn.enabled = enabled;
        sSelf.horMirrorBtn.enabled = enabled;
        sSelf.verMirrorBtn.enabled = enabled;
    }];
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
    
    // initialResizeWHScale默认为初始化时的resizeWHScale，此后可自行修改initialResizeWHScale的值
    // self.imageresizerView.initialResizeWHScale = 16.0 / 9.0; // 可随意修改该参数
    
    // 调用recoveryByInitialResizeWHScale方法进行重置，则resizeWHScale会重置为initialResizeWHScale的值
    // 调用recoveryByCurrentResizeWHScale方法进行重置，则resizeWHScale不会被重置
    // 调用recoveryByResizeWHScale:方法进行重置，可重置为任意resizeWHScale
}

#pragma mark - 监听屏幕旋转

- (void)didChangeStatusBarOrientation {
    [self setStatusBarOrientation:[UIApplication sharedApplication].statusBarOrientation
                         duration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration];
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)statusBarOrientation {
    [self setStatusBarOrientation:statusBarOrientation duration:0];
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)statusBarOrientation duration:(NSTimeInterval)duration {
    if (_statusBarOrientation == statusBarOrientation) return;
    _statusBarOrientation = statusBarOrientation;
    
    float portraitPriority;
    float landscapePriority;
    CGFloat backBtnLeft;
    CGFloat backBtnTop;
    CGFloat resizeBtnRight;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(JPMargin, JPMargin, JPMargin, JPMargin);
    
    if (statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
        statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        portraitPriority = 1;
        landscapePriority = 999;
        backBtnTop = JPMargin;
        
        if (statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            backBtnLeft = JPStatusBarH;
            resizeBtnRight = JPDiffTabBarH;
        } else {
            backBtnLeft = JPDiffTabBarH;
            resizeBtnRight = JPStatusBarH;
        }
        
        contentInsets.left += self.replaceMaskImgBtn.jp_width + backBtnLeft;
        contentInsets.right += self.bottomBtnWidthConstraint.constant + resizeBtnRight;
        contentInsets.top = JPDiffTabBarH;
        contentInsets.bottom = JPDiffTabBarH;
    } else {
        portraitPriority = 999;
        landscapePriority = 1;
        backBtnLeft = JPMargin;
        resizeBtnRight = JPMargin;
        
        if (statusBarOrientation == UIInterfaceOrientationPortrait) {
            backBtnTop = JPStatusBarH;
        } else {
            backBtnTop = JPDiffTabBarH;
        }
        
        contentInsets.top += JPStatusBarH + ButtonHeight;
        contentInsets.bottom += ButtonHeight * 2 + 15 + (JPis_iphoneX ? JPDiffTabBarH : JPStatusBarH);
    }
    for (NSLayoutConstraint *constraint in self.portraitConstraints) {
        constraint.priority = portraitPriority;
    }
    for (NSLayoutConstraint *constraint in self.landscapeConstraints) {
        constraint.priority = landscapePriority;
    }
    self.backBtnLeftConstraint.constant = backBtnLeft;
    self.backBtnTopConstraint.constant = backBtnTop;
    self.resizeBtnRightConstraint.constant = resizeBtnRight;
    
    if (duration) {
        UIViewAnimationOptions options;
        switch (self.imageresizerView.animationCurve) {
            case JPAnimationCurveEaseInOut:
                options = UIViewAnimationOptionCurveEaseInOut;
                break;
            case JPAnimationCurveEaseIn:
                options = UIViewAnimationOptionCurveEaseIn;
                break;
            case JPAnimationCurveEaseOut:
                options = UIViewAnimationOptionCurveEaseOut;
                break;
            case JPAnimationCurveLinear:
                options = UIViewAnimationOptionCurveLinear;
                break;
        }
        
        self.navigationController.view.clipsToBounds = NO;
        self.imageresizerView.clipsToBounds = NO;
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.navigationController.view.clipsToBounds = YES;
            self.imageresizerView.clipsToBounds = YES;
        }];
    } else {
        [self.view layoutIfNeeded];
    }
    
    // 横竖屏切换
    [self.imageresizerView updateFrame:[UIScreen mainScreen].bounds contentInsets:contentInsets duration:duration];
}

#pragma mark - 按钮点击事件

#pragma mark 返回
static UIViewController *tmpVC_;
- (IBAction)pop:(id)sender {
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"将此次裁剪保留？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"不保留" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (JPTableViewController.savedConfigure == self.configure) {
            JPTableViewController.savedConfigure = nil;
        }
        [self goback];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"保留" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        JPTableViewController.savedConfigure = [self.imageresizerView saveCurrentConfigure];
        [self goback];
    }]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}
- (void)goback {
    if (self.backBlock) {
        self.backBlock(self);
        return;
    }
    
    CATransition *cubeAnim = [CATransition animation];
    cubeAnim.duration = 0.45;
    cubeAnim.type = @"cube";
    cubeAnim.subtype = kCATransitionFromLeft;
    cubeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.navigationController.view.layer addAnimation:cubeAnim forKey:@"cube"];
    
    tmpVC_ = self; // 晚一些再死，不然视频画面会立即消失
    if (self.navigationController.viewControllers.count <= 1) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tmpVC_ = nil;
    });
}

#pragma mark 设置蒙版图片
- (IBAction)replaceMaskImage:(UIButton *)sender {
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"蒙版素材列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @jp_weakify(self);
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:[ShapeListViewController shapeListViewController:^(UIImage *shapeImage) {
            @jp_strongify(self);
            if (!self) return;
            self.imageresizerView.maskImage = shapeImage;
        }]];
        if (@available(iOS 13.0, *)) {
            navCtr.modalPresentationStyle = UIModalPresentationPageSheet;
        } else {
            navCtr.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self presentViewController:navCtr animated:YES completion:nil];
    }]];
    
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"love" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.maskImage = [UIImage imageNamed:@"love.png"];
    }]];
    
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Supreme" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.maskImage = [UIImage imageNamed:@"supreme.png"];
    }]];
    
    if (self.isBecomeDanielWu) {
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"DanielWu-Face" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.imageresizerView.maskImage = self.maskImage;
        }]];
    }
    
    if (self.imageresizerView.maskImage) {
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"移除蒙版" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            self.imageresizerView.maskImage = nil;
        }]];
    }
    
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark 预览
- (IBAction)previewAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.imageresizerView.isPreview = sender.selected;
}

#pragma mark 按垂直线镜像
- (IBAction)verMirror:(id)sender {
    self.imageresizerView.verticalityMirror = !self.imageresizerView.verticalityMirror;
}

#pragma mark 按水平线镜像
- (IBAction)horMirror:(id)sender {
    self.imageresizerView.horizontalMirror = !self.imageresizerView.horizontalMirror;
}

#pragma mark 锁定裁剪框（不能拖拽）
- (IBAction)lockFrame:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.imageresizerView.isLockResizeFrame = sender.selected;
}

#pragma mark 更换边框样式
- (IBAction)changeFrameType:(UIButton *)sender {
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (self.imageresizerView.isGIF) {
        [alertCtr addAction:[UIAlertAction actionWithTitle:(self.imageresizerView.isLoopPlaybackGIF ? @"GIF自主选择" : @"GIF自动播放") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.imageresizerView.isLoopPlaybackGIF = !self.imageresizerView.isLoopPlaybackGIF;
        }]];
    }
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"简洁样式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.borderImage = nil;
        self.imageresizerView.frameType = JPConciseFrameType;
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"经典样式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.borderImage = nil;
        self.imageresizerView.frameType = JPClassicFrameType;
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"拉伸的边框图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.borderImageRectInset = JPConfigureModel.stretchBorderImageRectInset;
        self.imageresizerView.borderImage = [JPConfigureModel stretchBorderImage];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"平铺的边框图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.borderImageRectInset = JPConfigureModel.tileBorderImageRectInset;
        self.imageresizerView.borderImage = [JPConfigureModel tileBorderImage];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark 旋转
- (IBAction)rotate:(id)sender {
    [self.imageresizerView rotation];
}

#pragma mark 重置
- (IBAction)recovery:(id)sender {
    [self.imageresizerView recovery];
}

#pragma mark 设置宽高比
- (IBAction)changeResizeWHScale:(id)sender {
    [UIAlertController changeResizeWHScale:^(CGFloat resizeWHScale) {
        if (resizeWHScale < 0) {
            self.imageresizerView.isArbitrarily = !self.imageresizerView.isArbitrarily;
        } else if (resizeWHScale == 0) {
            self.imageresizerView.isRoundResize = !self.imageresizerView.isRoundResize;
        } else {
            self.imageresizerView.resizeWHScale = resizeWHScale;
        }
    } isArbitrarily:self.imageresizerView.isArbitrarily isRoundResize:self.imageresizerView.isRoundResize fromVC:self];
}

#pragma mark 设置毛玻璃
- (IBAction)changeBlurEffect:(id)sender {
    [UIAlertController changeBlurEffect:^(UIBlurEffect *blurEffect) {
        self.imageresizerView.blurEffect = blurEffect;
    } fromVC:self];
}

#pragma mark 随机颜色（边框、背景、遮罩透明度）
- (IBAction)changeRandomColor:(id)sender {
    CGFloat maskAlpha = (CGFloat)JPRandomNumber(0, 10) / 10.0;
    UIColor *strokeColor;
    UIColor *bgColor;
    if (@available(iOS 13, *)) {
        UIColor *strokeColor1 = JPRandomColor;
        UIColor *strokeColor2 = JPRandomColor;
        strokeColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return strokeColor1;
            } else {
                return strokeColor2;
            }
        }];
        UIColor *bgColor1 = JPRandomColor;
        UIColor *bgColor2 = JPRandomColor;
        bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return bgColor1;
            } else {
                return bgColor2;
            }
        }];
    } else {
        strokeColor = JPRandomColor;
        bgColor = JPRandomColor;
    }
    [self.imageresizerView setupStrokeColor:strokeColor blurEffect:self.imageresizerView.blurEffect bgColor:bgColor maskAlpha:maskAlpha animated:YES];
    
    // 随机网格数
    self.imageresizerView.gridCount = JPRandomNumber(2, 20);
}

#pragma mark 更换素材
- (IBAction)replace:(UIButton *)sender {
    [UIAlertController replaceObj:^(UIImage *image, NSData *imageData, NSURL *videoURL) {
        if (image) {
            self.imageresizerView.image = image;
        } else if (imageData) {
            self.imageresizerView.imageData = imageData;
        } else if (videoURL) {
            @jp_weakify(self);
            [self.imageresizerView setVideoURL:videoURL animated:YES fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                weak_self.isExporting = NO;
                [self.class showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
            } fixStartBlock:^{
                [JPProgressHUD show];
            } fixProgressBlock:^(float progress) {
                weak_self.isExporting = YES;
                [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"修正方向中...%.0lf%%", progress * 100] userInteractionEnabled:YES];
            } fixCompleteBlock:^(NSURL *cacheURL) {
                weak_self.isExporting = NO;
                [JPProgressHUD dismiss];
            }];
        }
    } fromVC:self];
}

#pragma mark 裁剪
- (IBAction)resize:(id)sender {
    @jp_weakify(self);
    
    // 裁剪视频
    if (self.imageresizerView.videoURL) {
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"裁剪当前帧画面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [JPProgressHUD show];
            [self.imageresizerView cropVideoCurrentFrameWithCacheURL:nil errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                @jp_strongify(self);
                if (!self) return;
                [self.class showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
            } completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
                @jp_strongify(self);
                if (!self) return;
                [self __imageresizerDone:finalImage cacheURL:cacheURL];
            }];
        }]];
        [alertCtr addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"截取%.0lf秒为GIF", JPCutGIFDuration] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [JPProgressHUD show];
            [self.imageresizerView cropVideoToGIFFromCurrentSecondWithDuration:JPCutGIFDuration cacheURL:[self __cacheURL:@"gif"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                @jp_strongify(self);
                if (!self) return;
                [self.class showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
            } completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
                @jp_strongify(self);
                if (!self) return;
                [self __imageresizerDone:finalImage cacheURL:cacheURL];
            }];
        }]];
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"裁剪视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self __cropVideo];
        }]];
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertCtr animated:YES completion:nil];
        return;
    }
    
    // 裁剪GIF
    if (self.imageresizerView.isGIF) {
        void (^cropGIF)(void) = ^{
            [JPProgressHUD show];
            [self.imageresizerView cropGIFWithCacheURL:[self __cacheURL:@"gif"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                @jp_strongify(self);
                if (!self) return;
                [self.class showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
            } completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
                // 裁剪完成，finalImage为裁剪后的图片
                // 注意循环引用
                @jp_strongify(self);
                if (!self) return;
                [self __imageresizerDone:finalImage cacheURL:cacheURL];
            }];
        };
        if (self.imageresizerView.isLoopPlaybackGIF) {
            cropGIF();
        } else {
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"裁剪当前帧画面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [JPProgressHUD show];
                [self.imageresizerView cropGIFCurrentIndexWithCacheURL:nil errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                    @jp_strongify(self);
                    if (!self) return;
                    [self.class showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
                } completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
                    // 裁剪完成，finalImage为裁剪后的图片
                    // 注意循环引用
                    @jp_strongify(self);
                    if (!self) return;
                    [self __imageresizerDone:finalImage cacheURL:cacheURL];
                }];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"裁剪GIF" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                cropGIF();
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertCtr animated:YES completion:nil];
        }
        return;
    }
    
    // 裁剪图片
    [JPProgressHUD show];
    [self.imageresizerView cropPictureWithCacheURL:[self __cacheURL:@"jpeg"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
        @jp_strongify(self);
        if (!self) return;
        [self.class showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
    } completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
        // 裁剪完成，finalImage为裁剪后的图片
        // 注意循环引用
        @jp_strongify(self);
        if (!self) return;
        [self __imageresizerDone:finalImage cacheURL:cacheURL];
    }];
}

#pragma mark - 以当前时间戳生成缓存路径

- (NSURL *)__cacheURL:(NSString *)extension {
    NSString *fileName = [NSString stringWithFormat:@"%.0lf.%@", [[NSDate date] timeIntervalSince1970], extension];
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:cachePath];
}

#pragma mark - 图片裁剪完成

- (void)__imageresizerDone:(UIImage *)finalImage cacheURL:(NSURL *)cacheURL {
    if (!finalImage && !cacheURL) {
        [JPProgressHUD showErrorWithStatus:@"裁剪失败" userInteractionEnabled:YES];
        return;
    }
    [JPProgressHUD dismiss];
    if (self.isBecomeDanielWu) {
        DanielWuViewController *vc = [DanielWuViewController DanielWuVC:finalImage];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        JPPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPPreviewViewController"];
        if (cacheURL) {
            vc.imageURL = cacheURL;
        } else {
            vc.image = finalImage;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 裁剪视频

- (void)__cropVideo {
    [JPProgressHUD show];
    @jp_weakify(self);
    [self.imageresizerView cropVideoWithCacheURL:[self __cacheURL:@"mov"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
        weak_self.isExporting = NO;
        [self.class showErrorMsg:reason pathExtension:[cacheURL pathExtension]];
    } progressBlock:^(float progress) {
        // 监听进度
        weak_self.isExporting = YES;
        [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"%.0f%%", progress * 100] userInteractionEnabled:YES];
    } completeBlock:^(NSURL *cacheURL) {
        // 裁剪完成
        [JPProgressHUD dismiss];
        
        @jp_strongify(self);
        if (!self) return;
        self.isExporting = NO;
        
        JPPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPPreviewViewController"];
        vc.videoURL = cacheURL;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)setIsExporting:(BOOL)isExporting {
    if (_isExporting == isExporting) return;
    _isExporting = isExporting;
    if (isExporting) {
        @jp_weakify(self);
        [JPExportCancelView showWithCancelHandler:^{
            @jp_strongify(self);
            if (!self) return;
            [self.imageresizerView videoCancelExport];
        }];
    } else {
        [JPExportCancelView hide];
    }
}

#pragma mark - 打印错误信息
+ (void)showErrorMsg:(JPImageresizerErrorReason)reason pathExtension:(NSString *)pathExtension {
    switch (reason) {
        case JPIEReason_NilObject:
            [JPProgressHUD showErrorWithStatus:@"资源为空" userInteractionEnabled:YES];
            break;
        case JPIEReason_CacheURLAlreadyExists:
            [JPProgressHUD showErrorWithStatus:@"缓存路径已存在其他文件" userInteractionEnabled:YES];
            break;
        case JPIEReason_NoSupportedFileType:
            [JPProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"“%@” 不支持的文件格式", pathExtension] userInteractionEnabled:YES];
            break;
        case JPIEReason_VideoAlreadyDamage:
            [JPProgressHUD showErrorWithStatus:@"视频文件已损坏" userInteractionEnabled:YES];
            break;
        case JPIEReason_VideoExportFailed:
            [JPProgressHUD showErrorWithStatus:@"视频导出失败" userInteractionEnabled:YES];
            break;
        case JPIEReason_VideoExportCancelled:
            [JPProgressHUD showInfoWithStatus:@"视频导出取消" userInteractionEnabled:YES];
            break;
    }
}

@end
