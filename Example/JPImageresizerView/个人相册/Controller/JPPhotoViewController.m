//
//  JPPhotoViewController.m
//  Infinitee2.0
//
//  Created by 周健平 on 2018/2/23.
//  Copyright © 2018年 Infinitee. All rights reserved.
//

#import "JPPhotoViewController.h"
#import "WMPageController.h"
#import "JPAlbumViewModel.h"
#import "JPPhotoCollectionViewController.h"
#import "JPCategoryTitleView.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <pop/POP.h>
#import "JPViewController.h"

@interface JPPhotoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, WMPageControllerDataSource, WMPageControllerDelegate, JPPhotoCollectionViewControllerDelegate>
@property (nonatomic, weak) WMPageController *pageCtr;
@property (nonatomic, weak) UILabel *navTitleLabel;
@property (nonatomic, weak) JPCategoryTitleView *titleView;
@property (nonatomic, strong) NSMutableDictionary *pageContentViewFrames;
@property (nonatomic, strong) NSMutableDictionary *photoCollectionVCs;
@end

@implementation JPPhotoViewController
{
    BOOL _isDragging;
    CGFloat _startOffsetX;
}

#pragma mark - const

#pragma mark - setter

#pragma mark - getter

- (NSMutableDictionary *)photoCollectionVCs {
    if (!_photoCollectionVCs) {
        _photoCollectionVCs = [NSMutableDictionary dictionary];
    }
    return _photoCollectionVCs;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupNavigationBar];
    [self setupCategoryTitleView];
    [self setupPageController];
    [self setupAlbums];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    NSLog(@"photoViewController is dead");
}

#pragma mark - setup

- (void)setupBase {
    self.view.backgroundColor = UIColor.whiteColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupNavigationBar {
    self.title = @"用户相册";
    UIButton *camceraBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setTitle:@"拍照" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(camcera) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:camceraBtn];
}

- (void)setupCategoryTitleView {
    JPCategoryTitleView *titleView = [JPCategoryTitleView categoryTitleViewWithSideMargin:15 cellSpace:20];
    [self.view addSubview:titleView];
    self.titleView = titleView;
    
    __weak typeof(self) wSelf = self;
    
    titleView.selectedIndexPathDidChange = ^(NSIndexPath *selectedIndexPath) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        NSInteger diffIndex = sSelf.pageCtr.selectIndex - selectedIndexPath.item;
        if (diffIndex == 0 || sSelf.pageCtr.scrollView.dragging) {
            return;
        } else if (labs(diffIndex) == 1) {
            [sSelf.pageCtr.scrollView setContentOffset:CGPointMake(sSelf.pageCtr.scrollView.frame.size.width * selectedIndexPath.item, 0) animated:YES];
        } else {
            UIView *snapshotView = [sSelf.pageCtr.scrollView.superview snapshotViewAfterScreenUpdates:NO];
            [sSelf.pageCtr.scrollView.superview insertSubview:snapshotView aboveSubview:sSelf.pageCtr.scrollView];
            
            BOOL isTurnLeft = diffIndex > 0;
            CGFloat width = sSelf.pageCtr.scrollView.frame.size.width;
            
            sSelf.pageCtr.scrollView.transform = CGAffineTransformMakeTranslation((isTurnLeft ? -1.0 : 1.0) * width, 0);
            [sSelf.pageCtr.scrollView setContentOffset:CGPointMake(width * selectedIndexPath.item, 0)];
            
            [UIView animateWithDuration:0.35 animations:^{
                sSelf.pageCtr.scrollView.transform = CGAffineTransformIdentity;
                snapshotView.transform = CGAffineTransformMakeTranslation((isTurnLeft ? 1.0 : -1.0) * width, 0);
            } completion:^(BOOL finished) {
                [snapshotView removeFromSuperview];
                [sSelf.pageCtr scrollViewDidEndDecelerating:sSelf.pageCtr.scrollView];
            }];
        }
    };
    
    titleView.isNeedAnimatedDidChange = ^(BOOL isNeedAnimated) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        sSelf.view.userInteractionEnabled = !isNeedAnimated;
    };
}

- (void)setupPageController {
    WMPageController *pageCtr = [[WMPageController alloc] init];
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.titleView.frame);
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height - y;
    pageCtr.viewFrame = CGRectMake(x, y, w, h);
    pageCtr.dataSource = self;
    pageCtr.delegate = self;
    [self.view addSubview:pageCtr.view];
    [self addChildViewController:pageCtr];
    self.pageCtr = pageCtr;
}

#pragma mark - 导航栏按钮响应

- (void)back {
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)camcera {
    __weak typeof(self) wSelf = self;
    [JPPhotoToolSI cameraAuthorityWithAllowAccessAuthorityHandler:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf photograph];
    } refuseAccessAuthorityHandler:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf photograph];
    } alreadyRefuseAccessAuthorityHandler:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf photograph];
    } canNotAccessAuthorityHandler:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf photograph];
    }];
}

#pragma mark - 判断相册权限

- (void)setupAlbums {
    __weak typeof(self) wSelf = self;
    [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [SVProgressHUD show];
        [sSelf setupDataSource];
    } refuseAccessAuthorityHandler:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf setupDataSource];
    } alreadyRefuseAccessAuthorityHandler:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf setupDataSource];
    } canNotAccessAuthorityHandler:nil isRegisterChange:YES];
}

#pragma mark - 配置相册数据源

- (void)setupDataSource {
    self.pageContentViewFrames = [NSMutableDictionary dictionary];
    [SVProgressHUD show];
    __weak typeof(self) wSelf = self;
    [JPPhotoToolSI getAllAssetCollectionWithFastEnumeration:^(PHAssetCollection *collection, NSInteger index, NSInteger totalCount) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        JPAlbumViewModel *albumVM = [JPAlbumViewModel albumViewModelWithAssetCollection:collection assetTotalCount:totalCount];
        [sSelf.titleView.titleVMs addObject:albumVM];
        
        CGFloat w = sSelf.pageCtr.viewFrame.size.width;
        CGFloat x = index * w;
        CGFloat y = 0;
        CGFloat h = sSelf.pageCtr.viewFrame.size.height;
        CGRect frame = CGRectMake(x, y, w, h);
        sSelf.pageContentViewFrames[@(index)] = @(frame);
    } completion:^{
        [SVProgressHUD dismiss];
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        [sSelf.titleView reloadDataWithAnimated:YES];
        [sSelf.pageCtr reloadData];
    }];
}

#pragma mark - 拍照

- (void)photograph {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController相关逻辑

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (picker.sourceType != UIImagePickerControllerSourceTypeCamera) return;
    
    // 获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) return;
    
    __weak typeof(self) wSelf = self;
    [JPPhotoToolSI savePhotoWithImage:image successHandle:^(NSString *assetID) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [sSelf imageresizerWithImage:image];
            
            if (sSelf.titleView.titleVMs.count == 0) return;
            JPAlbumViewModel *albumVM = (JPAlbumViewModel *)sSelf.titleView.titleVMs.firstObject;
            albumVM.count = [NSString stringWithFormat:@"%zd", albumVM.count.integerValue + 1];
            [sSelf.titleView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            
            for (JPPhotoCollectionViewController *pcVC in sSelf.pageCtr.childViewControllers) {
                if (pcVC.albumVM == albumVM) {
                    PHAsset *asset = [JPPhotoToolSI getNewestAsset];
                    JPPhotoViewModel *photoVM = [[JPPhotoViewModel alloc] initWithAsset:asset];
                    [pcVC insertPhotoVM:photoVM atIndex:0];
                    break;
                }
            }
        }];
        
    } failHandle:^{
        [SVProgressHUD showErrorWithStatus:@"图片保存失败"];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - 裁剪图片

- (void)imageresizerWithImage:(UIImage *)image {
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
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 请求照片

- (void)pcVC:(JPPhotoCollectionViewController *)pcVC requestPhotosWithIndex:(NSInteger)index {
    __weak typeof(self) wSelf = self;
    [pcVC requestPhotosWithComplete:^(NSInteger photoTotal) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        JPAlbumViewModel *albumVM = (JPAlbumViewModel *)sSelf.titleView.titleVMs[index];
        if (albumVM.count.integerValue != photoTotal) {
            albumVM.count = [NSString stringWithFormat:@"%zd", photoTotal];
            [UIView performWithoutAnimation:^{
                [sSelf.titleView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
            }];
        }
    }];
}

#pragma mark - <JPPhotoCollectionViewDelegate>

- (BOOL)pcVC:(JPPhotoCollectionViewController *)pcVC photoDidSelected:(JPPhotoViewModel *)photoVM {
    return NO;
}

#pragma mark - WMPageControllerDataSource, WMPageControllerDelegate

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleView.titleVMs.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    JPAlbumViewModel *albumVM = (JPAlbumViewModel *)self.titleView.titleVMs[index];
    JPPhotoCollectionViewController *pcVC = [JPPhotoCollectionViewController pcVCWithAlbumVM:albumVM sideMargin:8 cellSpace:2 maxWHSclae:(16.0 / 9.0) maxCol:4 pcVCDelegate:self];
    self.photoCollectionVCs[@(index)] = pcVC;
    return pcVC;
}

- (CGRect)pageController:(WMPageController *)pageController viewControllerFrameAtIndex:(NSInteger)index {
    return [self.pageContentViewFrames[@(index)] CGRectValue];
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController index:(NSInteger)index {
    if (self.titleView.selectedIndexPath) {
        if (self.titleView.selectedIndexPath.item == index) {
            [self.titleView resetSelectedLine];
        } else {
            self.titleView.selectedIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
        }
    }
    [self pcVC:(JPPhotoCollectionViewController *)viewController requestPhotosWithIndex:index];
    
    _isDragging = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JPPhotoPageViewScrollDidEnd" object:nil];
}

- (void)pageController:(WMPageController *)pageController lazyLoadViewController:(__kindof UIViewController *)viewController index:(NSInteger)index {
    [self pcVC:(JPPhotoCollectionViewController *)viewController requestPhotosWithIndex:index];
}

- (void)pageController:(WMPageController *)pageController scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isDragging = YES;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollViewWidth = pageController.scrollView.bounds.size.width;
    
    NSInteger sourceIndex = (NSInteger)((offsetX + scrollViewWidth * 0.5) / scrollViewWidth);
    _startOffsetX = scrollViewWidth * (CGFloat)sourceIndex;

    JPPhotoCollectionViewController *sourceVC = self.photoCollectionVCs[@(sourceIndex)];
    if (sourceVC) [sourceVC willBeginScorllHandle];

    JPPhotoCollectionViewController *leftVC = self.photoCollectionVCs[@(sourceIndex - 1)];
    if (leftVC) [leftVC willBeginScorllHandle];
    
    JPPhotoCollectionViewController *rightVC = self.photoCollectionVCs[@(sourceIndex + 1)];
    if (rightVC) [rightVC willBeginScorllHandle];
}

- (void)pageController:(WMPageController *)pageController scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_isDragging) return;
    
    NSInteger totalCount = self.titleView.titleVMs.count;
    if (totalCount <= 1) return;
    
    CGFloat viewWidth = scrollView.bounds.size.width;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX < 0) {
        offsetX = 0;
    } else if (offsetX > (scrollView.contentSize.width - viewWidth)) {
        offsetX = (scrollView.contentSize.width - viewWidth);
    }
    
    if (offsetX == _startOffsetX) return;
    
    NSInteger sourceIndex = 0;
    NSInteger targetIndex = 0;
    CGFloat progress = 0;
    
    // 滑动位置与初始位置的距离
    CGFloat offsetDistance = fabs(offsetX - _startOffsetX);
    
    if (offsetX > _startOffsetX) {
        // 左滑动
        sourceIndex = (NSInteger)(offsetX / viewWidth);
        targetIndex = sourceIndex + 1;
        progress = offsetDistance / viewWidth;
        
        // 这里要大于等于1
        // 例如 如果 startOffsetX = 0
        // 若 0 < offsetX < 375，0 < progress < 1，本来 sourceIndex = 0，targetIndex = 1
        // 但 375 <= offsetX，progress >= 1，导致 sourceIndex = 1，targetIndex = 2
        if (progress >= 1) {
//            NSLog(@"向左改变");
            if (targetIndex == totalCount) {
                progress = 1;
                targetIndex -= 1;
                sourceIndex -= 1;
            } else {
                progress = 0;
            }
        }
        
        JPPhotoCollectionViewController *sourceVC = self.photoCollectionVCs[@(sourceIndex)];
        if (sourceVC) sourceVC.hideScale = progress;
        
        JPPhotoCollectionViewController *targetVC = self.photoCollectionVCs[@(targetIndex)];
        if (targetVC) targetVC.showScale = progress;
        
    } else {
        // 右滑动
        targetIndex = (NSInteger)(offsetX / viewWidth);
        sourceIndex = targetIndex + 1;
        progress = offsetDistance / viewWidth;
        
        // 这里只能大于1
        // 例如 如果 startOffsetX = 750
        // 若 375 <= offsetX < 750，0 < progress <= 1，本来 targetIndex = 1，sourceIndex = 2
        // 但 375 > offsetX，progress > 1，导致 targetIndex = 0，sourceIndex = 1
        if (progress > 1) {
//            NSLog(@"向右改变");
            if (sourceIndex == totalCount) {
                progress = 1;
                targetIndex -= 1;
                sourceIndex -= 1;
            } else {
                progress = 0;
            }
        }
        
        JPPhotoCollectionViewController *sourceVC = self.photoCollectionVCs[@(sourceIndex)];
        if (sourceVC) sourceVC.showScale = 1 - progress;
        
        JPPhotoCollectionViewController *targetVC = self.photoCollectionVCs[@(targetIndex)];
        if (targetVC) targetVC.hideScale = 1 - progress;
    }
    
    if (offsetDistance >= viewWidth) {
        NSInteger index = (NSInteger)((offsetX + viewWidth * 0.5) / viewWidth);
        _startOffsetX = viewWidth * (CGFloat)index;
    }
    
    [self.titleView updateSelectedLineWithSourceIndex:sourceIndex targetIndex:targetIndex progress:progress];
}

@end
