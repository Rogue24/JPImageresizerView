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

@interface JPTableViewController ()
@property (nonatomic, copy) NSArray *configures;
@end

@implementation JPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Example";
    
    NSString *title1 = @"默认样式";
    JPImageresizerConfigure *configure1 = [JPImageresizerConfigure defaultConfigureWithResizeImage:nil make:nil];
    
    NSString *title2 = @"深色毛玻璃遮罩";
    JPImageresizerConfigure *configure2 = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure.jp_strokeColor([UIColor orangeColor]);
    }];
    
    NSString *title3 = @"浅色毛玻璃遮罩";
    JPImageresizerConfigure *configure3 = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure.jp_strokeColor([UIColor yellowColor]);
    }];
    
    NSString *title4 = @"其他样式";
    JPImageresizerConfigure *configure4 = [JPImageresizerConfigure defaultConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_maskAlpha(0.5)
        .jp_strokeColor(JPRandomColor)
        .jp_frameType(JPClassicFrameType)
        .jp_bgColor(JPRandomColor)
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
    
    JPImageresizerConfigure *configure5 = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_strokeColor([UIColor colorWithRed:(205.0 / 255.0) green:(107.0 / 255.0) blue:(153.0 / 255.0) alpha:1.0])
        .jp_borderImage(stretchBorderImage)
        .jp_borderImageRectInset(CGPointMake(-2, -2));
    }];
    
    NSString *title6 = @"自定义边框图片（平铺模式）";
    
    UIImage *tileBorderImage = [UIImage imageNamed:@"dotted_line"];
    // 设定平铺区域
    tileBorderImage = [tileBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];
    
    JPImageresizerConfigure *configure6 = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_frameType(JPClassicFrameType)
        .jp_borderImage(tileBorderImage)
        .jp_borderImageRectInset(CGPointMake(-1.75, -1.75));
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
        
        NSString *imageName;
        NSInteger index = 1 + arc4random() % 9;
        if (index > 5) {
            switch (index) {
                case 6:
                    imageName = @"Kobe.jpg";
                    break;
                case 7:
                    imageName = @"Woman.jpg";
                    break;
                case 8:
                    imageName = @"Beauty.jpg";
                    break;
                default:
                    imageName = @"Train.jpg";
                    break;
            }
        } else {
            imageName = [NSString stringWithFormat:@"Girl%zd.jpg", index];
        }
        vc.configure.resizeImage = [UIImage imageNamed:imageName];
        
        CATransition *cubeAnim = [CATransition animation];
        cubeAnim.duration = 0.5;
        cubeAnim.type = @"cube";
        cubeAnim.subtype = kCATransitionFromRight;
        cubeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.view.window.layer addAnimation:cubeAnim forKey:@"cube"];
        
        [self.navigationController pushViewController:vc animated:NO];
    } else {
        __weak typeof(self) wSelf = self;
        [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            JPPhotoViewController *vc = [[JPPhotoViewController alloc] init];
            [sSelf.navigationController pushViewController:vc animated:YES];
        } refuseAccessAuthorityHandler:nil alreadyRefuseAccessAuthorityHandler:nil canNotAccessAuthorityHandler:nil isRegisterChange:NO];
    }
}

@end
