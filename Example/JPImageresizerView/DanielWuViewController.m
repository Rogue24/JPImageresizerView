//
//  DanielWuViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/6/8.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "DanielWuViewController.h"
#import "JPPhotoTool.h"

@interface DanielWuViewController ()
@property (strong, nonatomic) UIImageView *DanielWuView;
@property (strong, nonatomic) UIImageView *faceView;
@property (nonatomic, weak) UIButton *camceraBtn;
@end

@implementation DanielWuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    [self setupNavigationBar];
    
    UIImage *image = [UIImage imageNamed:@"DanielWu.jpg"];
    
    CGFloat w = JPPortraitScreenWidth;
    CGFloat h = w * (image.size.height / image.size.width);
    CGFloat x = 0;
    CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight, h);
    self.DanielWuView = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        aImgView.image = image;
        aImgView;
    });
    [self.view addSubview:self.DanielWuView];
    
    CGFloat scale = JPPortraitScreenWidth / 567.0;
    
    x = 152.0 * scale;
    y = 239.0 * scale;
    w = (567.0 - 152.0 - 166.0) * scale;
    h = w * (300.0 / 263.0);
    self.faceView = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        aImgView.contentMode = UIViewContentModeScaleAspectFit;
        aImgView.image = self.image;
        aImgView;
    });
    self.faceView.hidden = YES;
    [self.DanielWuView addSubview:self.faceView];
}

- (void)setupNavigationBar {
    self.title = @"我叫吴彦祖";
    UIButton *camceraBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setTitle:@"保存" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(savePhotoToAppAlbum) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    camceraBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:camceraBtn];
    self.camceraBtn = camceraBtn;
}

- (void)savePhotoToAppAlbum {
    [JPProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self.DanielWuView jp_convertToImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPPhotoToolSI savePhotoToAppAlbumWithImage:image successHandle:^(NSString *assetID) {
                [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
            } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                [JPProgressHUD showSuccessWithStatus:@"保存失败" userInteractionEnabled:YES];
            }];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView transitionWithView:self.faceView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.faceView.hidden = NO;
    } completion:^(BOOL finished) {
        self.camceraBtn.enabled = YES;
    }];
}

@end
