//
//  JPPreviewViewController.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2018/1/2.
//  Copyright © 2018年 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPImageresizerResult;

@interface JPPreviewViewController : UIViewController
+ (instancetype)buildWithResult:(JPImageresizerResult *)result;
+ (instancetype)buildWithResults:(NSArray<JPImageresizerResult *> *)results;
@end
