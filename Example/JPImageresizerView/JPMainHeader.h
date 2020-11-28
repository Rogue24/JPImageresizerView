//
//  JPMainHeader.h
//  JPImageresizerView_Example
//
//  Created by aa on 2020/11/28.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPMainHeader : UICollectionReusableView
+ (NSString *)headerID;
+ (UIFont *)titleFont;
+ (UIColor *)titleColor;
@property (nonatomic, weak) UILabel *titleLabel;
@end

NS_ASSUME_NONNULL_END
