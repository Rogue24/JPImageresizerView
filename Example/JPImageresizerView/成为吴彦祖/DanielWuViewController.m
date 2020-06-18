//
//  DanielWuViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/6/8.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "DanielWuViewController.h"
#import "FaceView.h"
#import "JPImageViewController.h"

@interface DanielWuViewController ()
@property (nonatomic, strong) UIImageView *DanielWuView;
@property (nonatomic, strong) FaceView *faceView;
@end

@implementation DanielWuViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupNavigationBar];
    [self __setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 初始布局

- (void)__setupNavigationBar {
    self.title = @"我叫吴彦祖";
    UIButton *synthesizeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setTitle:@"合成" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(__synthesizeImages) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:synthesizeBtn];
}

- (void)__setupSubviews {
    self.view.backgroundColor = UIColor.blackColor;
    
    UIImage *DanielWuImage = [UIImage imageNamed:@"DanielWu.jpg"];
    
    CGFloat w = JPPortraitScreenWidth;
    CGFloat h = w * (DanielWuImage.size.height / DanielWuImage.size.width);
    CGFloat x = 0;
    CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight, h);
    self.DanielWuView = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        aImgView.image = DanielWuImage;
        aImgView;
    });
    self.DanielWuView.userInteractionEnabled = YES;
    [self.view addSubview:self.DanielWuView];
    
    CGFloat scale = JPPortraitScreenWidth / 567.0;
    x = 152.0 * scale;
    y = 239.0 * scale;
    w = (567.0 - 152.0 - 166.0) * scale;
    h = w * (300.0 / 263.0);
    self.faceView = [[FaceView alloc] initWithFrame:CGRectMake(x, y, w, h) image:self.image];
    [self.DanielWuView addSubview:self.faceView];
}

#pragma mark - 合成图片

- (void)__synthesizeImages {
    [JPProgressHUD show];
    
    UIImage *DanielWuImage = self.DanielWuView.image;
    CGRect rect = CGRectMake(0, 0, floorl(self.DanielWuView.frame.size.width), floorl(self.DanielWuView.frame.size.height));
    
    UIImage *faceImage = self.faceView.faceImage;
    CGRect faceBounds = self.faceView.faceBounds;
    CGPoint faceOrigin = self.faceView.faceOrigin;
    CGFloat faceRadian = self.faceView.faceRadian;
    CGFloat faceScale = self.faceView.faceScale;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        [DanielWuImage drawInRect:rect];
        
        CGImageRef faceImageRef = [self __imageDownMirrored:faceImage].CGImage;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, faceOrigin.x, faceOrigin.y); // 要先进行位移，确定好位置后再进行其他的形变操作，否则位置错乱。
        CGContextScaleCTM(context, faceScale, faceScale);
        CGContextRotateCTM(context, faceRadian);
        CGContextDrawImage(context, faceBounds, faceImageRef);
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];
            JPImageViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JPImageViewController"];
            vc.image = resultImage;
            [self.navigationController pushViewController:vc animated:YES];
        });
    });
}

#pragma mark - 私有方法

- (UIImage *)__imageDownMirrored:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    CGRect bounds = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(0.0, bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -bounds.size.height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), bounds, imageRef);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
