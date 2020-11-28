//
//  JPMainViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/11/1.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPMainViewController.h"
#import "JPDynamicPage.h"
#import "JPMainViewModel.h"
#import "UIViewController+JPExtension.h"

#import "JPImageresizerViewController.h"

@interface JPMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) JPDynamicPage *dp;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<JPCellModel *> *cellModels;

@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientation;
@end

@implementation JPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isVer = JPScreenWidth < JPScreenHeight;
    self.statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIEdgeInsets screenInsets = [JPSolveTool screenInsets:self.statusBarOrientation];
    
    [JPCellModel setupCellSize:screenInsets isVer:isVer];
    
    JPDynamicPage *dp = [JPDynamicPage dynamicPage];
    [self.view addSubview:dp];
    self.dp = dp;
    
    CGFloat wh = JPPortraitScreenHeight;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = JPSpace;
    flowLayout.minimumInteritemSpacing = JPSpace;
    flowLayout.sectionInset = UIEdgeInsetsMake(screenInsets.top, screenInsets.left, screenInsets.bottom + (wh - JPScreenHeight), screenInsets.right + (wh - JPScreenWidth));
    flowLayout.itemSize = JPCellModel.cellSize;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, wh, wh) collectionViewLayout:flowLayout];
    [self jp_contentInsetAdjustmentNever:collectionView];
    collectionView.autoresizingMask = UIViewAutoresizingNone;
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.alwaysBounceVertical = YES;
    collectionView.delaysContentTouches = NO;
    [collectionView registerClass:JPMainCell.class forCellWithReuseIdentifier:@"JPMainCell"];
    [collectionView registerClass:JPMainHeader.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JPMainHeader"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsVerticalScrollIndicator = isVer;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    JPObserveNotification(self, @selector(didChangeStatusBarOrientation), UIApplicationDidChangeStatusBarOrientationNotification, nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.dp startAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.cellModels.count) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<JPCellModel *> *cellModels = [JPCellModel examplesCellModels];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cellModels = cellModels;
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        });
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.dp stopAnimation];
}

- (void)dealloc {
    JPRemoveNotification(self);
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JPMainCell" forIndexPath:indexPath];
    cell.bounceView.tag = indexPath.item;
    JPCellModel *cellModel = self.cellModels[indexPath.item];
    [cellModel setupCellUI:cell];
    
    if (!cell.bounceView.viewTouchUpInside) {
        @jp_weakify(self);
        cell.bounceView.viewTouchUpInside = ^(JPBounceView *kBounceView) {
            @jp_strongify(self);
            if (!self) return;
            JPCellModel *cm = self.cellModels[kBounceView.tag];
            
            JPImageresizerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPImageresizerViewController"];
            vc.statusBarStyle = cm.model.statusBarStyle;
            vc.configure = cm.model.configure;
            
            CATransition *cubeAnim = [CATransition animation];
            cubeAnim.duration = 0.45;
            cubeAnim.type = @"cube";
            cubeAnim.subtype = kCATransitionFromRight;
            cubeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.navigationController.view.layer addAnimation:cubeAnim forKey:@"cube"];
            
            [self.navigationController pushViewController:vc animated:NO];
        };
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JPMainHeader" forIndexPath:indexPath];
    }
    return nil;
}

#pragma mark - 监听屏幕旋转

- (void)didChangeStatusBarOrientation {
    [self setStatusBarOrientation:[UIApplication sharedApplication].statusBarOrientation
                         duration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration];
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)statusBarOrientation {
    [self setStatusBarOrientation:statusBarOrientation duration:0];
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)statusBarOrientation duration:(NSTimeInterval)duration {
    if (_statusBarOrientation == statusBarOrientation) return;
    _statusBarOrientation = statusBarOrientation;
    
    BOOL isVer = JPScreenWidth < JPScreenHeight;
    UIEdgeInsets screenInsets = [JPSolveTool screenInsets:statusBarOrientation];
    
    [JPCellModel setupCellSize:screenInsets isVer:isVer];
    
    for (JPCellModel *cellModel in self.cellModels) {
        [cellModel updateLayout:isVer];
    }
    
    self.collectionView.showsVerticalScrollIndicator = isVer;
    
    CGFloat wh = self.collectionView.jp_width;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(screenInsets.top, screenInsets.left, screenInsets.bottom + (wh - JPScreenHeight), screenInsets.right + (wh - JPScreenWidth));
    CGSize itemSize = JPCellModel.cellSize;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (duration) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.dp updateFrame:JPScreenBounds];
            flowLayout.sectionInset = sectionInset;
            flowLayout.itemSize = itemSize;
        } completion:nil];
    } else {
        [self.dp updateFrame:JPScreenBounds];
        flowLayout.sectionInset = sectionInset;
        flowLayout.itemSize = itemSize;
    }
}

@end
