//
//  JPLiquidLayoutProtocol.h
//  JPLiquidLayout_Example
//
//  Created by 周健平 on 2018/8/13.
//  Copyright © 2018 Rogue24. All rights reserved.
//

/**
 * 流式布局协议 --- 用于记录item的位置信息
 */

#import <UIKit/UIKit.h>

@protocol JPLiquidLayoutProtocol <NSObject>

/** 图片的宽高比（宽除以高） */
@property (nonatomic, assign) CGFloat jp_whScale;

/** 所在列下标 */
@property (nonatomic, assign) NSInteger jp_colIndex;

/** 所在行下标 */
@property (nonatomic, assign) NSInteger jp_rowIndex;

/** item的Frame */
@property (nonatomic, assign) CGRect jp_itemFrame;

/** 是否已经设置了位置信息，用于避免重复计算 */
@property (nonatomic, assign) BOOL jp_isSetedDone;

@end
