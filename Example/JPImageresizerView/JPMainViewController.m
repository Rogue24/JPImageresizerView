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
#import "JPConfigureModel.h"
#import "JPImageresizerViewController.h"

@interface JPCellModel : NSObject
@property (nonatomic, strong) JPConfigureModel *model;
@property (nonatomic, assign) BOOL isTopImage;
@property (nonatomic, assign) CGRect imageFrame;
@property (nonatomic, assign) CGPoint imageAnchorPoint;
@property (nonatomic, assign) CGPoint imagePosition;
@property (nonatomic, assign) CGRect titleFrame;
@end

@implementation JPCellModel

static CGSize cellSize_;
+ (void)setupCellSize:(UIEdgeInsets)screenInsets isVer:(BOOL)isVer {
    NSInteger colCount = isVer ? 1 : 2;
    CGFloat w = ((JPScreenWidth - screenInsets.left - screenInsets.right) - (colCount - 1) * JPMargin) / (CGFloat)colCount;
    cellSize_ = CGSizeMake(w, w * JPWideVideoHWScale);
}
+ (CGSize)cellSize {
    return cellSize_;
}

- (void)updateLayout:(BOOL)isVer {
    CGFloat x = -JPMargin;
    CGFloat y = -JPMargin;
    CGFloat w = cellSize_.width + 2 * JPMargin;
    CGFloat h = w * (self.model.configure.image.size.height / self.model.configure.image.size.width);
    if (self.isTopImage) {
        self.imageAnchorPoint = CGPointMake(0.5, (JPMargin + cellSize_.height * 0.5) / h);
    } else {
        y = JPHalfOfDiff(cellSize_.height, h);
        self.imageAnchorPoint = CGPointMake(0.5, 0.5);
    }
    self.imagePosition = CGPointMake(cellSize_.width * 0.5, cellSize_.height * 0.5);
    self.imageFrame = CGRectMake(x, y, w, h);
    
    CGFloat titleMaxWidth = cellSize_.width - 2 * JP10Margin;
    CGFloat titleH = [self.model.title boundingRectWithSize:CGSizeMake(titleMaxWidth, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: JPMainCell.titleFont, NSForegroundColorAttributeName: JPMainCell.titleColor} context:nil].size.height;
    self.titleFrame = CGRectMake(JP10Margin, cellSize_.height - JP10Margin - titleH, titleMaxWidth, titleH);
}

- (void)setupCellUI:(JPMainCell *)cell {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    cell.imageView.image = self.model.configure.image;
    cell.imageView.frame = self.imageFrame;
    cell.imageView.layer.anchorPoint = self.imageAnchorPoint;
    cell.imageView.layer.position = self.imagePosition;
    cell.titleLabel.text = self.model.title;
    cell.titleLabel.frame = self.titleFrame;
    [CATransaction commit];
}

+ (NSArray<JPCellModel *> *)examplesCellModels {
    NSArray *configureModels = JPConfigureModel.examplesModels;
    NSMutableArray *imageNames = @[@"Girl1", @"Girl2", @"Girl3", @"Girl4", @"Girl5", @"Girl6", @"Girl7", @"Girl8"].mutableCopy;
    
    BOOL isVer = JPScreenWidth < JPScreenHeight;
    NSMutableArray *cellModels = [NSMutableArray array];
    for (NSInteger i = 0; i < configureModels.count; i++) {
        NSInteger index = JPRandomNumber(0, imageNames.count - 1);
        NSString *imageName = imageNames[index];
        NSString *imagePath = JPMainBundleResourcePath(imageName, @"jpg");
        
        UIImage *image = [[UIImage imageWithContentsOfFile:imagePath] jp_cgResizeImageWithScale:1];
        BOOL isTopImage = YES;
        if ([imageName isEqualToString:@"Girl1"] ||
            [imageName isEqualToString:@"Girl2"] ||
            [imageName isEqualToString:@"Girl4"] ||
            [imageName isEqualToString:@"Girl8"]) {
            isTopImage = NO;
        }
        
        JPConfigureModel *model = configureModels[i];
        model.configure.image = image;
        
        JPCellModel *cellModel = [JPCellModel new];
        cellModel.model = model;
        cellModel.isTopImage = isTopImage;
        [cellModel updateLayout:isVer];
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
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = screenInsets;
    flowLayout.minimumLineSpacing = JPMargin;
    flowLayout.minimumInteritemSpacing = JPMargin;
    flowLayout.itemSize = JPCellModel.cellSize;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:JPScreenBounds collectionViewLayout:flowLayout];
    [self jp_contentInsetAdjustmentNever:collectionView];
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.alwaysBounceVertical = YES;
    collectionView.delaysContentTouches = NO;
    [collectionView registerClass:JPMainCell.class forCellWithReuseIdentifier:@"JPMainCell"];
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
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.sectionInset = screenInsets;
    flowLayout.itemSize = JPCellModel.cellSize;
    
    if (duration) {
        [UIView animateWithDuration:duration delay:0 options:kNilOptions animations:^{
            [self.dp updateFrame:JPScreenBounds];
            self.collectionView.frame = JPScreenBounds;
            [self.collectionView setCollectionViewLayout:flowLayout animated:NO];
        } completion:nil];
    } else {
        [self.dp updateFrame:JPScreenBounds];
        self.collectionView.frame = JPScreenBounds;
        [self.collectionView setCollectionViewLayout:flowLayout animated:NO];
    }
    
    self.collectionView.showsVerticalScrollIndicator = isVer;
}

@end
