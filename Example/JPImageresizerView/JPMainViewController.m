//
//  JPMainViewController.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/11/1.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPMainViewController.h"
#import "JPDynamicPage.h"
#import "JPMainCell.h"
#import "UIViewController+JPExtension.h"
#import "UIImage+JPExtension.h"



@interface JPCellModel : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGRect imageFrame;
@property (nonatomic, assign) CGPoint imageAnchorPoint;
@property (nonatomic, assign) CGPoint imagePosition;
@property (nonatomic, assign) CGFloat titleHeight;
@end

@implementation JPCellModel

+ (NSArray<JPCellModel *> *)examplesCellModels {
    NSArray *titles = @[@"默认样式", @"深色毛玻璃遮罩", @"浅色毛玻璃遮罩", @"拉伸样式的边框图片", @"平铺样式的边框图片", @"圆切样式", @"蒙版样式"];
    NSMutableArray *imageNames = @[@"Girl1", @"Girl2", @"Girl3", @"Girl4", @"Girl5", @"Girl6", @"Girl7", @"Girl8"].mutableCopy;
    
    NSMutableArray *cellModels = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        NSInteger index = JPRandomNumber(0, imageNames.count - 1);
        NSString *imageName = imageNames[index];
        NSString *imagePath = JPMainBundleResourcePath(imageName, @"jpg");
        
        UIImage *image = [[UIImage imageWithContentsOfFile:imagePath] jp_cgResizeImageWithScale:1];
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat w = JPMainCell.cellMaxSize.width;
        CGFloat h = w * (image.size.height / image.size.width);
        CGPoint anchorPoint;
        CGPoint position = CGPointMake(JPMainCell.cellMaxSize.width * 0.5, JPMainCell.cellMaxSize.height * 0.5);
        if ([imageName isEqualToString:@"Girl1"] ||
            [imageName isEqualToString:@"Girl2"] ||
            [imageName isEqualToString:@"Girl4"] ||
            [imageName isEqualToString:@"Girl8"]) {
            y = JPHalfOfDiff(JPMainCell.cellMaxSize.height, h);
            anchorPoint = CGPointMake(0.5, 0.5);
        } else {
            anchorPoint = CGPointMake(0.5, (JPMainCell.cellMaxSize.height * 0.5) / h);
        }
        
        NSString *title = titles[i];
        CGFloat titleH = [title boundingRectWithSize:CGSizeMake(JPMainCell.titleMaxWidth, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: JPMainCell.titleFont, NSForegroundColorAttributeName: JPMainCell.titleColor} context:nil].size.height;
        
        JPCellModel *cellModel = [JPCellModel new];
        cellModel.imageFrame = CGRectMake(x, y, w, h);
        cellModel.imageAnchorPoint = anchorPoint;
        cellModel.imagePosition = position;
        cellModel.image = image;
        cellModel.title = title;
        cellModel.titleHeight = titleH;
        [cellModels addObject:cellModel];
        
        [imageNames removeObjectAtIndex:index];
    }
    return cellModels.copy;
}

@end

@interface JPMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) JPDynamicPage *dp;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<JPCellModel *> *cellModels;
@end

@implementation JPMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    JPDynamicPage *dp = [JPDynamicPage dynamicPage];
    [self.view addSubview:dp];
    self.dp = dp;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(JPStatusBarH + JPMainCell.cellMargin, JPMainCell.cellMargin, JPDiffTabBarH + JPMainCell.cellMargin, JPMainCell.cellMargin);
    flowLayout.minimumLineSpacing = JPMainCell.cellMargin;
    flowLayout.minimumInteritemSpacing = JPMainCell.cellMargin;
    flowLayout.itemSize = JPMainCell.cellMaxSize;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:JPPortraitScreenBounds collectionViewLayout:flowLayout];
    [self jp_contentInsetAdjustmentNever:collectionView];
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.alwaysBounceVertical = YES;
    collectionView.delaysContentTouches = NO;
    [collectionView registerClass:JPMainCell.class forCellWithReuseIdentifier:@"JPMainCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.dp startAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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


#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JPMainCell" forIndexPath:indexPath];
    JPCellModel *cellModel = self.cellModels[indexPath.item];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    cell.imageView.frame = cellModel.imageFrame;
    cell.imageView.image = cellModel.image;
    cell.imageView.layer.anchorPoint = cellModel.imageAnchorPoint;
    cell.imageView.layer.position = cellModel.imagePosition;
    cell.titleLabel.text = cellModel.title;
    cell.titleLabel.jp_height = cellModel.titleHeight;
    [CATransaction commit];
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    JPCellModel *cellVM = self.cellVMs[indexPath.item];
//    return cellVM.jp_itemFrame.size;
//}


@end
