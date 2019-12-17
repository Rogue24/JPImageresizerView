//
//  JPImageresizerViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2019/12/14.
//  Copyright © 2019 ZhouJianPing. All rights reserved.
//

#import "JPImageresizerViewController.h"
#import "JPImageresizerView.h"
#import "JPConstant.h"
#import "JPMacro.h"
#import "UIView+JPExtension.h"
#import "UIView+JPPOP.h"
#import "JPProgressHUD.h"

@interface JPImageresizerViewController ()
@property (weak, nonatomic) IBOutlet UIVisualEffectView *topToolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topToolBarHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBtnsBottomMargin;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *lineColorBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchLineBtn;
@property (weak, nonatomic) IBOutlet UIButton *imageresizeBtn;



@property (weak, nonatomic) IBOutlet UIVisualEffectView *bottomToolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBarHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBarBottom;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *bottomBtnsHorSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnsVerMargin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnsVerSpace;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *bottomToolBarBottomBtns;

@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@end

@implementation JPImageresizerViewController

#pragma mark - 常量

#pragma mark - setter

#pragma mark - getter

#pragma mark - 创建方法

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupImageresizerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - 初始布局

- (void)setupBase {
    self.topToolBarHeight.constant = 50 + JPStatusBarH;
    
    
    
    CGFloat verMarget = 5;
    
    self.topBtnsBottomMargin.constant = verMarget;
    
    self.bottomBtnsVerMargin.constant = verMarget;
    self.bottomBtnsVerSpace.constant = verMarget * 2;
    
    self.bottomToolBarHeight.constant = (self.bottomBtnsVerMargin.constant + 40) * 2 + self.bottomBtnsVerSpace.constant;
    self.bottomToolBarBottom.constant = -(self.bottomToolBarHeight.constant - (50 + JPDiffTabBarH));
    
    [self.bottomToolBarBottomBtns enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        btn.hidden = YES;
    }];
}

- (void)setupImageresizerView {
    UIImage *stretchBorderImage = [UIImage imageNamed:@"real_line"];
    // 裁剪掉上下多余的空白部分
    CGFloat inset = 1.5 * stretchBorderImage.scale;
    CGImageRef sbImageRef = stretchBorderImage.CGImage;
    sbImageRef = CGImageCreateWithImageInRect(sbImageRef, CGRectMake(0, inset, CGImageGetWidth(sbImageRef), CGImageGetHeight(sbImageRef) - 2 * inset));
    stretchBorderImage = [UIImage imageWithCGImage:sbImageRef scale:stretchBorderImage.scale orientation:stretchBorderImage.imageOrientation];
    CGImageRelease(sbImageRef);
    // 设定拉伸区域
    stretchBorderImage = [stretchBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(10 + 50 + JPStatusBarH,
                                                  10,
                                                  10 + 50 + JPDiffTabBarH,
                                                  10);
    
    JPImageresizerConfigure *configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithResizeImage:[UIImage imageNamed:@"Beauty.jpg"] make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_contentInsets(contentInsets)
        .jp_strokeColor([UIColor colorWithRed:(205.0 / 255.0) green:(107.0 / 255.0) blue:(153.0 / 255.0) alpha:1.0])
        .jp_borderImage(stretchBorderImage)
        .jp_borderImageRectInset(CGPointMake(-2, -2))
        .jp_maskAlpha(0);
    }];
    
    @jp_weakify(self);
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
        @jp_strongify(self);
        if (!self) return;
        // 当不需要重置设置按钮不可点
//        sSelf.recoveryBtn.enabled = isCanRecovery;
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        @jp_strongify(self);
        if (!self) return;
        // 当预备缩放设置按钮不可点，结束后可点击
//        BOOL enabled = !isPrepareToScale;
//        sSelf.rotateBtn.enabled = enabled;
//        sSelf.resizeBtn.enabled = enabled;
//        sSelf.horMirrorBtn.enabled = enabled;
//        sSelf.verMirrorBtn.enabled = enabled;
    }];
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
}

#pragma mark - 通知方法

#pragma mark - 事件触发方法

#pragma mark - 重写父类方法

#pragma mark - 系统方法

#pragma mark - 私有方法

#pragma mark - 公开方法






@end
