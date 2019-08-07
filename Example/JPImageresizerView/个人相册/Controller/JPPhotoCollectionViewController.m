//
//  JPPhotoCollectionViewController.m
//  Infinitee2.0
//
//  Created by 周健平 on 2018/8/10.
//  Copyright © 2018 Infinitee. All rights reserved.
//

#import "JPPhotoCollectionViewController.h"
#import "JPAlbumViewModel.h"
#import "JPPhotoCell.h"
#import "NoDataView.h"
#import "JPPhotoCollectionViewFlowLayout.h"
#import "JPBrowseImagesViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "JPViewController.h"

@interface JPPhotoCollectionViewController () <JPBrowseImagesDelegate>

@end

@implementation JPPhotoCollectionViewController
{
    CGFloat _photoSideMargin;
    CGFloat _photoCellSpace;
    
    NSInteger _photoMaxCol;
    CGFloat _photoMaxWhScale;
    CGFloat _photoMaxW;
    CGFloat _photoBaseH;
    
    BOOL _isRequested;
    CGFloat _extraWidth;
}

#pragma mark - const

static NSString *const JPPhotoCellID = @"JPPhotoCell";

#pragma mark - setter

- (void)setAlbumVM:(JPAlbumViewModel *)albumVM {
    if (_albumVM == albumVM) {
        return;
    }
    _albumVM = albumVM;
    if (_photoVMs.count) {
        [self.photoVMs removeAllObjects];
        [self.collectionView reloadData];
    }
}

#pragma mark - getter

- (NSMutableArray<JPPhotoViewModel *> *)photoVMs {
    if (!_photoVMs) {
        _photoVMs = [NSMutableArray array];
    }
    return _photoVMs;
}

#pragma mark - init

+ (JPPhotoCollectionViewController *)pcVCWithAlbumVM:(JPAlbumViewModel *)albumVM
                                          sideMargin:(CGFloat)sideMargin
                                           cellSpace:(CGFloat)cellSpace
                                          maxWHSclae:(CGFloat)maxWHSclae
                                              maxCol:(NSInteger)maxCol
                                        pcVCDelegate:(id<JPPhotoCollectionViewControllerDelegate>)pcVCDelegate {
    JPPhotoCollectionViewFlowLayout *flowLayout = [[JPPhotoCollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(sideMargin, sideMargin, sideMargin, sideMargin);
    flowLayout.minimumLineSpacing = cellSpace;
    flowLayout.minimumInteritemSpacing = cellSpace;
    
    JPPhotoCollectionViewController *pcVC = [[self alloc] initWithCollectionViewLayout:flowLayout photoSideMargin:sideMargin photoCellSpace:cellSpace photoMaxWhScale:maxWHSclae photoMaxCol:maxCol];
    pcVC.pcVCDelegate = pcVCDelegate;
    pcVC.albumVM = albumVM;
    
    __weak typeof(pcVC) wPcVC = pcVC;
    flowLayout.getLayoutAttributeFrame = ^CGRect(NSIndexPath * _Nonnull indexPath) {
        __strong typeof(wPcVC) sPcVC = wPcVC;
        if (!sPcVC) return CGRectZero;
        JPPhotoViewModel *photoVM = sPcVC.photoVMs[indexPath.item];
        return photoVM.jp_itemFrame;
    };
    
    return pcVC;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
                             photoSideMargin:(CGFloat)photoSideMargin
                              photoCellSpace:(CGFloat)photoCellSpace
                             photoMaxWhScale:(CGFloat)photoMaxWhScale
                                 photoMaxCol:(CGFloat)photoMaxCol {
    if (self = [super initWithCollectionViewLayout:layout]) {
        _photoSideMargin = photoSideMargin;
        _photoCellSpace = photoCellSpace;
        _photoMaxWhScale = photoMaxWhScale;
        _photoMaxCol = photoMaxCol;
        _photoMaxW = [UIScreen mainScreen].bounds.size.width - photoSideMargin * 2;
        _photoBaseH = _photoMaxW * 0.5;
        _showScale = 1;
        _extraWidth = 80.0 * ([UIScreen mainScreen].bounds.size.width / 375.0);
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageViewScrollDidEndHandle) name:@"JPPhotoPageViewScrollDidEnd" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setup subviews

- (void)setupCollectionView {
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:JPPhotoCell.class forCellWithReuseIdentifier:JPPhotoCellID];
}

#pragma mark - private method

- (void)pageViewScrollDidEndHandle {
    if (self.hideScale != 0) {
        self.hideScale = 0;
        _showScale = 1;
    }
    if (self.showScale != 1) {
        self.showScale = 1;
        _hideScale = 0;
    }
}

#pragma mark - public method

- (void)setHideScale:(CGFloat)hideScale {
    _hideScale = hideScale;
    
    if (self.collectionView.visibleCells.count == 0) return;
    for (UICollectionViewCell<JPPictureChooseCellProtocol> *cell in self.collectionView.visibleCells) {
        CGFloat layerScale = 1;
        CGFloat opacity = 1;
        CGFloat startScale = cell.startScale;
        CGFloat endScale = cell.endScale;
        CGFloat totalScale = cell.totalScale;
        if (hideScale >= startScale && hideScale < endScale) {
            // 隐藏比例在cell的区域内
            CGFloat currScale = (hideScale - cell.startScale) / totalScale;
            layerScale = 0.8 + 0.2 * (1 - currScale);
            opacity = 1 - currScale;
        } else if (hideScale >= endScale) {
            // 隐藏比例已经包含cell的最后位置
            layerScale = 0.8;
            opacity = 0;
        } else {
            // 隐藏比例已经落后cell的起始位置
            layerScale = 1;
            opacity = 1;
        }
        cell.layer.transform = CATransform3DMakeScale(layerScale, layerScale, 1);
        cell.layer.opacity = opacity;
    }
}

- (void)setShowScale:(CGFloat)showScale {
    _showScale = showScale;
    
    if (self.collectionView.visibleCells.count == 0) return;
    for (UICollectionViewCell<JPPictureChooseCellProtocol> *cell in self.collectionView.visibleCells) {
        CGFloat layerScale;
        CGFloat opacity;
        CGFloat startScale = cell.startScale;
        CGFloat endScale = cell.endScale;
        CGFloat totalScale = cell.totalScale;
        if (showScale >= startScale && showScale < endScale) {
            // 显示比例在cell的区域内
            CGFloat currScale = (showScale - startScale) / totalScale;
            layerScale = 0.8 + 0.2 * currScale;
            opacity = currScale;
        } else if (showScale >= endScale) {
            // 显示比例已经包含cell的最后位置
            layerScale = 1;
            opacity = 1;
        } else {
            // 显示比例已经落后cell的起始位置
            layerScale = 0.8;
            opacity = 0;
        }
        cell.layer.transform = CATransform3DMakeScale(layerScale, layerScale, 1);
        cell.layer.opacity = opacity;
    }
}

- (void)willBeginScorllHandle {
    [self.collectionView setContentOffset:self.collectionView.contentOffset animated:YES];
    if (self.collectionView.visibleCells.count) {
        CGFloat collectionViewW = self.collectionView.frame.size.width;
        for (UICollectionViewCell<JPPictureChooseCellProtocol> *cell in self.collectionView.visibleCells) {
            cell.startScale = (cell.frame.origin.x - _photoSideMargin) / collectionViewW;
            if (cell.startScale < 0) cell.startScale = 0;
            cell.endScale = (CGRectGetMaxX(cell.frame) + _extraWidth) / collectionViewW;
            if (cell.endScale > 1) cell.endScale = 1;
            cell.totalScale = cell.endScale - cell.startScale;
        }
    }
}



- (void)requestPhotosWithComplete:(void (^)(NSInteger))complete {
    if (_isRequested) return;
    _isRequested = YES;
    
    NoDataView *noDataView = [NoDataView noDataViewWithTitle:@"正在获取照片..." onView:self.collectionView center:CGPointMake(self.collectionView.frame.size.width * 0.5, self.collectionView.frame.size.height * 0.4)];
    noDataView.alpha = 0;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    [UIView animateWithDuration:0.25 animations:^{
        noDataView.alpha = 1;
    } completion:^(BOOL finished) {
        __weak typeof(self) wSelf = self;
        [JPPhotoToolSI getAssetsInAssetCollection:self.albumVM.assetCollection fastEnumeration:^(PHAsset *asset, NSInteger index, NSInteger totalCount) {
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            JPPhotoViewModel *photoVM = [[JPPhotoViewModel alloc] initWithAsset:asset];
            [sSelf.photoVMs addObject:photoVM];
        } completion:^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            [JPLiquidLayoutTool calculateItemFrames:sSelf.photoVMs
                                          targetRow:0
                                         flowLayout:flowLayout
                                           maxWidth:sSelf->_photoMaxW
                                         baseHeight:sSelf->_photoBaseH
                                     itemMaxWhScale:sSelf->_photoMaxWhScale
                                             maxCol:sSelf->_photoMaxCol];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger photoTotal = sSelf.photoVMs.count;
                if (photoTotal > 0) {
                    [UIView animateWithDuration:0.2 animations:^{
                        noDataView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [noDataView removeFromSuperview];
                    }];
                    [sSelf.collectionView performBatchUpdates:^{
                        [sSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    } completion:nil];
                } else {
                    noDataView.title = @"该相册没有照片";
                }
                !complete ? : complete(photoTotal);
            });
        }];
    }];
}

- (void)insertPhotoVM:(JPPhotoViewModel *)photoVM atIndex:(NSInteger)index {
    [self.photoVMs insertObject:photoVM atIndex:index];
    [JPLiquidLayoutTool updateItemFrames:self.photoVMs
                             targetIndex:index
                              flowLayout:(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout
                                maxWidth:_photoMaxW
                              baseHeight:_photoBaseH
                          itemMaxWhScale:_photoMaxWhScale
                                  maxCol:_photoMaxCol];
    [UIView animateWithDuration:0.65 delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:0.1 options:kNilOptions animations:^{
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        } completion:nil];
    } completion:nil];
}

- (void)removeSelectedPhotoVMs {
    if (self.albumVM.selectedPhotoVMs.count == 0) return;
    for (JPPhotoViewModel *photoVM in self.albumVM.selectedPhotoVMs) {
        photoVM.isSelected = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.photoVMs indexOfObject:photoVM] inSection:0];
        JPPhotoCell *cell = (JPPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) [cell updateSelectedState:NO animate:YES];
    }
    [self.albumVM.selectedPhotoVMs removeAllObjects];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoVMs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPPhotoCellID forIndexPath:indexPath];
    
    cell.photoVM = self.photoVMs[indexPath.item];
    
    __weak typeof(self) wSelf = self;
    
//    cell.longPressBlock = ^(JPPhotoCell *pCell) {
//        __strong typeof(wSelf) sSelf = wSelf;
//        if (!sSelf) return;
//        [sSelf browsePhotoWithIndexPath:indexPath];
//    };
    
    cell.tapBlock = ^(JPPhotoCell *pCell) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return NO;
        [sSelf browsePhotoWithIndexPath:indexPath];
        return NO;
//        if ([sSelf.pcVCDelegate respondsToSelector:@selector(pcVC:photoDidSelected:)]) {
//            return [sSelf.pcVCDelegate pcVC:sSelf photoDidSelected:pCell.photoVM];
//        } else {
//            return NO;
//        }
    };
    
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPPhotoViewModel *photoVM = self.photoVMs[indexPath.item];
    return photoVM.jp_itemFrame.size;
}

#pragma mark - <UICollectionViewDelegate>

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    __weak typeof(self) wSelf = self;
    [JPPhotoToolSI updateCachedAssetsWithStartCachingBlock:^(NSArray *indexPaths, GetAssetsCompletion getAssetsCompletion) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        NSArray *assets = [sSelf assetsAtIndexPaths:indexPaths];
        getAssetsCompletion(assets);
    } stopCachingBlock:^(NSArray *indexPaths, GetAssetsCompletion getAssetsCompletion) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        NSArray *assets = [sSelf assetsAtIndexPaths:indexPaths];
        getAssetsCompletion(assets);
    }];
}

#pragma mark - Asset Caching

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        JPPhotoViewModel *photoVM = self.photoVMs[indexPath.item];
        if (photoVM.asset) [assets addObject:photoVM.asset];
    }
    return assets;
}

#pragma mark - JPPhotoCellDelegate（浏览大图）

- (void)browsePhotoWithIndexPath:(NSIndexPath *)indexPath {
    JPBrowseImagesViewController *browseVC = [JPBrowseImagesViewController browseImagesViewControllerWithDelegate:self totalCount:self.photoVMs.count currIndex:indexPath.item isShowProgress:YES isShowNavigationBar:YES];
    [self presentViewController:browseVC animated:YES completion:nil];
}

#pragma mark - <JPBrowseImagesDelegate>

- (UIImageView *)getOriginImageView:(NSInteger)currIndex {
    JPBrowseImageCell *cell = (JPBrowseImageCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currIndex inSection:0]];
    return cell.imageView;
}

- (CGFloat)getImageHWScale:(NSInteger)currIndex {
    JPPhotoViewModel *photoVM = self.photoVMs[currIndex];
    return photoVM.jp_whScale;
}

- (BOOL)isCornerRadiusTransition:(NSInteger)currIndex {
    return NO;
}

- (BOOL)isAlphaTransition:(NSInteger)currIndex {
    return NO;
}

- (void)flipImageViewWithLastIndex:(NSInteger)lastIndex currIndex:(NSInteger)currIndex {
    UICollectionViewCell *lastCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:lastIndex inSection:0]];
    lastCell.hidden = NO;
    UICollectionViewCell *currCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currIndex inSection:0]];
    currCell.hidden = YES;
}

- (void)dismissComplete:(NSInteger)currIndex {
    UICollectionViewCell *currCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currIndex inSection:0]];
    currCell.hidden = NO;
}

- (void)cellRequestImage:(JPBrowseImageCell *)cell
                   index:(NSInteger)index
           progressBlock:(void (^)(NSInteger, JPBrowseImageModel *, float))progressBlock
           completeBlock:(void (^)(NSInteger, JPBrowseImageModel *, UIImage *))completeBlock {
    JPPhotoViewModel *photoVM = self.photoVMs[index];
    __weak typeof(self) wSelf = self;
    __weak JPBrowseImageModel *wModel = cell.model;
    __weak typeof(photoVM) wPhotoVM = photoVM;
    [JPPhotoToolSI requestLargePhotoForAsset:photoVM.asset targetSize:photoVM.originPhotoSize isFastMode:NO isShouldFixOrientation:NO resultHandler:^(PHAsset *requestAsset, UIImage *result, NSDictionary *info) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf || !wModel || !wPhotoVM) return;
        !completeBlock ? : completeBlock(index, wModel, result);
    }];
}

- (void)requestImageFailWithModel:(JPBrowseImageModel *)model index:(NSInteger)index {
    [SVProgressHUD showErrorWithStatus:@"照片获取失败"];
}

- (NSString *)getNavigationDismissIcon {
    return @"jp_back";
}

- (NSString *)getNavigationOtherIcon {
    return @"jp_clipper";
}

- (void)browseImagesVC:(JPBrowseImagesViewController *)browseImagesVC navigationOtherHandleWithModel:(JPBrowseImageModel *)model index:(NSInteger)index {
    JPPhotoViewModel *photoVM = self.photoVMs[index];
    [SVProgressHUD show];
    __weak typeof(self) wSelf = self;
    [JPPhotoToolSI requestLargePhotoForAsset:photoVM.asset targetSize:PHImageManagerMaximumSize isFastMode:NO isShouldFixOrientation:NO resultHandler:^(PHAsset *requestAsset, UIImage *result, NSDictionary *info) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        if (result) {
            [SVProgressHUD dismiss];
            [sSelf imageresizerWithImage:result fromVC:browseImagesVC];
        } else {
            [SVProgressHUD showErrorWithStatus:@"照片获取失败"];
        }
    }];
}

#pragma mark - 裁剪照片

- (void)imageresizerWithImage:(UIImage *)image fromVC:(UIViewController *)fromVC {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(50, 0, (40 + 30 + 30 + 10), 0);
    BOOL isX = [UIScreen mainScreen].bounds.size.height > 736.0;
    if (isX) {
        contentInsets.top += 24;
        contentInsets.bottom += 34;
    }
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:image make:^(JPImageresizerConfigure *kConfigure) {
        kConfigure.jp_contentInsets(contentInsets);
    }];
    JPViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JPViewController"];
    vc.statusBarStyle = UIStatusBarStyleLightContent;
    vc.configure = configure;
    [fromVC presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

@end
