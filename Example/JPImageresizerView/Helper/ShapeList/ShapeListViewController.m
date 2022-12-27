//
//  ShapeListViewController.m
//  Infinitee2.0
//
//  Created by guanning on 2017/6/15.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "ShapeListViewController.h"
#import "JPSolveTool.h"
#import "NoDataView.h"
#import "JPAttachmentFlowLayout.h"
#import "ShapeMergeCell.h"
#import "UIViewController+JPExtension.h"

@interface ShapeListViewController ()
@property (nonatomic, copy) void (^getShapeImageBlock)(UIImage *shapeImage);
@property (nonatomic, copy) NSArray<NSString *> *dataSource;
@end

@implementation ShapeListViewController
{
    BOOL _isDidAppear;
    UIFont *_baseFont;
    UIFont *_smallFont;
}

static NSString *const ShapeMergeCellID = @"ShapeMergeCell";
static NSArray<NSString *> *shapes_;

#pragma mark - build

+ (instancetype)shapeListViewController:(void (^)(UIImage *))getShapeImageBlock {
    CGFloat cellMargin = [ShapeMergeCell cellMargin];
    CGFloat cellSpace = [ShapeMergeCell cellSpace];
    CGFloat itemWH = [ShapeMergeCell cellWH];
    
    JPAttachmentFlowLayout *layout = [[JPAttachmentFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(JPPortraitScreenWidth, itemWH);
    CGFloat topInset;
    if (@available(iOS 13.0, *)) {
        topInset = [JPConstant pageSheetPortraitNavBarH];
    } else {
        topInset = JPNavTopMargin;
    }
    layout.sectionInset = UIEdgeInsetsMake(topInset + cellMargin, 0, JPDiffTabBarH + cellMargin, 0);
    layout.minimumLineSpacing = cellSpace;
    layout.minimumInteritemSpacing = 0;
    
    ShapeListViewController *vc = [[self alloc] initWithCollectionViewLayout:layout];
    vc.getShapeImageBlock = getShapeImageBlock;
    return vc;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蒙版素材列表";
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(__back)];
    
    _baseFont = JPShapeFont(55);
    _smallFont = JPShapeFont(30);
    
    [self jp_contentInsetAdjustmentNever:self.collectionView];
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(JPNavTopMargin, 0, JPDiffTabBarH, 0);
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:ShapeMergeCell.class forCellWithReuseIdentifier:ShapeMergeCellID];
    self.collectionView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_isDidAppear) return;
    _isDidAppear = YES;
    if (!shapes_) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            shapes_ = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shapeList" ofType:@"plist"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self __reloadData:shapes_];
            });
        });
    } else {
       [self __reloadData:shapes_];
    }
}

#pragma mark - 私有方法

- (void)__reloadData:(NSArray<NSString *> *)shapes {
    JPAttachmentFlowLayout *layout = (JPAttachmentFlowLayout *)self.collectionView.collectionViewLayout;
    layout.springinessEnabled = YES;
    
    self.dataSource = shapes;
    [self.collectionView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        self.collectionView.alpha = 1;
    }];
}

- (void)__back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger shapeMergeCount = [ShapeMergeCell shapeMergeCount];
    NSInteger count = self.dataSource.count / shapeMergeCount;
    if (self.dataSource.count % shapeMergeCount > 0) {
        count += 1;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ShapeMergeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ShapeMergeCellID forIndexPath:indexPath];
    if (!cell.tapShapeBlock) {
        @jp_weakify(self);
        cell.tapShapeBlock = ^(NSString *shape) {
            [JPProgressHUD show];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CGFloat fontSize = JPPortraitScreenWidth;
                NSDictionary *attDic = @{NSFontAttributeName: [UIFont fontWithName:@"shape" size:fontSize]};
                CGRect rect = [shape boundingRectWithSize:CGSizeMake(9999, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:attDic context:nil];
                UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
                [shape drawInRect:rect withAttributes:attDic];
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    [JPProgressHUD dismiss];
                    @jp_strongify(self);
                    if (!self || !self.getShapeImageBlock) return;
                    [self dismissViewControllerAnimated:YES completion:^{
                        self.getShapeImageBlock(newImage);
                    }];
                });
            });
        };
    }
    NSInteger shapeMergeCount = [ShapeMergeCell shapeMergeCount];
    NSInteger factItem = indexPath.item * shapeMergeCount;
    for (NSInteger i = factItem; i < factItem + shapeMergeCount; i++) {
        NSString *shape = self.dataSource[i];
        NSInteger index = i - factItem;
        UILabel *shapeLabel = cell.shapeLabels[index];
        shapeLabel.font = [shape isEqualToString:@""] ? _smallFont : _baseFont;
        shapeLabel.text = shape;
    }
    return cell;
}

@end
