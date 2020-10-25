//
//  JPAttachmentFlowLayout.m
//  JPTestCollectionView
//
//  Created by guanning on 2017/6/19.
//  Copyright © 2017年 Infinitee. All rights reserved.
//
//  参考：https://my.oschina.net/u/1378445/blog/335014

#import "JPAttachmentFlowLayout.h"

@interface JPAttachmentFlowLayout ()
@property (nonatomic, assign) CGFloat springDamping;
@property (nonatomic, assign) CGFloat springFrequency;
@property (nonatomic, assign) CGFloat resistanceFactor;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, assign) CGFloat scrollDelta;
@end

@implementation JPAttachmentFlowLayout

#pragma mark - setter

- (void)setSpringinessEnabled:(BOOL)springinessEnabled {
    if (_springinessEnabled == springinessEnabled) {
        return;
    }
    
    _springinessEnabled = springinessEnabled;
    
    [self invalidateLayoutWithContext:[[UICollectionViewFlowLayoutInvalidationContext alloc] init]];
    
    [_animator removeAllBehaviors];
    
}

#pragma mark - getter

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _animator;
}

#pragma mark - 重写父类方法

- (instancetype)init {
    if (self = [super init]) {
        _springDamping = 1;
        _springFrequency = 1;
        _resistanceFactor = JPScaleValue(2600);
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    if (!self.springinessEnabled) return;
    
    CGSize contentSize = [self collectionViewContentSize];

    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];

    if (self.animator.behaviors.count == 0 && attributesInRect.count > 0) {
        for (UICollectionViewLayoutAttributes *item in attributesInRect) {
            [self.animator addBehavior:[self attachmentBehaviorWithItem:item]];
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:rect];
    
    if (!self.springinessEnabled) return attributesInRect;
    
    NSMutableArray *attributesInRectCopy = [attributesInRect mutableCopy];
    
    NSArray *dynamicAttributes = [self.animator itemsInRect:rect];
    
    if (dynamicAttributes.count) {
        for (UICollectionViewLayoutAttributes *eachItem in attributesInRect) {
            for (UICollectionViewLayoutAttributes *eachDynamicItem in dynamicAttributes) {
                if ([eachItem.indexPath isEqual:eachDynamicItem.indexPath] &&
                    eachItem.representedElementCategory == eachDynamicItem.representedElementCategory) {
                    
                    [attributesInRectCopy removeObject:eachItem];
                    [attributesInRectCopy addObject:eachDynamicItem];
                    continue;
                }
            }
        }
    }
    
    return attributesInRectCopy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (!self.springinessEnabled) return [super layoutAttributesForItemAtIndexPath:indexPath];

    UICollectionViewLayoutAttributes *aItem = [self.animator layoutAttributesForCellAtIndexPath:indexPath];

    if (!aItem) {

        UICollectionViewLayoutAttributes *item = [super layoutAttributesForItemAtIndexPath:indexPath];
        if (item.representedElementCategory != UICollectionElementCategoryCell) return item;

        UIAttachmentBehavior *spring = [self attachmentBehaviorWithItem:item];
        [self.animator addBehavior:spring];

        aItem = (UICollectionViewLayoutAttributes *)[spring.items firstObject];
        CGPoint center = aItem.center;
        center.y += 30;
        aItem.center = center;

    }

    return aItem;

}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    if (self.springinessEnabled) {
        CGFloat scrollDelta = newBounds.origin.y - self.collectionView.bounds.origin.y;
        self.scrollDelta = scrollDelta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *spring, NSUInteger idx, BOOL *stop) {
            [self adjustSpringBehavior:spring forTouchLocation:touchLocation];
            [self.animator updateItemUsingCurrentState:spring.items.firstObject];
        }];
    }
    
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 私有方法

- (UIAttachmentBehavior *)attachmentBehaviorWithItem:(UICollectionViewLayoutAttributes *)item {
    if (CGSizeEqualToSize(item.frame.size, CGSizeZero)) {
        return nil;
    }
    
    if (item.representedElementCategory != UICollectionElementCategoryCell) return nil;
    
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    spring.length = 1;
    spring.damping = self.springDamping;
    spring.frequency = self.springFrequency;
    
    return spring;
}

- (void)adjustSpringBehavior:(UIAttachmentBehavior *)spring forTouchLocation:(CGPoint)touchLocation {
    
    if (CGPointEqualToPoint(CGPointZero, touchLocation) || self.collectionView.panGestureRecognizer.state == UIGestureRecognizerStatePossible) return;
    
    UICollectionViewLayoutAttributes *item = (UICollectionViewLayoutAttributes *)[spring.items firstObject];
    
    CGFloat distanceFromTouch = fabs(touchLocation.y - spring.anchorPoint.y);
    
    CGFloat scrollResistance = distanceFromTouch / self.resistanceFactor;
    
    CGFloat centerY = (self.scrollDelta > 0) ? MIN(self.scrollDelta, self.scrollDelta * scrollResistance) : MAX(self.scrollDelta, self.scrollDelta * scrollResistance);
    
    CGPoint center = item.center;
    center.y += centerY;
    item.center = center;
    
}

@end
