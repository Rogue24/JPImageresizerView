//
//  JPLiquidLayout.h
//  JPLiquidLayout_Example
//
//  Created by 周健平 on 2018/8/13.
//  Copyright © 2018 Rogue24. All rights reserved.
//

/**
 * 流式布局
 */

#import <UIKit/UIKit.h>
#import "JPLiquidLayoutProtocol.h"

@interface JPLiquidLayout : UICollectionViewFlowLayout

/** 每行最大列数 */
@property (nonatomic, assign) NSInteger maxCol;

/** 单个item的最大宽度 */
@property (nonatomic, assign) CGFloat maxWidth;

/** 每行的基准高度，在这个高度的基础上浮动适配 */
@property (nonatomic, assign) CGFloat baseHeight;

/** 图片的最大宽高比，超过则单行显示 */
@property (nonatomic, assign) CGFloat itemMaxWhScale;

/** 获取图片的宽高比（没有实现该block则使用1:1） */
@property (nonatomic, copy) CGFloat (^itemWhScale)(NSIndexPath *indexPath);

/** 是否带单个item的动画效果（默认为YES，只有单个的insert、delete、reload三种效果） */
@property (nonatomic, assign) BOOL singleAnimated;

@end

@interface JPLiquidLayoutAttributes: UICollectionViewLayoutAttributes <JPLiquidLayoutProtocol>

@end
