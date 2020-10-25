//
//  DanielWuViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/6/8.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "DanielWuViewController.h"

@interface DanielWuViewController ()

@end

@implementation DanielWuViewController

+ (instancetype)DanielWuVC:(UIImage *)faceImage {
    return [[self alloc] initWithPersonImage:[UIImage imageNamed:@"DanielWu.jpg"] faceImage:faceImage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我叫吴彦祖";
    
    CGFloat scale = JPPortraitScreenWidth / 567.0;
    CGFloat x = 152.0 * scale;
    CGFloat y = 239.0 * scale;
    self.faceView.jp_origin = CGPointMake(x, y);
}

@end
