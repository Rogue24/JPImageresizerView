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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *processBtns;
@property (weak, nonatomic) IBOutlet UIButton *recoveryBtn;
@property (weak, nonatomic) IBOutlet UIButton *goBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *resizeBtn;
@property (weak, nonatomic) IBOutlet UIButton *horMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *verMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.configure.bgColor;
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
    
    // initialResizeWHScale默认为初始化时的resizeWHScale
    // 若之后修改了resizeWHScale的值，重置时（调用 recovery）resizeWHScale会重置为该属性的值
    // self.imageresizerView.initialResizeWHScale = 16.0 / 9.0; // 可随意修改该参数
    
    // 若想重置为当前resizeWHScale，可使用recoveryByCurrentResizeWHScale方法
    // 若想重置为任意resizeWHScale，可使用recoveryByResizeWHScale:方法
    
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
//    [self.imageresizerView setResizeWHScale:1 animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    NSLog(@"viewController is dead");
}

- (IBAction)changeFrameType:(UIButton *)sender {
    sender.selected = !sender.selected;
    JPImageresizerFrameType frameType;
    if (sender.selected) {
        frameType = JPClassicFrameType;
    } else {
        frameType = JPConciseFrameType;
    }
    self.imageresizerView.frameType = frameType;
}

- (IBAction)rotate:(id)sender {
    [self.imageresizerView rotation];
}

- (IBAction)recovery:(id)sender {
    // 1.默认按initialResizeWHScale进行重置
    [self.imageresizerView recovery];
    
    // 2.按当前resizeWHScale进行重置
//    [self.imageresizerView recoveryByCurrentResizeWHScale];
    
    // 3.按指定resizeWHScale进行重置
//    [self.imageresizerView recoveryByResizeWHScale:(3.0 / 4.0)];
}

- (IBAction)anyScale:(id)sender {
    self.imageresizerView.resizeWHScale = 0;
}

- (IBAction)one2one:(id)sender {
    self.imageresizerView.resizeWHScale = 1.0;
}

- (IBAction)sixteen2nine:(id)sender {
    self.imageresizerView.resizeWHScale = 16.0 / 9.0;
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
    
    __weak typeof(self) wSelf = self;
    
    // 1.自定义压缩比例进行裁剪
    [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        if (!resizeImage) {
            NSLog(@"没有裁剪图片");
            return;
        }
        
        JPImageViewController *vc = [sSelf.storyboard instantiateViewControllerWithIdentifier:@"JPImageViewController"];
        vc.image = resizeImage;
        [sSelf.navigationController pushViewController:vc animated:YES];
        
        sSelf.recoveryBtn.enabled = YES;
    } scale:0.7]; // 这里压缩为原图尺寸的70%
    
    // 2.以原图尺寸进行裁剪
//    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
//        // 裁剪完成，resizeImage为裁剪后的图片
//        // 注意循环引用
//    }];
}

- (IBAction)goBack:(id)sender {
    for (UIButton *btn in self.processBtns) {
        btn.hidden = NO;
    }
    self.imageresizerView.hidden = NO;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.goBackBtn.hidden = YES;
    
    self.recoveryBtn.enabled = YES;
    [self.imageresizerView recovery];
}

- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)lockFrame:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.imageresizerView.isLockResizeFrame = sender.selected;
}

- (IBAction)verMirror:(id)sender {
    [self.imageresizerView setVerticalityMirror:!self.imageresizerView.verticalityMirror animated:YES];
}

- (IBAction)horMirror:(id)sender {
    [self.imageresizerView setHorizontalMirror:!self.imageresizerView.horizontalMirror animated:YES];
}

- (IBAction)previewAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.imageresizerView.isPreview = sender.selected;
//    [self.imageresizerView setIsPreview:sender.selected animated:NO];
}

@end
