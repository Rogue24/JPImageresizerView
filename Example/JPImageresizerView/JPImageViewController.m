//
//  JPImageViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2018/1/2.
//  Copyright © 2018年 ZhouJianPing. All rights reserved.
//

#import "JPImageViewController.h"

@interface JPImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation JPImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
