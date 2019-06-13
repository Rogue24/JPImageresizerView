//
//  JPCategoryTitleCell.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPCategoryTitleViewModel.h"

@interface JPCategoryTitleCell : UICollectionViewCell

+ (CGFloat)cellHeight;
+ (UIFont *)titleFont;
+ (UIFont *)countFont;

@property (nonatomic, strong) JPCategoryTitleViewModel *titleVM;
@property (nonatomic, assign) CGFloat colorProgress;

- (void)updateSelectedState:(BOOL)isSelected animate:(BOOL)animate;

@end
