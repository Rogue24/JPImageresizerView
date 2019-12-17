//
//  JPTableViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2017/12/25.
//  Copyright © 2017年 ZhouJianPing. All rights reserved.
//

#import "JPTableViewController.h"
#import "JPViewController.h"
#import "JPPhotoViewController.h"
#import "JPImageresizerViewController.h"

@interface JPTableViewController ()
@property (nonatomic, copy) NSArray *configures;
@end

@implementation JPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Example";
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(50, 10, (40 + 30 + 30 + 10), 10);
    BOOL isX = [UIScreen mainScreen].bounds.size.height > 736.0;
    if (isX) {
        contentInsets.top += 24;
        contentInsets.bottom += 34;
    }
    
    NSString *title1 = @"默认样式";
    JPImageresizerConfigure *configure1 = [JPImageresizerConfigure defaultConfigureWithResizeImage:[UIImage imageNamed:@"Girl.jpg"] make:^(JPImageresizerConfigure *configure) {
        configure.jp_contentInsets(contentInsets);
    }];
    
    NSString *title2 = @"深色毛玻璃遮罩";
    JPImageresizerConfigure *configure2 = [JPImageresizerConfigure blurMaskTypeConfigureWithResizeImage:[UIImage imageNamed:@"Girl.jpg"] isLight:NO make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_contentInsets(contentInsets)
        .jp_strokeColor([UIColor orangeColor]);
    }];
    
    NSString *title3 = @"浅色毛玻璃遮罩";
    JPImageresizerConfigure *configure3 = [JPImageresizerConfigure blurMaskTypeConfigureWithResizeImage:[UIImage imageNamed:@"Lotus.jpg"] isLight:YES make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_contentInsets(contentInsets)
        .jp_strokeColor([UIColor blueColor]);
    }];
    
    NSString *title4 = @"其他样式";
    JPImageresizerConfigure *configure4 = [JPImageresizerConfigure defaultConfigureWithResizeImage:[UIImage imageNamed:@"Kobe.jpg"] make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_maskAlpha(0.5)
        .jp_strokeColor([UIColor yellowColor])
        .jp_frameType(JPClassicFrameType)
        .jp_contentInsets(contentInsets)
        .jp_bgColor([UIColor orangeColor])
        .jp_isClockwiseRotation(YES)
        .jp_animationCurve(JPAnimationCurveEaseOut);
    }];
    
    NSString *title5 = @"自定义边框图片（拉伸模式）";
    
    UIImage *stretchBorderImage = [UIImage imageNamed:@"real_line"];
    // 裁剪掉上下多余的空白部分
    CGFloat inset = 1.5 * stretchBorderImage.scale;
    CGImageRef sbImageRef = stretchBorderImage.CGImage;
    sbImageRef = CGImageCreateWithImageInRect(sbImageRef, CGRectMake(0, inset, CGImageGetWidth(sbImageRef), CGImageGetHeight(sbImageRef) - 2 * inset));
    stretchBorderImage = [UIImage imageWithCGImage:sbImageRef scale:stretchBorderImage.scale orientation:stretchBorderImage.imageOrientation];
    CGImageRelease(sbImageRef);
    // 设定拉伸区域
    stretchBorderImage = [stretchBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    
    JPImageresizerConfigure *configure5 = [JPImageresizerConfigure blurMaskTypeConfigureWithResizeImage:[UIImage imageNamed:@"Beauty.jpg"] isLight:YES make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_contentInsets(contentInsets)
        .jp_strokeColor([UIColor colorWithRed:(205.0 / 255.0) green:(107.0 / 255.0) blue:(153.0 / 255.0) alpha:1.0])
        .jp_borderImage(stretchBorderImage)
        .jp_borderImageRectInset(CGPointMake(-2, -2))
        .jp_maskAlpha(0);
    }];
    
    NSString *title6 = @"自定义边框图片（平铺模式）";
    
    UIImage *tileBorderImage = [UIImage imageNamed:@"dotted_line"];
    // 设定平铺区域
    tileBorderImage = [tileBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];
    
    JPImageresizerConfigure *configure6 = [JPImageresizerConfigure blurMaskTypeConfigureWithResizeImage:[UIImage imageNamed:@"Woman.jpg"] isLight:NO make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_contentInsets(contentInsets)
        .jp_frameType(JPClassicFrameType)
        .jp_borderImage(tileBorderImage)
        .jp_borderImageRectInset(CGPointMake(-1.75, -1.75))
        .jp_maskAlpha(0);
    }];
    
    self.configures = @[@{@"title": title1,
                          @"configure": configure1,
                          @"statusBarStyle": @(UIStatusBarStyleLightContent)},
                        
                        @{@"title": title2,
                          @"configure": configure2,
                          @"statusBarStyle": @(UIStatusBarStyleLightContent)},
                        
                        @{@"title": title3,
                          @"configure": configure3,
                          @"statusBarStyle": @(UIStatusBarStyleDefault)},
                        
                        @{@"title": title4,
                          @"configure": configure4,
                          @"statusBarStyle": @(UIStatusBarStyleDefault)},
                        
                        @{@"title": title5,
                          @"configure": configure5,
                          @"statusBarStyle": @(UIStatusBarStyleDefault)},
                        
                        @{@"title": title6,
                          @"configure": configure6,
                          @"statusBarStyle": @(UIStatusBarStyleLightContent)}];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.configures.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSDictionary *dic = self.configures[indexPath.row];
        cell.textLabel.text = dic[@"title"];
    } else {
        cell.textLabel.text = @"用户相册";
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        JPViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPViewController"];
        NSDictionary *dic = self.configures[indexPath.row];
        vc.statusBarStyle = [dic[@"statusBarStyle"] integerValue];
        vc.configure = dic[@"configure"];
        [self.navigationController pushViewController:vc animated:YES];
        
//        JPImageresizerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPImageresizerViewController"];
//        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        __weak typeof(self) wSelf = self;
        [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            JPPhotoViewController *vc = [[JPPhotoViewController alloc] init];
            [sSelf.navigationController pushViewController:vc animated:YES];
        } refuseAccessAuthorityHandler:nil alreadyRefuseAccessAuthorityHandler:nil canNotAccessAuthorityHandler:nil isRegisterChange:YES];
        
    }
}

@end
