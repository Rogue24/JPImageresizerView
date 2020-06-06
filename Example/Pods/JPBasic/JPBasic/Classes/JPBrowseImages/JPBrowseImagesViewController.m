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
@property (nonatomic, copy) void (^presentComplete)(void);

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, strong) JPBrowseImageModel *startModel;
@property (nonatomic, weak) UIView *originImgView;
@property (nonatomic, weak) UIImageView *transitionImgView;

@property (nonatomic, weak) JPBrowseImageCell *currCell;
@property (nonatomic, weak) JPBrowseImagesTopView *topView;
@property (nonatomic, weak) JPBrowseImagesBottomView *bottomView;
@property (nonatomic, assign) NSInteger scrollIndex; // 滚动中的下标，四舍五入
@end

static NSString *const JPBrowseImageCellID = @"JPBrowseImageCell";
static NSInteger const JPViewMargin = 10;

@implementation JPBrowseImagesViewController
{
    BOOL _isHideNavigationBar;
}

#pragma mark - setter

- (void)setScrollIndex:(NSInteger)scrollIndex {
    if (_scrollIndex == scrollIndex) return;
    _scrollIndex = scrollIndex;
    
    self.topView.index = scrollIndex;
    
    JPBrowseImageModel *model = self.dataSource[scrollIndex];
    self.bottomView.synopsis = model.synopsis;
}

#pragma mark - 转场动画

- (void)willTransitionAnimateion:(BOOL)isPresent {
    UIView *originImgView = [self.delegate respondsToSelector:@selector(getOriginImageView:)] ? [self.delegate getOriginImageView:self.currIndex] : nil;
    self.originImgView = originImgView;
    
    UIStatusBarStyle statusBarStyle;
    UIImageView *transitionImgView;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (isPresent) {
        self.bgView.alpha = 0;
        self.collectionView.hidden = YES;
        
        statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        self.statusBarStyle = statusBarStyle;
        statusBarStyle = UIStatusBarStyleLightContent;
        
        JPBrowseImageModel *startModel = self.startModel;
        if (originImgView) {
            CGRect originPicFrame = [originImgView convertRect:originImgView.bounds toView:window];
            transitionImgView = [[UIImageView alloc] initWithFrame:originPicFrame];
            
            if ([originImgView respondsToSelector:@selector(image)]) transitionImgView.image = [originImgView performSelector:@selector(image)];
            
            BOOL isCornerRadiusTransition = [self.delegate respondsToSelector:@selector(isCornerRadiusTransition:)] && [self.delegate isCornerRadiusTransition:isPresent];
            if (isCornerRadiusTransition) transitionImgView.layer.cornerRadius = originImgView.layer.cornerRadius;
        } else {
            transitionImgView = [[UIImageView alloc] init];
            transitionImgView.frame = CGRectMake(startModel.contentInset.left,
                                                 JPPortraitScreenHeight,
                                                 startModel.contentSize.width,
                                                 startModel.contentSize.height);
            transitionImgView.backgroundColor = UIColor.lightGrayColor;
        }
        
        BOOL isAlphaTransition = [self.delegate respondsToSelector:@selector(isAlphaTransition:)] && [self.delegate isAlphaTransition:isPresent];
        if (isAlphaTransition) transitionImgView.alpha = 0;
        
        [self.view insertSubview:transitionImgView aboveSubview:self.collectionView];
        
        if ([self.delegate respondsToSelector:@selector(flipImageViewWithLastIndex:currIndex:)]) [self.delegate flipImageViewWithLastIndex:self.currIndex currIndex:self.currIndex];
    } else {
        statusBarStyle = self.statusBarStyle;
        
        self.currCell.isDismiss = YES;
        
        transitionImgView = self.currCell.imageView;
        CGRect imgViewFrame = [transitionImgView.superview convertRect:transitionImgView.frame toView:window];
        [window addSubview:transitionImgView];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        transitionImgView.layer.transform = CATransform3DIdentity;
        transitionImgView.frame = imgViewFrame;
        [CATransaction commit];
    }
    
    if (originImgView) {
        transitionImgView.contentMode = originImgView.contentMode;
        transitionImgView.layer.masksToBounds = originImgView.layer.masksToBounds;
    }
    
    self.transitionImgView = transitionImgView;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
#pragma clang diagnostic pop
}

- (void)transitionAnimateion:(BOOL)isPresent {
    UIImageView *transitionImgView = self.transitionImgView;
    if (isPresent) {
        self.bgView.alpha = 1;
        JPBrowseImageModel *startModel = self.startModel;
        transitionImgView.frame = CGRectMake(startModel.contentInset.left,
                                             startModel.contentInset.top,
                                             startModel.contentSize.width,
                                             startModel.contentSize.height);
        transitionImgView.layer.cornerRadius = 0;
        transitionImgView.alpha = 1;
    } else {
        self.bgView.alpha = 0;
        if (self.originImgView) {
            UIView *originImgView = self.originImgView;
            
            CGRect originPicFrame = [originImgView convertRect:originImgView.bounds toView:[UIApplication sharedApplication].keyWindow];
            transitionImgView.frame = originPicFrame;
            
            BOOL isCornerRadiusTransition = [self.delegate respondsToSelector:@selector(isCornerRadiusTransition:)] && [self.delegate isCornerRadiusTransition:isPresent];
            if (isCornerRadiusTransition) transitionImgView.layer.cornerRadius = originImgView.layer.cornerRadius;
            
            BOOL isAlphaTransition = [self.delegate respondsToSelector:@selector(isAlphaTransition:)] && [self.delegate isAlphaTransition:isPresent];
            if (isAlphaTransition) transitionImgView.alpha = 0;
        } else {
            transitionImgView.alpha = 0;
            transitionImgView.transform = CGAffineTransformMakeScale(0.2, 0.2);
        }
    }
}

- (void)transitionDoneAnimateion:(BOOL)isPresent complete:(void (^)(void))complete {
    self.startModel = nil;
    self.isPresentDone = YES;
    if (isPresent) {
        if (self.currCell) {
            [self __transitionDone:YES complete:complete];
        } else {
            self.presentComplete = complete;
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(dismissComplete:)]) [self.delegate dismissComplete:self.currIndex];
        [self __transitionDone:NO complete:complete];
    }
}

#pragma mark transition结束处理

- (void)__transitionDone:(BOOL)isPresent complete:(void (^)(void))complete {
    UIImageView *transitionImgView = self.transitionImgView;
    UIView *originImgView = self.originImgView;
    self.transitionImgView = nil;
    self.originImgView = nil;
    self.presentComplete = nil;
    self.collectionView.hidden = NO;
    self.currCell.isDisplaying = YES;
    if (!transitionImgView || (!isPresent && !originImgView)) {
        !complete ? : complete();
        return;
    }
    void (^completion)(BOOL finished) = ^(BOOL finished) {
        [transitionImgView removeFromSuperview];
        !complete ? : complete();
    };
    if (isPresent) {
        [UIView transitionWithView:transitionImgView.superview duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            transitionImgView.hidden = YES;
        } completion:completion];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            transitionImgView.alpha = 0;
        } completion:completion];
    }
}

#pragma mark dismiss动画

- (void)dismiss {
    [self __hideNavigationBar:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    JPBrowseImagesViewController *browseVC = [[JPBrowseImagesViewController alloc] initWithIsShowProgress:isShowProgress isShowNavigationBar:isShowNavigationBar delegate:delegate currIndex:currIndex];
    
    BOOL canGetImageHWScale = [delegate respondsToSelector:@selector(getImageHWScale:)];
    BOOL canGetImageSynopsis = isShowNavigationBar && [delegate respondsToSelector:@selector(getImageSynopsis:)];
    
    JPBrowseImageModel * (^createModel)(NSInteger index) = ^(NSInteger index){
        JPBrowseImageModel *model = [[JPBrowseImageModel alloc] init];
        model.index = index;
        
        if (canGetImageHWScale) {
            CGFloat w = JPPortraitScreenWidth;
            CGFloat h = w;
            CGFloat hwScale = [delegate getImageHWScale:index];
            if (hwScale > 0) h = w * hwScale;
            model.imageSize = CGSizeMake(w, h);
        }
        
        // 设置图片信息
        if (canGetImageSynopsis) {
            model.synopsis = [delegate getImageSynopsis:index];
        }
        
        return model;
    };
    
    NSArray<JPBrowseImageModel *> * (^createModels)(NSInteger count) = ^(NSInteger count) {
        NSMutableArray<JPBrowseImageModel *> *models = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i++) {
            JPBrowseImageModel *model = createModel(i);
            [models addObject:model];
        }
        return models;
    };
    
    __weak typeof(browseVC) weakVC = browseVC;
    void (^reloadData)(NSArray<JPBrowseImageModel *> *models, NSInteger index) = ^(NSArray<JPBrowseImageModel *> *models, NSInteger index) {
        if (!weakVC) return;
        
        if (weakVC.isShowNavigationBar) {
            [weakVC.topView resetTotal:models.count withIndex:index];
            weakVC.bottomView.synopsis = [models[index] synopsis];
            [weakVC __hideNavigationBar:NO];
        }
        
        weakVC.dataSource = models;
        [weakVC.collectionView reloadData];
        [weakVC.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    };
    
    browseVC.startModel = createModel(currIndex);
    if (totalCount > 500) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *models = createModels(totalCount);
            dispatch_async(dispatch_get_main_queue(), ^{
                reloadData(models, currIndex);
            });
        });
    } else {
        reloadData(createModels(totalCount), currIndex);
    }
    
    return browseVC;
}

- (instancetype)initWithIsShowProgress:(BOOL)isShowProgress
                   isShowNavigationBar:(BOOL)isShowNavigationBar
                              delegate:(id<JPBrowseImagesDelegate>)delegate
                             currIndex:(NSInteger)currIndex {
    if (self = [super init]) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        _isShowProgress = isShowProgress;
        _isShowNavigationBar = isShowNavigationBar;
        _currIndex = _scrollIndex = currIndex;
        _delegate = delegate;
        _isHideNavigationBar = YES;
        self.view.frame = JPPortraitScreenBounds;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupBase];
    [self __setupCollectionView];
    [self __setupNavigationBar];
}

- (void)dealloc {
//    [[JPWebImageManager sharedInstance] clearMemory];
    JPLog(@"图片浏览页面挂了，记得清除缓存");
}

#pragma mark - 页面布局

- (void)__setupBase {
    self.view.backgroundColor = UIColor.clearColor;
    
    UIView *bgView = [[UIView alloc] initWithFrame:JPPortraitScreenBounds];
    bgView.backgroundColor = UIColor.blackColor;
    bgView.alpha = 0;
    [self.view addSubview:bgView];
    _bgView = bgView;
}

- (void)__setupCollectionView {
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
    collectionView.scrollsToTop = NO;
    [collectionView registerClass:JPBrowseImageCell.class forCellWithReuseIdentifier:JPBrowseImageCellID];
    [self.view insertSubview:collectionView aboveSubview:self.bgView];
    _collectionView = collectionView;
}

- (void)__setupNavigationBar {
    if (!self.isShowNavigationBar) return;
    
    UIButton *dismissBtn = [self.delegate respondsToSelector:@selector(getNavigationDismissButton)] ? [self.delegate getNavigationDismissButton] : nil;
    UIButton *otherBtn = [self.delegate respondsToSelector:@selector(getNavigationOtherButton)] ? [self.delegate getNavigationOtherButton] : nil;
    
    JPBrowseImagesTopView *topView = [JPBrowseImagesTopView browseImagesTopViewWithDismissBtn:dismissBtn otherBtn:otherBtn target:self dismissAction:@selector(dismiss) otherAction:@selector(otherHandle)];
    topView.alpha = 0;
    [self.view addSubview:topView];
    self.topView = topView;
        
    JPBrowseImagesBottomView *bottomView = [JPBrowseImagesBottomView browseImagesBottomView];
    bottomView.alpha = 0;
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
}

#pragma mark - 导航栏动画

- (void)__hideNavigationBar:(BOOL)isHideNavigationBar {
    if (!self.isShowNavigationBar) return;
    if (_isHideNavigationBar == isHideNavigationBar) return;
    _isHideNavigationBar = isHideNavigationBar;
    
    CGRect topViewF = self.topView.frame;
    CGRect bottomViewF = self.bottomView.frame;
    topViewF.origin.y = isHideNavigationBar ? -self.topView.frame.size.height : 0;
    bottomViewF.origin.y = JPPortraitScreenHeight - (isHideNavigationBar ? 0 : (bottomViewF.size.height + JPDiffTabBarH));
    
    CGFloat alpha = isHideNavigationBar ? 0 : 1;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.alpha = self.bottomView.alpha = alpha;
        self.topView.frame = topViewF;
        self.bottomView.frame = bottomViewF;
    }];
}

#pragma mark - 导航栏事件处理

- (void)otherHandle {
    if ([self.delegate respondsToSelector:@selector(browseImagesVC:navigationOtherHandleWithModel:index:)]) {
        JPBrowseImageModel *model = self.dataSource[self.currIndex];
        [self.delegate browseImagesVC:self navigationOtherHandleWithModel:model index:self.currIndex];
    }
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
                [self __hideNavigationBar:!self->_isHideNavigationBar];
            } else {
                [self dismiss];
            }
        };
        cell.beginPanBlock = ^{
            @jp_strongify(self);
            if (!self) return;
            [self __hideNavigationBar:YES];
        };
        cell.endPanBlock = ^{
            @jp_strongify(self);
            if (!self) return;
            [self __hideNavigationBar:NO];
        };
    }
    
    NSInteger index = indexPath.item;
    [cell setModel:self.dataSource[index] index:index];
    
    if (index == self.currIndex) {
        self.currCell = cell;
        if (self.presentComplete != nil) {
            [self __transitionDone:YES complete:self.presentComplete];
        }
    }
    
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
