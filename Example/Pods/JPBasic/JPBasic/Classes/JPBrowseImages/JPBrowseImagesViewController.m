//
//  JPBrowseImagesViewController.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImagesViewController.h"
#import "JPBrowseImagesTransition.h"
#import "JPBrowseImagesTopView.h"
#import "JPBrowseImagesBottomView.h"
#import "JPConstant.h"
#import "JPMacro.h"

@interface JPBrowseImagesViewController () <UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isPresentDone;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, weak) JPBrowseImageCell *currCell;
@property (nonatomic, weak) JPBrowseImagesTopView *topView;
@property (nonatomic, weak) JPBrowseImagesBottomView *bottomView;
@property (nonatomic, assign) BOOL isHideNavigationBar;
@property (nonatomic, assign) BOOL isTapToHideNav; // 是否单击隐藏，如果是，说明是用户点击隐藏的，下拉缩小恢复后就继续隐藏
@property (nonatomic, assign) NSInteger scrollIndex; // 滚动中的下标，四舍五入

@property (nonatomic, weak) UIView *originImgView;
@property (nonatomic, weak) UIImageView *transitionImgView;
@end

static NSString *const JPBrowseImageCellID = @"JPBrowseImageCell";
static NSInteger const JPViewMargin = 10;

@implementation JPBrowseImagesViewController

#pragma mark - 转场动画

- (void)willTransitionAnimateion:(BOOL)isPresent {
    UIView *originImgView = [self.delegate respondsToSelector:@selector(getOriginImageView:)] ? [self.delegate getOriginImageView:self.currIndex] : nil;
    self.originImgView = originImgView;
    
    UIStatusBarStyle statusBarStyle;
    if (isPresent) {
        self.bgView.alpha = 0;
        
        statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        self.statusBarStyle = statusBarStyle;
        statusBarStyle = UIStatusBarStyleLightContent;
        
        JPBrowseImageModel *currModel = self.dataSource[self.currIndex];
        UIImageView *transitionImgView;
        if (originImgView) {
            CGRect originPicFrame = [originImgView convertRect:originImgView.bounds toView:[UIApplication sharedApplication].keyWindow];
            transitionImgView = [[UIImageView alloc] initWithFrame:originPicFrame];
            transitionImgView.backgroundColor = originImgView.backgroundColor;
            transitionImgView.contentMode = originImgView.contentMode;
            transitionImgView.layer.masksToBounds = originImgView.layer.masksToBounds;
            if ([originImgView respondsToSelector:@selector(image)]) transitionImgView.image = [originImgView performSelector:@selector(image)];
            if (currModel.isCornerRadiusTransition) transitionImgView.layer.cornerRadius = originImgView.layer.cornerRadius;
            if (currModel.isAlphaTransition) transitionImgView.alpha = 0;
        }
        [self.view addSubview:transitionImgView];
        self.transitionImgView = transitionImgView;
        
        if ([self.delegate respondsToSelector:@selector(flipImageViewWithLastIndex:currIndex:)]) [self.delegate flipImageViewWithLastIndex:0 currIndex:self.currIndex];
    } else {
        statusBarStyle = self.statusBarStyle;
        self.currCell.isDismiss = YES;
        self.transitionImgView = self.currCell.imageView;
        CGRect imgViewFrame = [self.transitionImgView.superview convertRect:self.transitionImgView.frame toView:[UIApplication sharedApplication].keyWindow];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.transitionImgView.layer.transform = CATransform3DIdentity;
        self.transitionImgView.frame = imgViewFrame;
        [[UIApplication sharedApplication].keyWindow addSubview:self.transitionImgView];
        if (self.originImgView) {
            self.transitionImgView.contentMode = originImgView.contentMode;
            self.transitionImgView.layer.masksToBounds = originImgView.layer.masksToBounds;
        }
        [CATransaction commit];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
#pragma clang diagnostic pop
}

- (void)transitionAnimateion:(BOOL)isPresent {
    UIImageView *transitionImgView = self.transitionImgView;
    if (isPresent) {
        self.bgView.alpha = 1;
        JPBrowseImageModel *model = self.dataSource[self.currIndex];
        transitionImgView.frame = CGRectMake(model.contentInset.left, model.contentInset.top, model.contentSize.width, model.contentSize.height);
        transitionImgView.layer.cornerRadius = 0;
        transitionImgView.alpha = 1;
    } else {
        if (self.originImgView) {
            UIView *originImgView = self.originImgView;
            self.bgView.alpha = 0;
            CGRect originPicFrame = [originImgView convertRect:originImgView.bounds toView:[UIApplication sharedApplication].keyWindow];
           transitionImgView.frame = originPicFrame;
            if (self.currCell.model.isCornerRadiusTransition) transitionImgView.layer.cornerRadius = originImgView.layer.cornerRadius;
            if (self.currCell.model.isAlphaTransition) transitionImgView.alpha = 0;
        } else {
            transitionImgView.alpha = 0;
            self.view.alpha = 0;
        }
    }
}

- (void)transitionDoneAnimateion:(BOOL)isPresent complete:(void (^)(void))complete {
    UIImageView *transitionImgView = self.transitionImgView;
    self.originImgView = nil;
    self.transitionImgView = nil;
    if (isPresent) {
        if (self.isShowNavigationBar) {
            [UIView animateWithDuration:0.3 animations:^{
                self.topView.layer.opacity = 1;
                self.bottomView.layer.opacity = 1;
            }];
        }
        self.isPresentDone = YES;
        [self.currCell showImageView];
    } else {
        if ([self.delegate respondsToSelector:@selector(dismissComplete:)]) [self.delegate dismissComplete:self.currIndex];
    }
    [UIView animateWithDuration:0.15 animations:^{
        transitionImgView.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionImgView removeFromSuperview];
        !complete ? : complete();
    }];
}

#pragma mark dismiss动画

- (void)dismiss {
    if (self.isShowNavigationBar) {
        self.topView.layer.opacity = 0;
        self.bottomView.layer.opacity = 0;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setter

- (void)setScrollIndex:(NSInteger)scrollIndex {
    if (_scrollIndex == scrollIndex) return;
    _scrollIndex = scrollIndex;
    
    self.topView.index = scrollIndex;
    
    JPBrowseImageModel *model = self.dataSource[scrollIndex];
    self.bottomView.synopsis = model.synopsis;
}

#pragma mark - 初始化

+ (instancetype)browseImagesViewControllerWithDelegate:(id<JPBrowseImagesDelegate>)delegate
                                            totalCount:(NSInteger)totalCount
                                             currIndex:(NSInteger)currIndex
                                        isShowProgress:(BOOL)isShowProgress
                                   isShowNavigationBar:(BOOL)isShowNavigationBar {
    if (totalCount <= 0) {
        JPLog(@"别搞笑，重新弄");
        return nil;
    }
    
    if (currIndex < 0) {
        currIndex = 0;
    } else if (currIndex >= totalCount) {
        currIndex = totalCount - 1;
    }
    
    JPBrowseImagesViewController *browseVC = [[JPBrowseImagesViewController alloc] initWithIsShowProgress:isShowProgress isShowNavigationBar:isShowNavigationBar];
    browseVC->_currIndex = currIndex;
    browseVC.delegate = delegate;
    
    NSMutableArray *models = [NSMutableArray array];
    
    BOOL isSetCornerRadiusTransition = [delegate respondsToSelector:@selector(isCornerRadiusTransition:)];
    BOOL isSetAlphaTransition = [delegate respondsToSelector:@selector(isAlphaTransition:)];
    BOOL canGetImageHWScale = [delegate respondsToSelector:@selector(getImageHWScale:)];
    BOOL canGetImageSynopsis = isShowNavigationBar && [delegate respondsToSelector:@selector(getImageSynopsis:)];
    
    for (NSInteger i = 0; i < totalCount; i++) {
        JPBrowseImageModel *model = [[JPBrowseImageModel alloc] init];
        model.index = i;
        
        if (isSetCornerRadiusTransition) model.isCornerRadiusTransition = [delegate isCornerRadiusTransition:i];
        if (isSetAlphaTransition) model.isAlphaTransition = [delegate isAlphaTransition:i];
        
        if (canGetImageHWScale) {
            CGFloat w = JPPortraitScreenWidth;
            CGFloat h = w;
            CGFloat hwScale = [delegate getImageHWScale:i];
            if (hwScale > 0) h = w * hwScale;
            model.imageSize = CGSizeMake(w, h);
        }
        
        // 设置图片信息
        if (canGetImageSynopsis) {
            model.synopsis = [delegate getImageSynopsis:i];
        }
        
        [models addObject:model];
    }
    browseVC.dataSource = models;
    return browseVC;
}

- (instancetype)initWithIsShowProgress:(BOOL)isShowProgress isShowNavigationBar:(BOOL)isShowNavigationBar {
    if (self = [super init]) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.isShowProgress = isShowProgress;
        self.isShowNavigationBar = isShowNavigationBar;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupCollectionView];
    [self setupNavigationBar];
}

- (void)dealloc {
//    [[JPWebImageManager sharedInstance] clearMemory];
    JPLog(@"图片浏览页面挂了，记得清除缓存");
}

#pragma mark - 页面布局

- (void)setupBase {
    self.view.backgroundColor = UIColor.clearColor;
    
    UIView *bgView = [[UIView alloc] initWithFrame:JPPortraitScreenBounds];
    bgView.backgroundColor = UIColor.blackColor;
    bgView.alpha = 0;
    [self.view addSubview:bgView];
    _bgView = bgView;
    
    _scrollIndex = self.currIndex;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = JPViewMargin;
    layout.minimumInteritemSpacing = JPViewMargin;
    layout.itemSize = JPPortraitScreenSize;
    layout.sectionInset = UIEdgeInsetsMake(0, JPViewMargin * 0.5, 0, JPViewMargin * 0.5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-JPViewMargin * 0.5, 0, JPPortraitScreenWidth + JPViewMargin, JPPortraitScreenHeight) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.alwaysBounceHorizontal = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerClass:JPBrowseImageCell.class forCellWithReuseIdentifier:JPBrowseImageCellID];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForItem:self.currIndex inSection:0];
    [collectionView scrollToItemAtIndexPath:startIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)setupNavigationBar {
    if (!self.isShowNavigationBar) return;
    
    JPBrowseImageModel *model = self.dataSource[self.currIndex];
    
    UIButton *dismissBtn = [self.delegate respondsToSelector:@selector(getNavigationDismissButton)] ? [self.delegate getNavigationDismissButton] : nil;
    UIButton *otherBtn = [self.delegate respondsToSelector:@selector(getNavigationOtherButton)] ? [self.delegate getNavigationOtherButton] : nil;
    
    JPBrowseImagesTopView *topView = [JPBrowseImagesTopView browseImagesTopViewWithPictureTotal:self.dataSource.count index:model.index dismissBtn:dismissBtn otherBtn:otherBtn target:self dismissAction:@selector(dismiss) otherAction:@selector(otherHandle)];
    topView.layer.opacity = 0;
    [self.view addSubview:topView];
    self.topView = topView;
        
    JPBrowseImagesBottomView *bottomView = [JPBrowseImagesBottomView browseImagesBottomViewWithSynopsis:model.synopsis];
    bottomView.layer.opacity = 0;
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
}

#pragma mark - 导航栏事件处理

- (void)otherHandle {
    if ([self.delegate respondsToSelector:@selector(browseImagesVC:navigationOtherHandleWithModel:index:)]) {
        JPBrowseImageModel *model = self.dataSource[self.currIndex];
        [self.delegate browseImagesVC:self navigationOtherHandleWithModel:model index:self.currIndex];
    }
}

#pragma mark - 导航栏动画

- (void)hideNavigationBar:(BOOL)isHideNavigationBar {
    if (!self.isShowNavigationBar) return;
    if (self.isHideNavigationBar == isHideNavigationBar) return;
    self.isHideNavigationBar = isHideNavigationBar;
    
    CGRect topViewF = self.topView.frame;
    CGRect bottomViewF = self.bottomView.frame;
    topViewF.origin.y = isHideNavigationBar ? -self.topView.frame.size.height : 0;
    bottomViewF.origin.y = isHideNavigationBar ? JPPortraitScreenHeight : (JPPortraitScreenHeight - self.bottomView.frame.size.height - JPDiffTabBarH);
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = topViewF;
        self.bottomView.frame = bottomViewF;
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return !self.collectionView.isDragging;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPBrowseImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPBrowseImageCellID forIndexPath:indexPath];
    
    if (!cell.superVC) {
        cell.superVC = self;
        cell.panGRDelegate = self;
        
        @jp_weakify(self);
        cell.singleClickBlock = ^{
            @jp_strongify(self);
            if (!self) return;
            if (self.isShowNavigationBar) {
                [self hideNavigationBar:!self.isHideNavigationBar];
                self.isTapToHideNav = self.isHideNavigationBar;
            } else {
                [self dismiss];
            }
        };
        
        cell.beginPanBlock = ^{
            @jp_strongify(self);
            if (!self) return;
            if (self.isShowNavigationBar) [self hideNavigationBar:YES];
        };
        
        cell.endPanBlock = ^{
            @jp_strongify(self);
            if (!self) return;
            if (self.isShowNavigationBar && !self.isTapToHideNav) {
                [self hideNavigationBar:NO];
            }
        };
    }
    
    NSInteger index = indexPath.item;
    
    if (index == self.currIndex) {
        self.currCell = cell;
        if (!self.isPresentDone) {
            [cell hideImageView];
        } else {
            [cell showImageView];
        }
    }
    
    [cell setModel:self.dataSource[index] index:index];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isShowNavigationBar) {
        CGFloat offsetX = scrollView.contentOffset.x;
        CGFloat scale = offsetX / scrollView.frame.size.width;
        NSInteger index = (NSInteger)(scale + 0.5);
        if (index < 0) index = 0;
        if (index > self.dataSource.count) index = self.dataSource.count;
        self.scrollIndex = index;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // scrollView的分页间距为scrollView的宽度
    
    // 需要加上左边间距（左边有5的间距被忽略了）
    CGFloat offsetX = scrollView.contentOffset.x + (JPViewMargin * 0.5);
    
    NSInteger lastIndex = self.currIndex;
    
    _currIndex = (NSInteger)(offsetX / scrollView.frame.size.width);
    
    if ([self.delegate respondsToSelector:@selector(flipImageViewWithLastIndex:currIndex:)]) {
        [self.delegate flipImageViewWithLastIndex:lastIndex currIndex:self.currIndex];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currIndex inSection:0];
    JPBrowseImageCell *cell = (JPBrowseImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.isDisplaying = YES;
    self.currCell = cell;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [JPBrowseImagesTransition presentTransition];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [JPBrowseImagesTransition dismissTransition];
}

@end
