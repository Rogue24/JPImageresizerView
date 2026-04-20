//
//  JPImageresizerViewController.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPImageresizerViewController.h"
#import <JPImageresizerView_Example-Swift.h>
#import <ScreenRotator/JPScreenRotator.h>
#import "DanielWuViewController.h"
#import "ShapeListViewController.h"

@interface JPImageresizerViewController ()
@property (nonatomic, assign) JPScreenOrientation orientation;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@property (weak, nonatomic) IBOutlet UIButton *replaceMaskImgBtn;
@property (weak, nonatomic) IBOutlet UIButton *horMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *verMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *processBtns;
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;
@property (weak, nonatomic) IBOutlet UIButton *recoveryBtn;
@property (weak, nonatomic) IBOutlet UIButton *resizeBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnPortraitBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resizeBtnRightConstraint;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *portraitConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *landscapeConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewRightConstraint; // 原本与旧父视图相关的约束
@property (nonatomic, strong) NSLayoutConstraint *topViewRightNewConstraint; // 更替与新父视图相关的约束
@property (nonatomic, strong) NSLayoutConstraint *topViewBottomConstraint; // 新增与新父视图相关的约束

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLeftConstraint; // 原本与旧父视图相关的约束
@property (nonatomic, strong) NSLayoutConstraint *bottomViewLeftNewConstraint; // 更替与新父视图相关的约束
@property (nonatomic, strong) NSLayoutConstraint *bottomViewTopConstraint; // 新增与新父视图相关的约束

@property (nonatomic, assign) BOOL isExporting;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIVisualEffect *bgEffect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) CGFloat maskAlpha;
@property (readonly) BOOL isGlassMask;
@end

@implementation JPImageresizerViewController

#pragma mark - getter

- (UIImage *)glassMaskImage {
    return [UIImage glassMaskImage];
}

- (BOOL)isGlassMask {
    UIImage *maskImage = self.imageresizerView.maskImage;
    return maskImage && self.glassMaskImage == maskImage;
}

#pragma mark - 生命周期

+ (instancetype)buildWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle configure:(JPImageresizerConfigure *)configure {
    JPImageresizerViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JPImageresizerViewController"];
    vc.statusBarStyle = statusBarStyle;
    vc.configure = configure;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupBase];
    [self __setupConstraints];
    [self __setupImageresizerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:YES];
#pragma clang diagnostic pop
}

- (void)dealloc {
    JPLog(@"viewController is dead");
    JPRemoveNotification(self);
}

#pragma mark - 初始化

- (void)__setupBase {
    self.view.backgroundColor = self.configure.mainAppearance.bgColor;
    
    // 注意：iOS11以下的系统，所在的controller最好设置automaticallyAdjustsScrollViewInsets为NO，不然就会随导航栏或状态栏的变化产生偏移
    if (@available(iOS 11.0, *)) {
        
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
}

- (void)__setupConstraints {
    self.bottomBtnWidthConstraint.constant = (JPPortraitScreenWidth - JPMargin * 2 - PortraitHorBtnSpace * 3) / 4.0;
    self.bottomBtnPortraitBottomConstraints.constant = JPis_iphoneX ? JPDiffTabBarH : JPStatusBarH;
    
    // 由于topView和bottomView转移了父视图（operationView -> operationView.container），
    // 因此需要将与旧父视图相关的约束，重新对新父视图进行配置。
    // 👇🏻👇🏻👇🏻
    
    // 使旧约束失效（等价于从旧父视图里remove掉该约束）
    self.topViewRightConstraint.active = NO;
    // 手动创建相同新约束代替旧约束
    self.topViewRightNewConstraint = [self.topView.trailingAnchor constraintEqualToAnchor:self.topView.superview.trailingAnchor constant:0];
    // 手动创建其他新约束
    self.topViewBottomConstraint = [self.topView.bottomAnchor constraintEqualToAnchor:self.topView.superview.bottomAnchor constant:0];
    
    // 使旧约束失效（等价于从旧父视图里remove掉该约束）
    self.bottomViewLeftConstraint.active = NO;
    // 手动创建相同新约束代替旧约束
    self.bottomViewLeftNewConstraint = [self.bottomView.leadingAnchor constraintEqualToAnchor:self.bottomView.superview.leadingAnchor constant:0];
    // 手动创建其他新约束
    self.bottomViewTopConstraint = [self.bottomView.topAnchor constraintEqualToAnchor:self.bottomView.superview.topAnchor constant:0];
    
    // 确定当前屏幕方向，同时ta的settet方法会设置好约束值
    _orientation = -1;
    self.orientation = [JPScreenRotator sharedInstance].orientation;
    
    // 使手动创建的新约束生效
    self.topViewRightNewConstraint.active = YES;
    self.topViewBottomConstraint.active = YES;
    self.bottomViewLeftNewConstraint.active = YES;
    self.bottomViewTopConstraint.active = YES;
    
    // 监听屏幕方向变化
    JPObserveNotification(self, @selector(orientationDidChange), JPScreenRotatorOrientationDidChangeNotification, nil);
}

- (void)__setupImageresizerView {
    self.configure.contentInsets = self.contentInsets;
    self.configure.viewFrame = [UIScreen mainScreen].bounds;
    
    @jp_weakify(self);
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:self.configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
        @jp_strongify(self);
        if (!self) return;
        // 当不需要重置设置按钮不可点
        self.recoveryBtn.enabled = isCanRecovery;
        /**
         *【1.10.2】改动：`isCanRecovery`仅针对[旋转]、[缩放]、[镜像]的变化情况，
         * 其他如裁剪宽高比的变化情况需另行判定能否重置，例如可补上：
            if (!isCanRecovery) {
              self.recoveryBtn.enabled = self.imageresizerView.resizeWHScale == self.imageresizerView.initialResizeWHScale;
            }
         */
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        @jp_strongify(self);
        if (!self) return;
        // 当预备缩放设置按钮不可点，结束后可点击
        BOOL enabled = !isPrepareToScale;
        self.rotateBtn.enabled = enabled;
        self.resizeBtn.enabled = enabled;
        self.horMirrorBtn.enabled = enabled;
        self.verMirrorBtn.enabled = enabled;
    }];
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
    
    // initialResizeWHScale默认为初始化时的resizeWHScale，此后可自行修改initialResizeWHScale的值
    // self.imageresizerView.initialResizeWHScale = 16.0 / 9.0; // 可随意修改该参数
    
    // 调用recoveryByInitialResizeWHScale方法进行重置，则resizeWHScale会重置为initialResizeWHScale的值
    // 调用recoveryByCurrentResizeWHScale方法进行重置，则resizeWHScale不会被重置
    // 调用recoveryByResizeWHScale:方法进行重置，可重置为任意resizeWHScale
    
    // 配置重置按钮
    self.recoveryBtn.enabled = self.imageresizerView.isCanRecovery;
    
    // 蒙版图片处理
    self.imageresizerView.maskImageDisplayHandler = ^UIImage *(UIImage *originMaskImage) {
        @jp_strongify(self);
        if (!self || self.isGlassMask) return originMaskImage; // 玻璃蒙版不处理
        return [JPImageresizerTool convertToAlphaInvertedBlackMaskImage:originMaskImage];
    };
}

#pragma mark - 监听屏幕旋转

- (void)orientationDidChange {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
#pragma clang diagnostic pop
    [self setOrientation:[JPScreenRotator sharedInstance].orientation duration:duration > 0 ? duration : 0.3];
}

- (void)setOrientation:(JPScreenOrientation)orientation {
    [self setOrientation:orientation duration:0];
}

- (void)setOrientation:(JPScreenOrientation)orientation duration:(NSTimeInterval)duration {
    if (_orientation == orientation) return;
    _orientation = orientation;
    
    BOOL isPortrait = orientation == JPScreenOrientationPortrait;
    
    float portraitPriority;
    float landscapePriority;
    CGFloat backBtnLeft;
    CGFloat backBtnTop;
    CGFloat resizeBtnRight;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(JPMargin, JPMargin, JPMargin, JPMargin);
    // 竖屏
    if (isPortrait) {
        portraitPriority = 999;
        landscapePriority = 1;
        backBtnLeft = JPMargin;
        resizeBtnRight = JPMargin;
        
        if (orientation == JPScreenOrientationPortrait) {
            backBtnTop = JPStatusBarH;
        } else {
            backBtnTop = JPDiffTabBarH > 0 ? JPDiffTabBarH : JPMargin;
        }
        
        contentInsets.top += JPStatusBarH + ButtonHeight;
        contentInsets.bottom += ButtonHeight * 2 + 15 + (JPis_iphoneX ? JPDiffTabBarH : JPStatusBarH);
    }
    // 横屏
    else {
        portraitPriority = 1;
        landscapePriority = 999;
        backBtnTop = JPMargin;
        
        if (orientation == JPScreenOrientationLandscapeLeft) {
            backBtnLeft = JPStatusBarH;
            resizeBtnRight = JPDiffTabBarH > 0 ? JPDiffTabBarH : JPMargin;
        } else {
            backBtnLeft = JPDiffTabBarH > 0 ? JPDiffTabBarH : JPMargin;
            resizeBtnRight = JPStatusBarH;
        }
        
        contentInsets.left += self.replaceMaskImgBtn.jp_width + backBtnLeft;
        contentInsets.right += self.bottomBtnWidthConstraint.constant + resizeBtnRight;
        contentInsets.top = contentInsets.bottom = JPDiffTabBarH > 0 ? JPDiffTabBarH : JPMargin;
    }
    
    self.topViewRightNewConstraint.priority = portraitPriority;
    self.topViewBottomConstraint.priority = landscapePriority;
    
    self.bottomViewLeftNewConstraint.priority = portraitPriority;
    self.bottomViewTopConstraint.priority = landscapePriority;
    
    for (NSLayoutConstraint *constraint in self.portraitConstraints) {
        constraint.priority = portraitPriority;
    }
    for (NSLayoutConstraint *constraint in self.landscapeConstraints) {
        constraint.priority = landscapePriority;
    }
    
    self.backBtnLeftConstraint.constant = backBtnLeft;
    self.backBtnTopConstraint.constant = backBtnTop;
    self.resizeBtnRightConstraint.constant = resizeBtnRight;
    
    self.contentInsets = contentInsets;
    
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
    
    //「横竖屏切换」
    if (!self.imageresizerView) return;
    CGRect frame = isPortrait ? JPPortraitScreenBounds : JPLandscapeScreenBounds;
    [self.imageresizerView updateFrame:frame contentInsets:contentInsets duration:duration];
}

#pragma mark - 按钮点击事件

#pragma mark 返回
static UIViewController *tmpVC_;
- (IBAction)pop:(id)sender {
    @jp_weakify(self);
    UIAlertController *alertCtr = [UIAlertController build:UIAlertControllerStyleAlert title:@"将此次裁剪保留？" message:nil];
    [alertCtr addAction:@"保留" handler:^{
        @jp_strongify(self);
        if (!self) return;
        [JPExampleListViewController cacheConfigure:[self.imageresizerView saveCurrentConfigure] statusBarStyle:self.statusBarStyle];
        [self goback];
    }];
    [alertCtr addDestructive:@"不保留" handler:^{
        @jp_strongify(self);
        if (!self) return;
        [JPExampleListViewController cleanConfigure:self.configure];
        [self goback];
    }];
    [alertCtr presentFrom:self];
}

- (void)goback {
    if (self.backBlock) {
        self.backBlock(self);
        return;
    }
    
    // TODO: 在iOS26中cube动画效果有问题，不会覆盖整个要push的界面（大概只一半），等后续修复吧。
//    CATransition *cubeAnim = [CATransition animation];
//    cubeAnim.duration = 0.45;
//    cubeAnim.type = @"cube";
//    cubeAnim.subtype = kCATransitionFromLeft;
//    cubeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [self.navigationController.view.layer addAnimation:cubeAnim forKey:@"cube"];
    
    tmpVC_ = self; // 晚一些再死，不然视频画面会立即消失
    if (self.navigationController.viewControllers.count <= 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tmpVC_ = nil;
    });
}

#pragma mark 设置蒙版图片
- (IBAction)replaceMaskImage:(UIButton *)sender {
    [UIAlertController changeMaskImage:^(UIImage * _Nullable maskImage) {
        [self __removeGlassMask];
        self.imageresizerView.maskImage = maskImage;
    } gotoMaskImageList:^{
        @jp_weakify(self);
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:[ShapeListViewController shapeListViewController:^(UIImage *shapeImage) {
            @jp_strongify(self);
            if (!self) return;
            [self __removeGlassMask];
            self.imageresizerView.maskImage = shapeImage;
        }]];
        if (@available(iOS 13.0, *)) {
            navCtr.modalPresentationStyle = UIModalPresentationPageSheet;
        } else {
            navCtr.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self presentViewController:navCtr animated:YES completion:nil];
    } isCanRemoveMaskImage:(self.imageresizerView.maskImage != nil) fromVC:self];
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
    @jp_weakify(self);
    UIAlertController *alertCtr = [UIAlertController build:UIAlertControllerStyleActionSheet title:nil message:nil];
    
    if (self.imageresizerView.isGIF) {
        [alertCtr addAction:(self.imageresizerView.isLoopPlaybackGIF ? @"GIF可控进度" : @"GIF自动播放") handler:^{
            @jp_strongify(self);
            if (!self) return;
            self.imageresizerView.isLoopPlaybackGIF = !self.imageresizerView.isLoopPlaybackGIF;
        }];
    }
    
    if (@available(iOS 26.0, *)) {
        [alertCtr addAction:@"玻璃样式" handler:^{
            @jp_strongify(self);
            if (!self) return;
            [self __addGlassMask];
        }];
    }
    
    [alertCtr addAction:@"简洁样式" handler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __removeGlassMask];
        self.imageresizerView.borderImage = nil;
        self.imageresizerView.frameType = JPConciseFrameType;
        self.imageresizerView.isShowGridlinesWhenIdle = NO;
        self.imageresizerView.isShowGridlinesWhenDragging = YES;
    }];
    
    [alertCtr addAction:@"经典样式" handler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __removeGlassMask];
        self.imageresizerView.borderImage = nil;
        self.imageresizerView.frameType = JPClassicFrameType;
        self.imageresizerView.isShowGridlinesWhenIdle = NO;
        self.imageresizerView.isShowGridlinesWhenDragging = YES;
    }];
    
    [alertCtr addAction:@"拉伸的边框图片" handler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __removeGlassMask];
        self.imageresizerView.borderImageRectInset = UIImage.stretchBorderRectInset;
        self.imageresizerView.borderImage = [UIImage getStretchBorderImage];
        self.imageresizerView.isShowGridlinesWhenIdle = NO;
        self.imageresizerView.isShowGridlinesWhenDragging = YES;
    }];
    
    [alertCtr addAction:@"平铺的边框图片" handler:^{
        @jp_strongify(self);
        if (!self) return;
        [self __removeGlassMask];
        self.imageresizerView.borderImageRectInset = UIImage.tileBorderRectInset;
        self.imageresizerView.borderImage = [UIImage getTileBorderImage];
        self.imageresizerView.isShowGridlinesWhenIdle = NO;
        self.imageresizerView.isShowGridlinesWhenDragging = YES;
    }];
    
    if (!self.isReplaceFace) {
        [alertCtr addAction:@"九宫格风格" handler:^{
            @jp_strongify(self);
            if (!self) return;
            [self __removeGlassMask];
            self.imageresizerView.maskImage = nil;
            self.imageresizerView.borderImage = nil;
            self.imageresizerView.frameType = JPClassicFrameType;
            self.imageresizerView.resizeWHScale = 1;
            self.imageresizerView.gridCount = 3;
            self.imageresizerView.isShowGridlinesWhenIdle = YES;
            self.imageresizerView.isShowGridlinesWhenDragging = YES;
        }];
    }
    
    [alertCtr addCancel:@"取消" handler:nil];
    [alertCtr presentFrom:self];
}

- (void)__addGlassMask {
    if (self.isGlassMask) return;
    
    self.strokeColor = self.imageresizerView.mainAppearance.strokeColor;
    self.bgEffect = self.imageresizerView.mainAppearance.bgEffect;
    self.bgColor = self.imageresizerView.mainAppearance.bgColor;
    self.maskAlpha = self.imageresizerView.mainAppearance.maskAlpha;
    
    if (@available(iOS 26.0, *)) {
        UIGlassEffect *glassEffect = [UIGlassEffect effectWithStyle:UIGlassEffectStyleClear];
        JPImageresizerAppearance *appearance = [[JPImageresizerAppearance alloc] initWithStrokeColor:nil bgEffect:glassEffect bgColor:[UIColor clearColor] maskAlpha:0];
        [self.imageresizerView setMaskImage:self.glassMaskImage
                             maskAppearance:appearance
                          isToBeArbitrarily:YES
                                   animated:YES];
    }
    
    [self.imageresizerView updateMainAppearance:^(JPImageresizerAppearance *appearance) {
        appearance.strokeColor = [UIColor clearColor];
        appearance.bgEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
        appearance.bgColor = [UIColor blackColor];
    } animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.imageresizerView.borderImage = nil;
        self.imageresizerView.resizeCornerRadius = 20;
    });
}

- (void)__removeGlassMask {
    if (!self.isGlassMask) return;
    self.imageresizerView.maskImage = nil;
    [self.imageresizerView updateMainAppearance:^(JPImageresizerAppearance *appearance) {
        appearance.strokeColor = self.strokeColor;
        appearance.bgEffect = self.bgEffect;
        appearance.bgColor = self.bgColor;
        appearance.maskAlpha = self.maskAlpha;
    } animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.imageresizerView.resizeCornerRadius = 0;
    });
}

#pragma mark 旋转
- (IBAction)rotate:(id)sender {
    [UIAlertController rotation:^(BOOL isClockwise) {
        self.imageresizerView.isClockwiseRotation = isClockwise;
        [self.imageresizerView rotation];
    } toDirection:^(JPImageresizerRotationDirection direction) {
        [self.imageresizerView rotationToDirection:direction];
    } fromVC:self];
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
    [UIAlertController changeEffect:^(UIVisualEffect *effect) {
        [self.imageresizerView updateMainAppearance:^(JPImageresizerAppearance *appearance) {
            appearance.bgEffect = effect;
        } animated:YES];
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
    
    [self.imageresizerView updateMainAppearance:^(JPImageresizerAppearance *appearance) {
        appearance.strokeColor = strokeColor;
        appearance.bgColor = bgColor;
        appearance.maskAlpha = maskAlpha;
    } animated:YES];
    
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
                [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
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
    
    // 裁剪是否忽略蒙版图片（玻璃蒙版不处理）
    self.imageresizerView.ignoresMaskImageForCrop = self.isGlassMask;
    
    // 裁剪视频
    if (self.imageresizerView.videoURL) {
        UIAlertController *alertCtr = [UIAlertController build:UIAlertControllerStyleActionSheet title:nil message:nil];
        [alertCtr addAction:@"裁剪当前帧画面" handler:^{
            @jp_strongify(self);
            if (!self) return;
            [JPProgressHUD show];
            [self.imageresizerView cropVideoCurrentFrameWithCacheURL:nil errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
            } completeBlock:^(JPImageresizerResult *result) {
                @jp_strongify(self);
                if (!self) {
                    [JPProgressHUD dismiss];
                    return;
                }
                [self __imageresizerDoneWithResult:result];
            }];
        }];
        [alertCtr addAction:[NSString stringWithFormat:@"从当前时间开始截取%.0lf秒为GIF", JPCutGIFDuration] handler:^{
            @jp_strongify(self);
            if (!self) return;
            [JPProgressHUD show];
            [self.imageresizerView cropVideoToGIFFromCurrentSecondWithDuration:JPCutGIFDuration cacheURL:[self __cacheURL:@"gif"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
            } completeBlock:^(JPImageresizerResult *result) {
                @jp_strongify(self);
                if (!self) {
                    [JPProgressHUD dismiss];
                    return;
                }
                [self __imageresizerDoneWithResult:result];
            }];
        }];
        [alertCtr addAction:@"裁剪整个视频" handler:^{
            @jp_strongify(self);
            if (!self) return;
            [self __cropVideo:0];
        }];
        [alertCtr addAction:[NSString stringWithFormat:@"裁剪视频并从当前时间开始截取%.0lf秒片段", JPCutVideoDuration] handler:^{
            @jp_strongify(self);
            if (!self) return;
            [self __cropVideo:JPCutVideoDuration];
        }];
        [alertCtr addCancel:@"取消" handler:nil];
        [alertCtr presentFrom:self];
        return;
    }
    
    // 裁剪GIF
    if (self.imageresizerView.isGIF) {
        void (^cropGIF)(void) = ^{
            [JPProgressHUD show];
            // compressScale：压缩比例
            // isReverseOrder：是否倒放
            // rate：速率
            [self.imageresizerView cropGIFWithCompressScale:1 isReverseOrder:NO rate:1 cacheURL:[self __cacheURL:@"gif"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
            } completeBlock:^(JPImageresizerResult *result) {
                @jp_strongify(self);
                if (!self) {
                    [JPProgressHUD dismiss];
                    return;
                }
                [self __imageresizerDoneWithResult:result];
            }];
        };
        if (self.imageresizerView.isLoopPlaybackGIF) {
            cropGIF();
        } else {
            UIAlertController *alertCtr = [UIAlertController build:UIAlertControllerStyleActionSheet title:nil message:nil];
            [alertCtr addAction:@"裁剪当前帧画面" handler:^{
                @jp_strongify(self);
                if (!self) return;
                [JPProgressHUD show];
                [self.imageresizerView cropGIFCurrentIndexWithCacheURL:nil errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
                    [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
                } completeBlock:^(JPImageresizerResult *result) {
                    @jp_strongify(self);
                    if (!self) {
                        [JPProgressHUD dismiss];
                        return;
                    }
                    [self __imageresizerDoneWithResult:result];
                }];
            }];
            [alertCtr addAction:@"裁剪GIF" handler:cropGIF];
            [alertCtr addCancel:@"取消" handler:nil];
            [alertCtr presentFrom:self];
        }
        return;
    }
    
    // 裁剪图片
    void (^cropPicture)(void) = ^{
        [JPProgressHUD show];
        [self.imageresizerView cropPictureWithCacheURL:[self __cacheURL:@"jpeg"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
            [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
        } completeBlock:^(JPImageresizerResult *result) {
            @jp_strongify(self);
            if (!self) {
                [JPProgressHUD dismiss];
                return;
            }
            [self __imageresizerDoneWithResult:result];
        }];
    };
    
    if (self.isReplaceFace ||
        self.imageresizerView.imageresizerWHScale <= 0.5 ||
        self.imageresizerView.imageresizerWHScale >= 2) {
        cropPicture();
        return;
    }
    
    UIAlertController *alertCtr = [UIAlertController build:UIAlertControllerStyleActionSheet title:nil message:nil];
    [alertCtr addAction:@"直接裁剪" handler:cropPicture];
    [alertCtr addAction:@"裁剪九宫格" handler:^{
        @jp_strongify(self);
        if (!self) return;
        [JPProgressHUD show];
        [self.imageresizerView cropNineGirdPicturesWithCompressScale:1 bgColor:nil cacheURL:[self __cacheURL:@"jpeg"] errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
            [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
        } completeBlock:^(JPImageresizerResult *originResult, NSArray<JPImageresizerResult *> *fragmentResults, NSInteger columnCount, NSInteger rowCount) {
            @jp_strongify(self);
            if (!self) return;
            [self __girdImageresizerDoneWithOriginResult:originResult fragmentResults:fragmentResults columnCount:columnCount rowCount:rowCount];
        }];
    }];
    [alertCtr addCancel:@"取消" handler:nil];
    [alertCtr presentFrom:self];
}

#pragma mark - 以当前时间戳生成缓存路径

- (NSURL *)__cacheURL:(NSString *)extension {
    NSString *folderPath = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:folderPath];
    for (NSString *fileName in fileEnumerator) {
        [fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"%.0lf", [[NSDate date] timeIntervalSince1970]];
    if (extension.length > 0) {
        fileName = [NSString stringWithFormat:@"%@.%@", fileName, extension];
    }
    NSString *cachePath = [folderPath stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:cachePath];
}

#pragma mark - 图片裁剪完成

- (void)__imageresizerDoneWithResult:(JPImageresizerResult *)result {
    if (!result) {
        [JPProgressHUD showErrorWithStatus:@"裁剪失败" userInteractionEnabled:YES];
        return;
    }
    
    [JPProgressHUD dismiss];
    JPLog(@"🎉 裁剪成功！缓存路径 >>>>> %@", result.cacheURL.absoluteString);
    
    if (self.isReplaceFace) {
        DanielWuViewController *vc = [DanielWuViewController DanielWuVC:result.image];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        JPPreviewViewController *vc = [JPPreviewViewController buildWithResult:result];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)__girdImageresizerDoneWithOriginResult:(JPImageresizerResult *)originResult fragmentResults:(NSArray<JPImageresizerResult *> *)fragmentResults columnCount:(NSInteger)columnCount rowCount:(NSInteger)rowCount {
    if (!originResult || fragmentResults.count == 0) {
        [JPProgressHUD showErrorWithStatus:@"裁剪失败" userInteractionEnabled:YES];
        return;
    }
    [JPProgressHUD dismiss];
    JPPreviewViewController *vc = [JPPreviewViewController buildWithResults:[@[originResult] arrayByAddingObjectsFromArray:fragmentResults] columnCount:columnCount rowCount:rowCount];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 裁剪视频

- (void)__cropVideo:(NSTimeInterval)duration {
    NSURL *videoURL = self.imageresizerView.videoURL;
    NSURL *cacheURL = [self __cacheURL:videoURL.pathExtension];
    [JPProgressHUD show];
    @jp_weakify(self);
    [self.imageresizerView cropVideoFromStartSecond:(duration > 0 ? self.imageresizerView.currentSecond : 0)
                                           duration:duration
                                         presetName:AVAssetExportPresetHighestQuality
                                           cacheURL:cacheURL
                                         errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
        weak_self.isExporting = NO;
        [JPProgressHUD showImageresizerError:reason pathExtension:[cacheURL pathExtension]];
    } progressBlock:^(float progress) {
        // 监听进度
        weak_self.isExporting = YES;
        [JPProgressHUD showProgress:progress status:[NSString stringWithFormat:@"%.0f%%", progress * 100] userInteractionEnabled:YES];
    } completeBlock:^(JPImageresizerResult *result) {
        @jp_strongify(self);
        if (!self) {
            [JPProgressHUD dismiss];
            return;
        }
        self.isExporting = NO;
        self.isReplaceFace = NO;
        [self __imageresizerDoneWithResult:result];
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

@end
