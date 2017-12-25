//
//  JPViewController.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPViewController.h"

@interface JPViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *processBtns;
@property (weak, nonatomic) IBOutlet UIButton *recoveryBtn;
@property (weak, nonatomic) IBOutlet UIButton *goBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *resizeBtn;
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@end

@implementation JPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recoveryBtn.enabled = NO;
    
    __weak typeof(self) weakSelf = self;
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:self.configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf.recoveryBtn.enabled = isCanRecovery;
    }];
    [self.view insertSubview:imageresizerView aboveSubview:self.imageView];
    self.imageresizerView = imageresizerView;
    self.configure = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        
        for (UIButton *btn in strongSelf.processBtns) {
            btn.hidden = YES;
        }
        strongSelf.imageresizerView.hidden = YES;
        
        strongSelf.imageView.image = resizeImage;
        strongSelf.imageView.hidden = NO;
        strongSelf.goBackBtn.hidden = NO;
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

@end
