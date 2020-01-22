//
//  JPCategoryTitleView.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/8.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPCategoryTitleView.h"

@interface JPCategoryTitleView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) CALayer *selectedLine;
@property (nonatomic, weak) CALayer *bottomLine;
@property (nonatomic, assign) BOOL isNeedAnimated;
@end

@implementation JPCategoryTitleView
{
    CGFloat _sideMargin;
    CGFloat _cellSpace;
}


static NSString *const JPPictureChooseCategoryCellID = @"JPPictureChooseCategoryCell";

+ (JPCategoryTitleView *)categoryTitleViewWithSideMargin:(CGFloat)sideMargin cellSpace:(CGFloat)cellSpace {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, sideMargin, 0, sideMargin);
    flowLayout.minimumLineSpacing = cellSpace;
    flowLayout.minimumInteritemSpacing = cellSpace;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return [[self alloc] initWithFrame:CGRectMake(0, JPNavTopMargin, JPPortraitScreenWidth, JPCategoryTitleCell.cellHeight) collectionViewLayout:flowLayout sideMargin:sideMargin cellSpace:cellSpace];
}

- (instancetype)initWithFrame:(CGRect)frame
         collectionViewLayout:(UICollectionViewLayout *)layout
                   sideMargin:(CGFloat)sideMargin
                    cellSpace:(CGFloat)cellSpace {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        _sideMargin = sideMargin;
        _cellSpace = cellSpace;
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        
        if (@available(iOS 11.0, *)) self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [self registerClass:JPCategoryTitleCell.class forCellWithReuseIdentifier:JPPictureChooseCategoryCellID];
        
        CALayer *selectedLine = [CALayer layer];
        selectedLine.backgroundColor = JPRGBAColor(88, 144, 255, 1).CGColor;
        selectedLine.frame = CGRectMake(0, frame.size.height - 1, 0, 1);
        selectedLine.cornerRadius = 0.5;
        selectedLine.masksToBounds = YES;
        selectedLine.zPosition = 1;
        selectedLine.opacity = 0;
        [self.layer addSublayer:selectedLine];
        self.selectedLine = selectedLine;
        
        CALayer *line = [CALayer layer];
        line.backgroundColor = JPRGBAColor(88, 144, 255, 0.1).CGColor;
        line.frame = CGRectMake(0, frame.size.height - (JPSeparateLineThick + 0.01), frame.size.width, JPSeparateLineThick + 0.01);
        [self.layer addSublayer:line];
        self.bottomLine = line;
    }
    return self;
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height - 1, (contentSize.width > self.frame.size.width ? contentSize.width : self.frame.size.width) * 2, 1);
    [CATransaction commit];
}

#pragma mark - setter & getter

- (void)setIsNeedAnimated:(BOOL)isNeedAnimated {
    if (_isNeedAnimated == isNeedAnimated) {
        return;
    }
    _isNeedAnimated = isNeedAnimated;
    !self.isNeedAnimatedDidChange ? : self.isNeedAnimatedDidChange(isNeedAnimated);
}

- (NSMutableArray<JPCategoryTitleViewModel *> *)titleVMs {
    if (!_titleVMs) {
        _titleVMs = [NSMutableArray array];
    }
    return _titleVMs;
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    if (self.titleVMs.count == 0) {
        _selectedIndexPath = nil;
        return;
    }
    
    if (_selectedIndexPath && (_selectedIndexPath.item == selectedIndexPath.item)) {
        return;
    }
    
    self.userInteractionEnabled = NO;
    
    JPCategoryTitleViewModel *noSelTitleVM;
    if (_selectedIndexPath) {
        noSelTitleVM = self.titleVMs[_selectedIndexPath.item];
        noSelTitleVM.isSelected = NO;
        JPCategoryTitleCell *cell = (JPCategoryTitleCell *)[self cellForItemAtIndexPath:_selectedIndexPath];
        if (cell) [cell updateSelectedState:NO animate:YES];
    }
    
    JPCategoryTitleViewModel *seledTitleVM;
    if (selectedIndexPath) {
        seledTitleVM = self.titleVMs[selectedIndexPath.item];
        seledTitleVM.isSelected = YES;
        JPCategoryTitleCell *cell = (JPCategoryTitleCell *)[self cellForItemAtIndexPath:selectedIndexPath];
        if (cell) [cell updateSelectedState:YES animate:YES];
    }
    
    CGRect selectedFrame = self.selectedLine.frame;
    selectedFrame.origin.x = seledTitleVM.cellFrame.origin.x + seledTitleVM.titleFrame.origin.x;
    selectedFrame.size.width = seledTitleVM.titleFrame.size.width;
    [self updateSelectedLineFrame:selectedFrame];
    
    [UIView animateWithDuration:0.35 animations:^{
        self.selectedLine.opacity = 1;
        self.selectedLine.frame = selectedFrame;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
        self->_selectedIndexPath = selectedIndexPath;
    }];
    
    !self.selectedIndexPathDidChange ? : self.selectedIndexPathDidChange(selectedIndexPath);
}

#pragma makr - 刷新动画

- (void)reloadDataWithAnimated:(BOOL)animated {
    _selectedIndexPath = nil;
    
    CGFloat x = _sideMargin;
    for (NSInteger i = 0; i < self.titleVMs.count; i++) {
        JPCategoryTitleViewModel *titleVM = self.titleVMs[i];
        titleVM.isSelected = NO;
        titleVM.cellFrame = CGRectMake(x, 0, titleVM.cellSize.width, titleVM.cellSize.height);
        x += (_cellSpace + titleVM.cellSize.width);
    }
    
    self.isNeedAnimated = animated && _titleVMs.count;
    
    if (self.visibleCells.count && animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectedLine.opacity = 0;
            for (UICollectionViewCell *cell in self.visibleCells) {
                cell.alpha = 0;
            }
        } completion:^(BOOL finished) {
            [self reloadData];
        }];
    } else {
        [self reloadData];
    }
}

- (void)reloadCount:(NSInteger)count inIndex:(NSInteger)index {
    JPCategoryTitleViewModel *titleVM = self.titleVMs[index];
    if (titleVM.count.integerValue == count) return;
    
    titleVM.count = [NSString stringWithFormat:@"%zd", count];
    
    CGFloat x = _sideMargin;
    for (NSInteger i = 0; i < self.titleVMs.count; i++) {
        JPCategoryTitleViewModel *titleVM = self.titleVMs[i];
        titleVM.cellFrame = CGRectMake(x, 0, titleVM.cellSize.width, titleVM.cellSize.height);
        x += (_cellSpace + titleVM.cellSize.width);
    }
    
    [UIView performWithoutAnimation:^{
        [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    }];
}

- (void)updateSelectedLineFrame:(CGRect)frame {
    CGFloat offsetX = frame.origin.x - (self.jp_width - frame.size.width) * 0.5;
    CGFloat maxOffsetX = self.contentSize.width - self.jp_width;
    CGFloat minOffsetX = 0;
    if (offsetX > maxOffsetX) offsetX = maxOffsetX;
    if (offsetX < minOffsetX) offsetX = minOffsetX;
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPCollectionViewContentOffset];
    anim.duration = 0.35;
    anim.toValue = @(CGPointMake(offsetX, 0));
    [self pop_addAnimation:anim forKey:@"CollectionViewContentOffset"];
}

- (void)updateSelectedLineWithSourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress {
    
    JPCategoryTitleCell *sourceCell = (JPCategoryTitleCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:sourceIndex inSection:0]];
    if (sourceCell) sourceCell.colorProgress = 1 - progress;
    
    JPCategoryTitleCell *targetCell = (JPCategoryTitleCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
    if (targetCell) targetCell.colorProgress = progress;
    
    JPCategoryTitleViewModel *sourceTitleVM = self.titleVMs[sourceIndex];
    JPCategoryTitleViewModel *targetTitleVM = self.titleVMs[targetIndex];
    
    CGFloat w = sourceTitleVM.titleFrame.size.width + (targetTitleVM.titleFrame.size.width - sourceTitleVM.titleFrame.size.width) * progress;
    
    CGFloat sourceTitleCenterX = sourceTitleVM.cellFrame.origin.x + CGRectGetMidX(sourceTitleVM.titleFrame);
    CGFloat targetTitleCenterX = targetTitleVM.cellFrame.origin.x + CGRectGetMidX(targetTitleVM.titleFrame);
    CGFloat x = sourceTitleCenterX + (targetTitleCenterX - sourceTitleCenterX) * progress - w * 0.5;
    
    CGRect frame = self.selectedLine.frame;
    frame.origin.x = x;
    frame.size.width = w;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.selectedLine.frame = frame;
    [CATransaction commit];
}

- (void)resetSelectedLine {
    [self updateSelectedLineFrame:self.selectedLine.frame];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPCategoryTitleViewModel *cellVM = self.titleVMs[indexPath.item];
    return cellVM.cellSize;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleVMs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JPCategoryTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPPictureChooseCategoryCellID forIndexPath:indexPath];
    
    JPCategoryTitleViewModel *titleVM = self.titleVMs[indexPath.item];
    
    cell.titleVM = titleVM;
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath.item == indexPath.item) {
        [self resetSelectedLine];
    } else {
        self.selectedIndexPath = indexPath;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isNeedAnimated) {
        cell.alpha = 0;
        cell.jp_x += JPPortraitScreenWidth;
        [UIView animateWithDuration:1.0 delay:0.04 * indexPath.item usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0 animations:^{
            cell.jp_x -= JPPortraitScreenWidth;
            cell.alpha = 1;
        } completion:^(BOOL finished) {
            if (indexPath.item == collectionView.visibleCells.count - 1) {
                self.isNeedAnimated = NO;
                self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            }
        }];
    } else {
        JPCategoryTitleCell *ctCell = (JPCategoryTitleCell *)cell;
        [ctCell updateSelectedState:ctCell.titleVM.isSelected animate:NO];
    }
}

@end
