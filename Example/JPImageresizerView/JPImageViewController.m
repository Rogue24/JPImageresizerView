//
//  JPImageViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2018/1/2.
//  Copyright © 2018年 ZhouJianPing. All rights reserved.
//

#import "JPImageViewController.h"
#import "JPPhotoTool.h"

@interface JPImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation JPImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Finish";
    self.imageView.image = self.image;
    [self __setupNavigationBar];
    [self __changBgColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)__setupNavigationBar {
    UIButton *camceraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    camceraBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [camceraBtn setTitle:@"保存" forState:UIControlStateNormal];
    [camceraBtn addTarget:self action:@selector(__savePhotoToAppAlbum) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:camceraBtn];
}

- (void)__savePhotoToAppAlbum {
    [JPPhotoToolSI savePhotoToAppAlbumWithImage:self.image successHandle:^(NSString *assetID) {
        [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
    } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
        [JPProgressHUD showSuccessWithStatus:@"保存失败" userInteractionEnabled:YES];
    }];
}

- (void)__changBgColor {
    @jp_weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewBackgroundColor toValue:JPRandomColor duration:2.0 completionBlock:^(POPAnimation *anim, BOOL finished) {
            @jp_strongify(self);
            if (!self) return;
            [self __changBgColor];
        }];
    });
}

- (void)dealloc {
    NSLog(@"imageViewController is dead");
}

@end
