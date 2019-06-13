//
//  NoDataView.h
//  Infinitee2.0
//
//  Created by guanning on 2016/12/26.
//  Copyright © 2016年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoDataView : UIView

@property (nonatomic, copy) NSString *title;

+ (NoDataView *)noDataViewWithTitle:(NSString *)title onView:(UIView *)superView center:(CGPoint)center;
+ (NoDataView *)noDataViewWithTitle:(NSString *)title onView:(UIView *)superView center:(CGPoint)center isWholeCenter:(BOOL)isWholeCenter;

- (void)show;
- (void)hideWithCompletion:(void(^)(void))completion;

@end
