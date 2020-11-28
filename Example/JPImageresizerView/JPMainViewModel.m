//
//  JPMainViewModel.m
//  JPImageresizerView_Example
//
//  Created by aa on 2020/11/28.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPMainViewModel.h"
#import "UIImage+JPExtension.h"

@implementation JPCellModel

static CGSize cellSize_;
+ (void)setupCellSize:(UIEdgeInsets)screenInsets isVer:(BOOL)isVer {
    NSInteger colCount = isVer ? 2 : 4;
    CGFloat w = ((JPScreenWidth - screenInsets.left - screenInsets.right) - (colCount - 1) * JPSpace) / (CGFloat)colCount;
    CGFloat h = w * (2.0 / 3.0);
    cellSize_ = CGSizeMake(w, h);
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

@implementation JPHeaderModel

static CGSize headerSize_;
+ (void)setupHeaderSize:(UIEdgeInsets)screenInsets isVer:(BOOL)isVer {
    NSInteger colCount = isVer ? 2 : 4;
    CGFloat w = ((JPScreenWidth - screenInsets.left - screenInsets.right) - (colCount - 1) * JPSpace) / (CGFloat)colCount;
    CGFloat h = w * (2.0 / 3.0);
    headerSize_ = CGSizeMake(w, h);
}
+ (CGSize)headerSize {
    return headerSize_;
}

+ (NSArray<JPHeaderModel *> *)examplesHeaderModels {
    return nil;
}

@end

@implementation JPMainViewModel

@end
