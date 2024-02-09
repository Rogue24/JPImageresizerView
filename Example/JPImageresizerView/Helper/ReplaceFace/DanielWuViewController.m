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
    return [[self alloc] initWithPersonImage:[UIImage imageNamed:@"DanielWu.jpg"] faceImages:@[faceImage]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"趣味换脸";
    
    CGFloat scale = JPPortraitScreenWidth / 567.0;
    CGFloat x = self.personView.jp_x + 152.0 * scale;
    CGFloat y = self.personView.jp_y + 239.0 * scale;
    self.faceViews[0].jp_origin = CGPointMake(x, y);
}

@end
