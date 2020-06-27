//
//  ReplaceFaceViewController.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/6/20.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceView.h"

@interface ReplaceFaceViewController : UIViewController
- (instancetype)initWithPersonImage:(UIImage *)personImage faceImage:(UIImage *)faceImage;
@property (nonatomic, strong) UIImage *personImage;
@property (nonatomic, strong) UIImage *faceImage;
@property (nonatomic, weak) UIImageView *personView;
@property (nonatomic, weak) FaceView *faceView;
@end
