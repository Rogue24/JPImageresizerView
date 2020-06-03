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
#import "JPViewController.h"
#import "UIViewController+JPExtension.h"

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
    CGFloat _extraWidth;
    
    BOOL _isRequested;
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
    flowLayout.sectionInset = UIEdgeInsetsMake(sideMargin, sideMargin, sideMargin + JPDiffTabBarH, sideMargin);
    flowLayout.minimumLineSpacing = cellSpace;
    flowLayout.minimumInteritemSpacing = cellSpace;
    
    JPPhotoCollectionViewController *pcVC = [[self alloc] initWithCollectionViewLayout:flowLayout photoSideMargin:sideMargin photoCellSpace:cellSpace photoMaxWhScale:maxWHSclae photoMaxCol:maxCol];
    pcVC.pcVCDelegate = pcVCDelegate;
    pcVC.albumVM = albumVM;
    
    @jp_weakify(pcVC);
    flowLayout.getLayoutAttributeFrame = ^CGRect(NSIndexPath * _Nonnull indexPath) {
        @jp_strongify(pcVC);
        if (!pcVC) return CGRectZero;
        JPPhotoViewModel *photoVM = pcVC.photoVMs[indexPath.item];
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
        _photoMaxW = JPPortraitScreenWidth - photoSideMargin * 2;
        _photoBaseH = _photoMaxW * 0.5;
        _extraWidth = JPScaleValue(80);
        _showScale = 1;
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
    [self jp_contentInsetAdjustmentNever:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = YES;
    [self.collectionView registerClass:JPPhotoCell.class forCellWithReuseIdentifier:JPPhotoCellID];
}

#pragma mark - notification method

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
        CGFloat collectionViewW = self.collectionView.jp_width;
        for (UICollectionViewCell<JPPictureChooseCellProtocol> *cell in self.collectionView.visibleCells) {
            cell.startScale = (cell.jp_x - _photoSideMargin) / collectionViewW;
            if (cell.startScale < 0) cell.startScale = 0;
            cell.endScale = (cell.jp_maxX + _extraWidth) / collectionViewW;
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
        [JPPhotoToolSI getAssetsInAssetCollection:self.albumVM.assetCollection fastEnumeration:^(PHAsset *asset, NSUInteger index, NSUInteger totalCount) {
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
    cell.index = indexPath.item;
    cell.photoVM = self.photoVMs[indexPath.item];
    
    if (!cell.tapBlock) {
        @jp_weakify(self);
        cell.tapBlock = ^(JPPhotoCell *pCell) {
            @jp_strongify(self);
            if (!self) return NO;
            [self browsePhotoWithIndex:pCell.index];
            return NO;
        };
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPPhotoViewModel *photoVM = self.photoVMs[indexPath.item];
    return photoVM.jp_itemFrame.size;
}

#pragma mark - JPPhotoCellDelegate（浏览大图）

- (void)browsePhotoWithIndex:(NSInteger)index {
    JPBrowseImagesViewController *browseVC = [JPBrowseImagesViewController browseImagesViewControllerWithDelegate:self totalCount:self.photoVMs.count currIndex:index isShowProgress:NO isShowNavigationBar:YES];
    [self presentViewController:browseVC animated:YES completion:nil];
}

#pragma mark - <JPBrowseImagesDelegate>

- (UIView *)getOriginImageView:(NSInteger)currIndex {
    JPPhotoCell *cell = (JPPhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currIndex inSection:0]];
    return cell.imageView;
}

- (CGFloat)getImageHWScale:(NSInteger)currIndex {
    JPPhotoViewModel *photoVM = self.photoVMs[currIndex];
    return photoVM.jp_whScale > 0.0 ? (1.0 / photoVM.jp_whScale) : 0;
}

- (NSString *)getImageSynopsis:(NSInteger)currIndex {
    static NSDateFormatter *dateFormatter_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter_ = [[NSDateFormatter alloc] init];
        [dateFormatter_ setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    });
    JPPhotoViewModel *photoVM = self.photoVMs[currIndex];
    return [NSString stringWithFormat:@"创建于 %@", [dateFormatter_ stringFromDate:photoVM.asset.creationDate]];
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
    [JPPhotoToolSI requestOriginalPhotoImageForAsset:photoVM.asset isFastMode:NO isFixOrientation:NO isJustGetFinalPhoto:YES resultHandler:^(PHAsset *requestAsset, UIImage *resultImage, BOOL isFinalImage) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf || !wModel || !wPhotoVM) return;
        !completeBlock ? : completeBlock(index, wModel, resultImage);
    }];
}

- (void)requestImageFailWithModel:(JPBrowseImageModel *)model index:(NSInteger)index {
    [JPProgressHUD showErrorWithStatus:@"照片获取失败" userInteractionEnabled:YES];
}

- (NSString *)getNavigationDismissIcon {
    return @"back";
}

- (NSString *)getNavigationOtherIcon {
    return @"clipper";
}

- (void)browseImagesVC:(JPBrowseImagesViewController *)browseImagesVC navigationOtherHandleWithModel:(JPBrowseImageModel *)model index:(NSInteger)index {
    JPBrowseImageCell *cell = (JPBrowseImageCell *)[browseImagesVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell.isSetingImage) {
        [JPProgressHUD showInfoWithStatus:@"照片获取中请稍后" userInteractionEnabled:YES];
        return;
    }
    if (!cell.isSetImageSuccess) {
        [JPProgressHUD showErrorWithStatus:@"照片获取失败" userInteractionEnabled:YES];
        return;
    }
    [self imageresizerWithImage:cell.imageView.image fromVC:browseImagesVC];
}

#pragma mark - 裁剪照片

- (void)imageresizerWithImage:(UIImage *)image fromVC:(UIViewController *)fromVC {
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:image make:nil];
    JPViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JPViewController"];
    vc.statusBarStyle = UIStatusBarStyleLightContent;
    vc.configure = configure;
    
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:vc];
    navCtr.modalPresentationStyle = UIModalPresentationFullScreen;
    
    CATransition *cubeAnim = [CATransition animation];
    cubeAnim.duration = 0.5;
    cubeAnim.type = @"cube";
    cubeAnim.subtype = kCATransitionFromRight;
    cubeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.window.layer addAnimation:cubeAnim forKey:@"cube"];
    
    [fromVC presentViewController:navCtr animated:NO completion:nil];
}

@end
