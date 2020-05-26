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

@interface JPConfigureModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) JPImageresizerConfigure *configure;
+ (NSArray<JPConfigureModel *> *)testModels;
@end

@implementation JPConfigureModel
+ (NSArray<JPConfigureModel *> *)testModels {
    JPConfigureModel *model1 = [self new];
    model1.title = @"默认样式";
    model1.statusBarStyle = UIStatusBarStyleLightContent;
    model1.configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:nil make:nil];
    
    JPConfigureModel *model2 = [self new];
    model2.title = @"深色毛玻璃遮罩";
    model2.statusBarStyle = UIStatusBarStyleLightContent;
    model2.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure.jp_strokeColor([UIColor orangeColor]);
    }];
    
    JPConfigureModel *model3 = [self new];
    model3.title = @"浅色毛玻璃遮罩";
    model3.statusBarStyle = UIStatusBarStyleDefault;
    model3.configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure.jp_strokeColor([UIColor yellowColor]);
    }];
    
    JPConfigureModel *model4 = [self new];
    model4.title = @"其他样式";
    model4.statusBarStyle = UIStatusBarStyleDefault;
    model4.configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_maskAlpha(0.5)
        .jp_strokeColor(JPRandomColor)
        .jp_frameType(JPClassicFrameType)
        .jp_bgColor(JPRandomColor)
        .jp_isClockwiseRotation(YES)
        .jp_animationCurve(JPAnimationCurveEaseOut);
    }];
    
    JPConfigureModel *model5 = [self new];
    model5.title = @"自定义边框图片（拉伸模式）";
    model5.statusBarStyle = UIStatusBarStyleDefault;
    
    UIImage *stretchBorderImage = [UIImage imageNamed:@"real_line"];
    // 裁剪掉上下多余的空白部分
    CGFloat inset = 1.5 * stretchBorderImage.scale;
    CGImageRef sbImageRef = stretchBorderImage.CGImage;
    sbImageRef = CGImageCreateWithImageInRect(sbImageRef, CGRectMake(0, inset, CGImageGetWidth(sbImageRef), CGImageGetHeight(sbImageRef) - 2 * inset));
    stretchBorderImage = [UIImage imageWithCGImage:sbImageRef scale:stretchBorderImage.scale orientation:stretchBorderImage.imageOrientation];
    CGImageRelease(sbImageRef);
    // 设定拉伸区域
    stretchBorderImage = [stretchBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    
    model5.configure = [JPImageresizerConfigure lightBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_strokeColor([UIColor colorWithRed:(205.0 / 255.0) green:(107.0 / 255.0) blue:(153.0 / 255.0) alpha:1.0])
        .jp_borderImage(stretchBorderImage)
        .jp_borderImageRectInset(CGPointMake(-2, -2));
    }];
    
    JPConfigureModel *model6 = [self new];
    model6.title = @"自定义边框图片（平铺模式）";
    model6.statusBarStyle = UIStatusBarStyleLightContent;
    
    UIImage *tileBorderImage = [UIImage imageNamed:@"dotted_line"];
    // 设定平铺区域
    tileBorderImage = [tileBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];
    
    model6.configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithResizeImage:nil make:^(JPImageresizerConfigure *configure) {
        configure
        .jp_frameType(JPClassicFrameType)
        .jp_borderImage(tileBorderImage)
        .jp_borderImageRectInset(CGPointMake(-1.75, -1.75));
    }];
    
    return @[model1, model2, model3, model4, model5, model6];
}
@end

@interface JPTableViewController ()
@property (nonatomic, copy) NSArray<JPConfigureModel *> *models;
@end

@implementation JPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Example";
    self.models = [JPConfigureModel testModels];
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
        return self.models.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        JPConfigureModel *model = self.models[indexPath.row];
        cell.textLabel.text = model.title;
    } else {
        cell.textLabel.text = @"用户相册";
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        JPConfigureModel *model = self.models[indexPath.row];
        model.configure.resizeImage = self.randomResizeImage;
        
        JPViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPViewController"];
        vc.statusBarStyle = model.statusBarStyle;
        vc.configure = model.configure;
        
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

#pragma mark - 随机图片

- (UIImage *)randomResizeImage {
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
    return [UIImage imageNamed:imageName];
}

@end
