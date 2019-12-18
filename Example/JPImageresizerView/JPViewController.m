//
//  JPViewController.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPViewController.h"
#import "JPImageViewController.h"

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
@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.configure.bgColor;
    self.frameType = self.configure.frameType;
    self.borderImage = self.configure.borderImage;
    self.recoveryBtn.enabled = NO;
    
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
    
    // 注意：iOS11以下的系统，所在的controller最好设置automaticallyAdjustsScrollViewInsets为NO，不然就会随导航栏或状态栏的变化产生偏移
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
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
}

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
    if (self.navigationController.viewControllers.count <= 1) {
        [UIView transitionWithView:self.view.window duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self dismissViewControllerAnimated:NO completion:nil];
        } completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
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
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"任意比例" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView setResizeWHScale:0 isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"原切" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView roundResize:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"1 : 1" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView setResizeWHScale:1 isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"2 : 3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView setResizeWHScale:(2.0 / 3.0) isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"3 : 5" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView setResizeWHScale:(3.0 / 5.0) isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"7 : 3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView setResizeWHScale:(7.0 / 3.0) isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"9 : 16" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView setResizeWHScale:(9.0 / 16.0) isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"16 : 9" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageresizerView setResizeWHScale:(16.0 / 9.0) isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (IBAction)changeBlurEffect:(id)sender {
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"移除模糊效果" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.blurEffect = nil;
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"ExtraLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Light" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Dark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }]];
    if (@available(iOS 10, *)) {
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"Regular" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        }]];
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"Prominent" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
        }]];
        
        if (@available(iOS 13, *)) {
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThinMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThickMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemChromeMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThinMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialLight];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialLight];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThickMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialLight];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemChromeMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThinMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemThickMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialDark];
            }]];
            [alertCtr addAction:[UIAlertAction actionWithTitle:@"SystemChromeMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
            }]];
        }
    }
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (IBAction)changeRandomColor:(id)sender {
    CGFloat alpha = (CGFloat)JPRandomNumber(0, 10) / 10.0;
    UIColor *strokeColor;
    UIColor *bgColor;
    if (@available(iOS 13, *)) {
        strokeColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return JPRandomColor;
            } else {
                return JPRandomColor;
            }
        }];
        bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return JPRandomColor;
            } else {
                return JPRandomColor;
            }
        }];
    } else {
        strokeColor = JPRandomColor;
        bgColor = JPRandomColor;
    }
    [self.imageresizerView setupBlurEffect:self.imageresizerView.blurEffect bgColor:bgColor maskAlpha:alpha strokeColor:strokeColor animated:YES];
}

- (IBAction)replaceImage:(UIButton *)sender {
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Girl" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       self.imageresizerView.resizeImage = [UIImage imageNamed:@"Girl.jpg"];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Kobe" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       self.imageresizerView.resizeImage = [UIImage imageNamed:@"Kobe.jpg"];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Woman" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       self.imageresizerView.resizeImage = [UIImage imageNamed:@"Woman.jpg"];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Beauty" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       self.imageresizerView.resizeImage = [UIImage imageNamed:@"Beauty.jpg"];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Train" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       self.imageresizerView.resizeImage = [UIImage imageNamed:@"Train.jpg"];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

@end
