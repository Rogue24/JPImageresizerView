//
//  JPViewController.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPViewController.h"
#import "JPImageViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

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
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.imageresizerView setResizeWHScale:1 isToBeArbitrarily:NO animated:animated:YES];
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
    // 1.按当前 resizeWHScale 进行重置
    [self.imageresizerView recoveryByCurrentResizeWHScale];
    
    // 2.按 initialResizeWHScale 进行重置
//    [self.imageresizerView recoveryByInitialResizeWHScale:self.isToBeArbitrarily];
    
    // 3.按 目标裁剪宽高比 进行重置
//    [self.imageresizerView recoveryByTargetResizeWHScale:self.imageresizerView.imageresizeWHScale isToBeArbitrarily:self.isToBeArbitrarily];
}

- (IBAction)anyScale:(id)sender {
    self.imageresizerView.resizeWHScale = 0;
}

- (IBAction)one2one:(id)sender {
//    self.imageresizerView.resizeWHScale = 1.0;
    [self.imageresizerView setResizeWHScale:1.0 isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
}

- (IBAction)sixteen2nine:(id)sender {
//    self.imageresizerView.resizeWHScale = 16.0 / 9.0;
    [self.imageresizerView setResizeWHScale:(16.0 / 9.0) isToBeArbitrarily:self.isToBeArbitrarily animated:YES];
}

- (IBAction)replaceImage:(UIButton *)sender {
    sender.selected = !sender.selected;
    UIImage *image;
    if (sender.selected) {
        image = [UIImage imageNamed:@"Kobe.jpg"];
    } else {
        image = [UIImage imageNamed:@"Girl.jpg"];
    }
    self.imageresizerView.resizeImage = image;
}

- (IBAction)resize:(id)sender {
    self.recoveryBtn.enabled = NO;
    
    [SVProgressHUD show];
    
    __weak typeof(self) wSelf = self;
    
    // 1.自定义压缩比例进行裁剪
//    [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
//        // 裁剪完成，resizeImage为裁剪后的图片
//        // 注意循环引用
//    } scale:0.7]; // 这里压缩为原图尺寸的70%
    
    // 2.以原图尺寸进行裁剪
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        if (!resizeImage) {
            [SVProgressHUD showErrorWithStatus:@"没有裁剪图片"];
            return;
        }
        
        [SVProgressHUD dismiss];
        
        JPImageViewController *vc = [sSelf.storyboard instantiateViewControllerWithIdentifier:@"JPImageViewController"];
        vc.image = resizeImage;
        [sSelf.navigationController pushViewController:vc animated:YES];
        
        sSelf.recoveryBtn.enabled = YES;
    }];
}

- (IBAction)pop:(id)sender {
    if (self.navigationController.viewControllers.count <= 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
    [self.imageresizerView setResizeWHScale:self.imageresizerView.resizeWHScale isToBeArbitrarily:self.isToBeArbitrarily animated:NO];
}

@end
