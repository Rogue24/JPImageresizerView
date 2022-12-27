//
//  ShapeMergeCell.h
//  Infinitee2.0
//
//  Created by guanning on 2017/6/19.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeMergeCell : UICollectionViewCell
+ (NSInteger)shapeMergeCount;
+ (CGFloat)cellMargin;
+ (CGFloat)cellSpace;
+ (CGFloat)cellWH;
@property (nonatomic, copy) NSArray<UILabel *> *shapeLabels;
@property (nonatomic, copy) void (^tapShapeBlock)(NSString *shape);
@end
