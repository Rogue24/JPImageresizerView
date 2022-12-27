//
//  JPExportCancelView.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/7/21.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPExportCancelView : UIView
+ (void)showWithCancelHandler:(void(^)(void))cancelHandler;
+ (void)hide;
@end

NS_ASSUME_NONNULL_END
