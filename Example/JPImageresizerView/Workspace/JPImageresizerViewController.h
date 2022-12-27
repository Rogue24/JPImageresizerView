//
//  JPImageresizerViewController.h
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPImageresizerViewController : UIViewController
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) JPImageresizerConfigure *configure;
@property (nonatomic, assign) BOOL isReplaceFace;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@property (nonatomic, copy) void (^_Nullable backBlock)(JPImageresizerViewController *vc);

+ (instancetype)buildWithStatusBarStyle:(UIStatusBarStyle)statusBarStyle configure:(JPImageresizerConfigure *)configure;
+ (void)showErrorMsg:(JPImageresizerErrorReason)reason pathExtension:(NSString *)pathExtension;
@end

NS_ASSUME_NONNULL_END
