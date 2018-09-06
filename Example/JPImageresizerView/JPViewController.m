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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    [self.imageresizerView recovery];
}

- (IBAction)anyScale:(id)sender {
    self.imageresizerView.resizeWHScale = 0;
}

- (IBAction)one2one:(id)sender {
    self.imageresizerView.resizeWHScale = 1;
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
    
    __weak typeof(self) weakSelf = self;
    [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (!resizeImage) {
            NSLog(@"没有裁剪图片");
            return;
        }
        
        JPImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPImageViewController"];
        vc.image = resizeImage;
        [strongSelf.navigationController pushViewController:vc animated:YES];
        
        strongSelf.recoveryBtn.enabled = YES;
        
    }];
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

@end
