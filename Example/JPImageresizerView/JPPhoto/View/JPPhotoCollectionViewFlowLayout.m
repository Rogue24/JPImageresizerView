//
//  JPPhotoCollectionViewFlowLayout.m
//  Infinitee2.0
//
//  Created by 周健平 on 2019/6/13.
//  Copyright © 2019 Infinitee. All rights reserved.
//

#import "JPPhotoCollectionViewFlowLayout.h"

@implementation JPPhotoCollectionViewFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    if (self.getLayoutAttributeFrame) {
        for (UICollectionViewLayoutAttributes *layoutAttribute in layoutAttributes) {
            layoutAttribute.frame = self.getLayoutAttributeFrame(layoutAttribute.indexPath);
        }
    }
    return layoutAttributes;
}

@end
