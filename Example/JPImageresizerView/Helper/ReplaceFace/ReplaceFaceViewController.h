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
- (instancetype)initWithPersonImage:(UIImage *)personImage faceImages:(NSArray<UIImage *> *)faceImages;
@property (nonatomic, strong) UIImage *personImage;
@property (nonatomic, copy) NSArray<UIImage *> *faceImages;
@property (nonatomic, weak) UIImageView *personView;
@property (nonatomic, copy) NSArray<FaceView *> *faceViews;
@end
