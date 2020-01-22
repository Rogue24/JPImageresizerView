//
//  JPCategoryTitleView.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/8.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPCategoryTitleCell.h"

@interface JPCategoryTitleView : UICollectionView

+ (JPCategoryTitleView *)categoryTitleViewWithSideMargin:(CGFloat)sideMargin cellSpace:(CGFloat)cellSpace;

@property (nonatomic, strong) NSMutableArray<JPCategoryTitleViewModel *> *titleVMs;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, copy) void (^selectedIndexPathDidChange)(NSIndexPath *selectedIndexPath);
@property (nonatomic, copy) void (^isNeedAnimatedDidChange)(BOOL isNeedAnimated);

- (void)reloadDataWithAnimated:(BOOL)animated;

- (void)reloadCount:(NSInteger)count inIndex:(NSInteger)index;

- (void)updateSelectedLineWithSourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress;
- (void)resetSelectedLine;

@end
