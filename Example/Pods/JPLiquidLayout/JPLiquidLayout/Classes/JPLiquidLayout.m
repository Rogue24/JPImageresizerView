//
//  JPLiquidLayout.m
//  JPLiquidLayout_Example
//
//  Created by 周健平 on 2018/8/13.
//  Copyright © 2018 Rogue24. All rights reserved.
//

#import "JPLiquidLayout.h"
#import "JPLiquidLayoutTool.h"

@interface JPLiquidLayout ()
@property (nonatomic, strong) NSMutableArray<JPLiquidLayoutAttributes *> *attributes;
@property (nonatomic, strong) NSMutableArray<JPLiquidLayoutAttributes *> *oldAttributes;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, strong) NSIndexPath *insertIndexPath;
@property (nonatomic, strong) NSIndexPath *deleteIndexPath;
@property (nonatomic, strong) NSIndexPath *reloadIndexPath;
@end

@implementation JPLiquidLayout

- (instancetype)init {
    if (self = [super init]) {
        self.itemMaxWhScale = 1;
        self.maxCol = 1;
        self.singleAnimated = YES;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.oldAttributes = [self.attributes mutableCopy];
    self.attributes = [NSMutableArray array];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        JPLiquidLayoutAttributes *att = [JPLiquidLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        att.jp_whScale = self.itemWhScale ? self.itemWhScale(indexPath) : 1;
        [self.attributes addObject:att];
    }
    
    self.maxHeight = [JPLiquidLayoutTool calculateItemFrames:self.attributes
                                                   targetRow:0
                                                liquidLayout:self];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributes;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, self.maxHeight);
}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
    if (!self.singleAnimated || updateItems.count > 1) return;
    UICollectionViewUpdateItem *updateItem = updateItems.firstObject;
    switch (updateItem.updateAction) {
        case UICollectionUpdateActionInsert:
            self.insertIndexPath = updateItem.indexPathAfterUpdate;
            break;
        case UICollectionUpdateActionDelete:
            self.deleteIndexPath = updateItem.indexPathBeforeUpdate;
            break;
        case UICollectionUpdateActionReload:
            self.reloadIndexPath = updateItem.indexPathAfterUpdate;
            break;
        default:
            break;
    }
}

- (void)finalizeCollectionViewUpdates {
    self.oldAttributes = nil;
    self.insertIndexPath = nil;
    self.deleteIndexPath = nil;
    self.reloadIndexPath = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    
    UICollectionViewLayoutAttributes *attributes = [[super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath] copy];
    
    if (self.insertIndexPath) {
        if (itemIndexPath.item == self.insertIndexPath.item) {
            [self setupAttributesItemFrameWithAttributes:attributes index:itemIndexPath.item];
            attributes.alpha = 0;
            attributes.transform = CGAffineTransformMakeScale(0.3, 0.3);
        } else {
            NSInteger index = itemIndexPath.item;
            if (index >= self.insertIndexPath.item) {
                index -= 1;
            }
            [self setupOldAttributesItemFrameWithAttributes:attributes index:index];
        }
        return attributes;
    }

    if (self.deleteIndexPath) {
        NSInteger index = itemIndexPath.item;
        if (index >= self.deleteIndexPath.item) {
            index += 1;
        }
        [self setupOldAttributesItemFrameWithAttributes:attributes index:index];
        return attributes;
    }

    if (self.reloadIndexPath) {
        [self setupOldAttributesItemFrameWithAttributes:attributes index:itemIndexPath.item];
        if (itemIndexPath.item == self.reloadIndexPath.item) {
            attributes.alpha = 0.5;
        }
        return attributes;
    }

    [self setupAttributesItemFrameWithAttributes:attributes index:itemIndexPath.item];
    attributes.alpha = 0;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    
    UICollectionViewLayoutAttributes *attributes = [[super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath] copy];
    
    if (self.insertIndexPath) {
        NSInteger index = itemIndexPath.item;
        if (index >= self.insertIndexPath.item) {
            index += 1;
        }
        [self setupAttributesItemFrameWithAttributes:attributes index:index];
        return attributes;
    }
    
    if (self.deleteIndexPath) {
        if (itemIndexPath.item == self.deleteIndexPath.item) {
            [self setupOldAttributesItemFrameWithAttributes:attributes index:itemIndexPath.item];
            attributes.transform = CGAffineTransformMakeScale(0.3, 0.3);
            attributes.alpha = 0;
        } else {
            NSInteger index = itemIndexPath.item;
            if (index > self.deleteIndexPath.item) {
                index -= 1;
            }
            [self setupAttributesItemFrameWithAttributes:attributes index:index];
        }
        return attributes;
    }
    
    if (self.reloadIndexPath) {
        [self setupAttributesItemFrameWithAttributes:attributes index:itemIndexPath.item];
        if (itemIndexPath.item == self.reloadIndexPath.item) {
            attributes.alpha = 0;
        }
        return attributes;
    }
    
    [self setupAttributesItemFrameWithAttributes:attributes index:itemIndexPath.item];
    return attributes;
}

- (void)setupOldAttributesItemFrameWithAttributes:(UICollectionViewLayoutAttributes *)attributes index:(NSInteger)index {
    NSInteger count = self.oldAttributes.count;
    if (count && index < count && index >= 0) {
        attributes.frame = [self.oldAttributes[index] jp_itemFrame];
    }
}

- (void)setupAttributesItemFrameWithAttributes:(UICollectionViewLayoutAttributes *)attributes index:(NSInteger)index {
    NSInteger count = self.attributes.count;
    if (count && index < count && index >= 0) {
        attributes.frame = [self.attributes[index] jp_itemFrame];
    }
}

@end

@implementation JPLiquidLayoutAttributes

@synthesize jp_whScale = _jp_whScale;
@synthesize jp_itemFrame = _jp_itemFrame;
@synthesize jp_rowIndex = _jp_rowIndex;
@synthesize jp_colIndex = _jp_colIndex;
@synthesize jp_isSetedDone = _jp_isSetedDone;

- (void)setJp_itemFrame:(CGRect)jp_itemFrame {
    self.frame = jp_itemFrame;
}

- (CGRect)jp_itemFrame {
    return self.frame;
}

@end
