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
@end

@implementation DanielWuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    y = self.DanielWuView.jp_y + 239.0 * scale;
    w = (567.0 - 152.0 - 166.0) * scale;
    h = w * (300.0 / 263.0);
    UIImage *faceImage = self.image;
    self.faceView = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        aImgView.image = faceImage;
        aImgView;
    });
    self.faceView.hidden = YES;
    [self.view addSubview:self.faceView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = @"/Users/zhoujianping/Desktop/testImages/faceImage.png";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
        NSData *data = UIImagePNGRepresentation(faceImage);
        [data writeToFile:path atomically:YES];
    });
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
    [JPPhotoToolSI savePhotoToAppAlbumWithImage:self.image successHandle:^(NSString *assetID) {
        [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
    } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
        [JPProgressHUD showSuccessWithStatus:@"保存失败" userInteractionEnabled:YES];
    }];
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
    } completion:nil];
}

@end
