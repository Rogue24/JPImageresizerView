//
//  JPViewController.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPViewController.h"
#import "JPImageViewController.h"
#import "UIAlertController+JPImageresizer.h"

@interface JPViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *processBtns;
@property (weak, nonatomic) IBOutlet UIButton *recoveryBtn;
@property (weak, nonatomic) IBOutlet UIButton *resizeBtn;
@property (weak, nonatomic) IBOutlet UIButton *horMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *verMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@property (nonatomic, assign) JPImageresizerFrameType frameType;
@property (nonatomic, strong) UIImage *borderImage;
@property (nonatomic, assign) BOOL isToBeArbitrarily;

@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientation;

@property (weak, nonatomic) IBOutlet UIButton *keepScaleBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnPortraitBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resizeBtnRightConstraint;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *portraitConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeConstraints;
@end

@implementation JPViewController

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
    NSLog(@"viewController is dead");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 初始化

- (void)__setupBase {
    self.view.backgroundColor = self.configure.bgColor;
    self.frameType = self.configure.frameType;
    self.borderImage = self.configure.borderImage;
    self.recoveryBtn.enabled = NO;
    
    // 注意：iOS11以下的系统，所在的controller最好设置automaticallyAdjustsScrollViewInsets为NO，不然就会随导航栏或状态栏的变化产生偏移
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)__setupConstraints {
    self.bottomBtnWidthConstraint.constant = (JPPortraitScreenWidth - JPMargin * 2 - PortraitHorBtnSpace * 3) / 4.0;
    self.bottomBtnPortraitBottomConstraints.constant = JPis_iphoneX ? JPDiffTabBarH : JPStatusBarH;
    
    self.backBtnLeftConstraint.constant = JPMargin;
    self.backBtnTopConstraint.constant = JPStatusBarH;
    
    self.statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
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
    self.configure = nil;
    
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
        
        contentInsets.left += self.keepScaleBtn.jp_width + backBtnLeft;
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
    
    [self.imageresizerView updateFrame:self.view.bounds contentInsets:contentInsets duration:duration];
}

#pragma mark - 按钮点击事件

- (IBAction)changeFrameType:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.borderImage) {
        self.imageresizerView.borderImage = sender.selected ? nil : self.borderImage;
        return;
    } else {
        self.imageresizerView.frameType = sender.selected ? (self.frameType == JPClassicFrameType ? JPConciseFrameType : JPClassicFrameType) : self.frameType;
    }
}

- (IBAction)rotate:(id)sender {
    [self.imageresizerView rotation];
}

- (IBAction)recovery:(id)sender {
    if ([self.imageresizerView isRoundResizing]) {
        [self.imageresizerView recoveryToRoundResize];
        return;
    }
    
    // 1.按当前【resizeWHScale】进行重置
//    [self.imageresizerView recoveryByCurrentResizeWHScale];
    
    // 2.按【initialResizeWHScale】进行重置
    [self.imageresizerView recoveryByInitialResizeWHScale:self.isToBeArbitrarily];
    
    // 3.按【目标裁剪宽高比】进行重置
//    [self.imageresizerView recoveryByTargetResizeWHScale:self.imageresizerView.imageresizeWHScale isToBeArbitrarily:self.isToBeArbitrarily];
}

- (IBAction)resize:(id)sender {
    [JPProgressHUD show];
    
    __weak typeof(self) wSelf = self;
    
    // 1.自定义压缩比例进行裁剪
//    [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
//        // 裁剪完成，resizeImage为裁剪后的图片
//        // 注意循环引用
//        __strong typeof(wSelf) sSelf = wSelf;
//        if (!sSelf) return;
//        [sSelf imageresizerDone:resizeImage];
//    } compressScale:0.5]; // 这里压缩为原图尺寸的50%
    
    // 2.以原图尺寸进行裁剪
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        // 裁剪完成，resizeImage为裁剪后的图片
        // 注意循环引用
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf imageresizerDone:resizeImage];
    }];
}

- (void)imageresizerDone:(UIImage *)resizeImage {
    if (!resizeImage) {
        [JPProgressHUD showErrorWithStatus:@"没有裁剪图片" userInteractionEnabled:YES];
        return;
    }

    [JPProgressHUD dismiss];

    JPImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPImageViewController"];
    vc.image = resizeImage;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pop:(id)sender {
    CATransition *cubeAnim = [CATransition animation];
    cubeAnim.duration = 0.5;
    cubeAnim.type = @"cube";
    cubeAnim.subtype = kCATransitionFromLeft;
    cubeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.window.layer addAnimation:cubeAnim forKey:@"cube"];
    
    if (self.navigationController.viewControllers.count <= 1) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (IBAction)lockFrame:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.imageresizerView.isLockResizeFrame = sender.selected;
}

- (IBAction)verMirror:(id)sender {
    self.imageresizerView.verticalityMirror = !self.imageresizerView.verticalityMirror;
}

- (IBAction)horMirror:(id)sender {
    self.imageresizerView.horizontalMirror = !self.imageresizerView.horizontalMirror;
}

- (IBAction)previewAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.imageresizerView.isPreview = sender.selected;
}

- (IBAction)toBeArbitrarilyAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.isToBeArbitrarily = sender.selected;
    [self.imageresizerView setResizeWHScale:self.imageresizerView.resizeWHScale isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
}
- (IBAction)changeResizeWHScale:(id)sender {
    [UIAlertController changeResizeWHScale:^(CGFloat resizeWHScale) {
        if (resizeWHScale < 0) {
            [self.imageresizerView roundResize:YES];
        } else {
            [self.imageresizerView setResizeWHScale:resizeWHScale isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
        }
    } fromVC:self];
}

- (IBAction)changeBlurEffect:(id)sender {
    [UIAlertController changeBlurEffect:^(UIBlurEffect *blurEffect) {
        self.imageresizerView.blurEffect = blurEffect;
    } fromVC:self];
}

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
}

- (IBAction)replaceImage:(UIButton *)sender {
    [UIAlertController replaceRandomImage:^(UIImage *image) {
        self.imageresizerView.resizeImage = image;
    } fromVC:self];
}

@end
