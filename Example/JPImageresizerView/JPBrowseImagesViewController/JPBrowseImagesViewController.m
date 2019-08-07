//
//  JPBrowseImagesViewController.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImagesViewController.h"
#import "JPBrowseImagesTransition.h"
#import "JPBrowseImageCell.h"
#import "JPBrowseImagesTopView.h"
#import "JPBrowseImagesBottomView.h"

@interface JPBrowseImagesViewController () <UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isPresentDone;
@property (nonatomic, assign) BOOL isShowProgress;
@property (nonatomic, assign) BOOL isShowNavigationBar;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, weak) JPBrowseImageCell *currCell;
@property (nonatomic, weak) JPBrowseImagesTopView *topView;
@property (nonatomic, weak) JPBrowseImagesBottomView *bottomView;
@property (nonatomic, assign) BOOL isHideNavigationBar;
@property (nonatomic, assign) BOOL isTapToHideNav; // 是否单击隐藏，如果是，说明是用户点击隐藏的，下拉缩小恢复后就继续隐藏
@property (nonatomic, assign) NSInteger scrollIndex; // 滚动中的下标，四舍五入

@property (nonatomic, weak) UIImageView *originImgView;
@property (nonatomic, weak) UIImageView *transitionImgView;
@end

static NSString *const JPBrowseImageCellID = @"BrowseImageCell";
static NSInteger const JPViewMargin = 10;

@implementation JPBrowseImagesViewController

#pragma mark - 转场动画

- (void)willTransitionAnimateion:(BOOL)isPresent {
    self.originImgView = [self.delegate respondsToSelector:@selector(getOriginImageView:)] ? [self.delegate getOriginImageView:self.currIndex] : nil;
    UIStatusBarStyle statusBarStyle;
    if (isPresent) {
        self.bgView.alpha = 0;
        
        statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        self.statusBarStyle = statusBarStyle;
        statusBarStyle = UIStatusBarStyleLightContent;
        
        JPBrowseImageModel *currModel = self.dataSource[self.currIndex];
        UIImageView *transitionImgView;
        if (self.originImgView) {
            CGRect originPicFrame = [self.originImgView convertRect:self.originImgView.bounds toView:[UIApplication sharedApplication].keyWindow];
            transitionImgView = [[UIImageView alloc] initWithFrame:originPicFrame];
            transitionImgView.image = self.originImgView.image;
            transitionImgView.backgroundColor = self.originImgView.backgroundColor;
            transitionImgView.contentMode = self.originImgView.contentMode;
            transitionImgView.layer.masksToBounds = self.originImgView.layer.masksToBounds;
            if (currModel.isCornerRadiusTransition) transitionImgView.layer.cornerRadius = self.originImgView.layer.cornerRadius;
            if (currModel.isAlphaTransition) transitionImgView.alpha = 0;
        }
        [self.view addSubview:transitionImgView];
        self.transitionImgView = transitionImgView;
        
        if ([self.delegate respondsToSelector:@selector(flipImageViewWithLastIndex:currIndex:)]) [self.delegate flipImageViewWithLastIndex:0 currIndex:self.currIndex];
    } else {
        statusBarStyle = self.statusBarStyle;
        self.currCell.isDismiss = YES;
        CGRect imgViewFrame = self.currCell.imageView.frame;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.currCell.imageView.layer.transform = CATransform3DIdentity;
        self.currCell.imageView.frame = imgViewFrame;
        if (self.originImgView) {
            self.currCell.imageView.contentMode = self.originImgView.contentMode;
            self.currCell.imageView.layer.masksToBounds = self.originImgView.layer.masksToBounds;
        }
        [CATransaction commit];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
}

- (void)transitionAnimateion:(BOOL)isPresent {
    if (isPresent) {
        self.bgView.alpha = 1;
        self.transitionImgView.frame = self.dataSource[self.currIndex].pictureFrame;
        self.transitionImgView.layer.cornerRadius = 0;
        self.transitionImgView.alpha = 1;
    } else {
        if (self.originImgView) {
            self.bgView.alpha = 0;
            CGRect originPicFrame = [self.originImgView convertRect:self.originImgView.bounds toView:[UIApplication sharedApplication].keyWindow];
            originPicFrame.origin.y += self.currCell.scrollView.contentOffset.y;
            self.currCell.imageView.frame = originPicFrame;
            if (self.currCell.model.isCornerRadiusTransition) self.currCell.imageView.layer.cornerRadius = self.originImgView.layer.cornerRadius;
            if (self.currCell.model.isAlphaTransition) self.currCell.imageView.alpha = 0;
        } else {
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
        [UIView animateWithDuration:0.15 animations:^{
            transitionImgView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionImgView removeFromSuperview];
            !complete ? : complete();
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(dismissComplete:)]) [self.delegate dismissComplete:self.currIndex];
        !complete ? : complete();
    }
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
    JPPictureInfoModel *infoModel = model.infoModel;
    self.bottomView.synopsis = infoModel.synopsis;
}

- (void)setCurrIndex:(NSInteger)currIndex {
    _currIndex = currIndex;
}

#pragma mark - 初始化

+ (instancetype)browseImagesViewControllerWithDelegate:(id<JPBrowseImagesDelegate>)delegate
                                            totalCount:(NSInteger)totalCount
                                             currIndex:(NSInteger)currIndex
                                        isShowProgress:(BOOL)isShowProgress
                                   isShowNavigationBar:(BOOL)isShowNavigationBar {
    if (totalCount <= 0) {
        NSLog(@"别搞笑，重新弄");
        return nil;
    }
    
    if (currIndex < 0) {
        currIndex = 0;
    } else if (currIndex >= totalCount) {
        currIndex = totalCount - 1;
    }
    
    JPBrowseImagesViewController *browseVC = [[JPBrowseImagesViewController alloc] initWithIsShowProgress:isShowProgress isShowNavigationBar:isShowNavigationBar];
    browseVC.currIndex = currIndex;
    browseVC.delegate = delegate;
    
    NSMutableArray *models = [NSMutableArray array];
    CGFloat w = browseVC.contentFrame.size.width;
    CGFloat x = 0;
    
    BOOL canGetOriginImageView = [delegate respondsToSelector:@selector(getOriginImageView:)];
    BOOL isSetCornerRadiusTransition = [delegate respondsToSelector:@selector(isCornerRadiusTransition:)];
    BOOL isSetAlphaTransition = [delegate respondsToSelector:@selector(isAlphaTransition:)];
    BOOL canGetImageHWScale = [delegate respondsToSelector:@selector(getImageHWScale:)];
    
    for (NSInteger i = 0; i < totalCount; i++) {
        JPBrowseImageModel *model = [[JPBrowseImageModel alloc] init];
        
        if (isSetCornerRadiusTransition) model.isCornerRadiusTransition = [delegate isCornerRadiusTransition:i];
        if (isSetAlphaTransition) model.isAlphaTransition = [delegate isAlphaTransition:i];
        
        CGFloat h = w;
        if (canGetOriginImageView) {
            UIImageView *originImgView = [delegate getOriginImageView:i];
            if (originImgView.image) {
                model.placeHolderImage = originImgView.image;
                h *= (model.placeHolderImage.size.height / model.placeHolderImage.size.width);
            }
        }
        if (h == w && canGetImageHWScale) {
            CGFloat hwScale = [delegate getImageHWScale:i];
            if (hwScale > 0) h *= hwScale;
        }
        
        CGFloat y = browseVC.contentFrame.origin.y + (browseVC.contentFrame.size.height - h) * 0.5;
        if (y < browseVC.contentFrame.origin.y) y = browseVC.contentFrame.origin.y;
        
        model.pictureFrame = CGRectMake(x, y, w, h);
        
        // 显示导航信息（isShowNavigationBar）就得设置infoModel
        JPPictureInfoModel *infoModel = [JPPictureInfoModel new];
        infoModel.index = i;
        model.infoModel = infoModel;
        
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
        CGFloat diffStatusBarH = 0;
        CGFloat diffTabBarH = 0;
        BOOL isX = [UIScreen mainScreen].bounds.size.height > 736.0;
        if (isX) {
            diffStatusBarH += 24;
            diffTabBarH += 34;
        }
        _contentFrame = CGRectMake(0, diffStatusBarH, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - diffStatusBarH - diffTabBarH);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupCollectionView];
    [self setupNavigationBar];
}

- (void)dealloc {
//    [[JPWebImageManager sharedInstance] clearMemory];
    NSLog(@"图片浏览页面挂了，记得清除缓存");
}

#pragma mark - 页面布局

- (void)setupBase {
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0;
    [self.view addSubview:bgView];
    _bgView = bgView;
    
    _scrollIndex = self.currIndex;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = JPViewMargin;
    layout.minimumInteritemSpacing = JPViewMargin;
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.sectionInset = UIEdgeInsetsMake(0, JPViewMargin * 0.5, 0, JPViewMargin * 0.5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-JPViewMargin * 0.5, 0, [UIScreen mainScreen].bounds.size.width + JPViewMargin, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.alwaysBounceHorizontal = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerClass:[JPBrowseImageCell class] forCellWithReuseIdentifier:JPBrowseImageCellID];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForItem:self.currIndex inSection:0];
    [collectionView scrollToItemAtIndexPath:startIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)setupNavigationBar {
    if (!self.isShowNavigationBar) return;
    
    JPBrowseImageModel *model = self.dataSource[self.currIndex];
    JPPictureInfoModel *infoModel = model.infoModel;
    NSString *dismissIcon = [self.delegate respondsToSelector:@selector(getNavigationDismissIcon)] ? [self.delegate getNavigationDismissIcon] : nil;
    NSString *otherIcon = [self.delegate respondsToSelector:@selector(getNavigationOtherIcon)] ? [self.delegate getNavigationOtherIcon] : nil;
    
    JPBrowseImagesTopView *topView = [JPBrowseImagesTopView browseImagesTopViewWithPictureTotal:self.dataSource.count index:infoModel.index dismissIcon:dismissIcon otherIcon:otherIcon target:self dismissAction:@selector(dismiss) otherAction:@selector(otherHandle)];
    topView.layer.opacity = 0;
    [self.view addSubview:topView];
    self.topView = topView;
        
    JPBrowseImagesBottomView *bottomView = [JPBrowseImagesBottomView browseImagesBottomViewWithSynopsis:infoModel.synopsis];
    bottomView.layer.opacity = 0;
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
}

#pragma mark - 导航栏动画

- (void)hideNavigationBar:(BOOL)isHideNavigationBar {
    if (!self.isShowNavigationBar) return;
    if (self.isHideNavigationBar == isHideNavigationBar) return;
    
    self.isHideNavigationBar = isHideNavigationBar;
    
    CGFloat diffTabBarH = [UIScreen mainScreen].bounds.size.height > 736.0 ? 34 : 0;
    
    CGRect topViewF = self.topView.frame;
    CGRect bottomViewF = self.bottomView.frame;
    topViewF.origin.y = isHideNavigationBar ? -self.topView.frame.size.height : 0;
    bottomViewF.origin.y = isHideNavigationBar ? [UIScreen mainScreen].bounds.size.height : ([UIScreen mainScreen].bounds.size.height - self.bottomView.frame.size.height - diffTabBarH);
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = topViewF;
        self.bottomView.frame = bottomViewF;
    }];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JPBrowseImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPBrowseImageCellID forIndexPath:indexPath];
    
    __weak typeof(self) wSelf = self;
    if (!cell.singleClickBlock) {
        cell.singleClickBlock = ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            if (sSelf.isShowNavigationBar) {
                [sSelf hideNavigationBar:!sSelf.isHideNavigationBar];
                sSelf.isTapToHideNav = sSelf.isHideNavigationBar;
            } else {
                [sSelf dismiss];
            }
        };
    }
    if (!cell.beginPanBlock) {
        cell.beginPanBlock = ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            [sSelf hideNavigationBar:YES];
        };
    }
    if (!cell.endPanBlock) {
        cell.endPanBlock = ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            if (!sSelf.isTapToHideNav) {
                [sSelf hideNavigationBar:NO];
            }
        };
    }
    
    cell.isShowProgress = self.isShowProgress;
    cell.superVC = self;
    cell.panGRDelegate = self;
    
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
    
    self.currIndex = (NSInteger)(offsetX / scrollView.frame.size.width);
    
    if ([self.delegate respondsToSelector:@selector(flipImageViewWithLastIndex:currIndex:)]) {
        [self.delegate flipImageViewWithLastIndex:lastIndex currIndex:self.currIndex];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currIndex inSection:0];
    JPBrowseImageCell *cell = (JPBrowseImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.isDisplaying = YES;
    self.currCell = cell;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return self.statusBarStyle;
//}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [JPBrowseImagesTransition presentTransition];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [JPBrowseImagesTransition dismissTransition];
}

#pragma mark - 导航栏事件处理

- (void)otherHandle {
    if ([self.delegate respondsToSelector:@selector(browseImagesVC:navigationOtherHandleWithModel:index:)]) {
        JPBrowseImageModel *model = self.dataSource[self.currIndex];
        [self.delegate browseImagesVC:self navigationOtherHandleWithModel:model index:self.currIndex];
    }
}

@end
