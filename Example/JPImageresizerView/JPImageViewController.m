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
    [self setupNavigationBar];
    self.imageView.image = self.image;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)setupNavigationBar {
    self.title = @"裁剪后";
    UIButton *camceraBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setTitle:@"保存" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(savePhotoToAppAlbum) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:camceraBtn];
}

- (void)savePhotoToAppAlbum {
    [[JPPhotoTool sharedInstance] savePhotoToAppAlbumSuccessWithImage:self.image];
}

@end
