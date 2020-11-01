//
//  JPImageresizerViewController.h
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPConfigureModel.h"
#import "JPImageresizerView.h"

@interface JPImageresizerViewController : UIViewController
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) JPImageresizerConfigure *configure;
@property (nonatomic, assign) BOOL isBecomeDanielWu;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@property (nonatomic, copy) void (^backBlock)(JPImageresizerViewController *vc);

+ (void)showErrorMsg:(JPImageresizerErrorReason)reason pathExtension:(NSString *)pathExtension;
@end
