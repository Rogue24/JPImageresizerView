//
//  JPLiquidLayoutTool.h
//  JPLiquidLayout_Example
//
//  Created by 周健平 on 2018/8/13.
//  Copyright © 2018 Rogue24. All rights reserved.
//

/**
 * 流式布局的计算工具类
 */

#import <Foundation/Foundation.h>
#import "JPLiquidLayout.h"

@interface JPLiquidLayoutTool : NSObject

/*!
 @method
 @brief 计算所有item的布局
 @param items --- 所有遵守布局协议的元素
 @param targetRow --- 从哪一行开始进行计算
 @param flowLayout --- UICollectionViewFlowLayout
 @param maxWidth --- 单个item的最大宽度
 @param baseHeight --- 每行的基准高度，在这个高度的基础上浮动适配
 @param itemMaxWhScale --- 图片的最大宽高比，超过则单行显示
 @param maxCol --- 每行最大列数
 @discussion 自行配置参数
 */
+ (CGFloat)calculateItemFrames:(NSArray<NSObject<JPLiquidLayoutProtocol> *> *)items
                     targetRow:(NSInteger)targetRow
                    flowLayout:(UICollectionViewFlowLayout *)flowLayout
                      maxWidth:(CGFloat)maxWidth
                    baseHeight:(CGFloat)baseHeight
                itemMaxWhScale:(CGFloat)itemMaxWhScale
                        maxCol:(NSInteger)maxCol;

/*!
 @method
 @brief 更新所有item的布局
 @param items --- 所有遵守布局协议的元素
 @param targetIndex --- 从哪一个开始更新
 @param flowLayout --- UICollectionViewFlowLayout
 @param maxWidth --- 单个item的最大宽度
 @param baseHeight --- 每行的基准高度，在这个高度的基础上浮动适配
 @param itemMaxWhScale --- 图片的最大宽高比，超过则单行显示
 @param maxCol --- 每行最大列数
 @discussion 自行配置参数
 */
+ (CGFloat)updateItemFrames:(NSArray<NSObject<JPLiquidLayoutProtocol> *> *)items
                targetIndex:(NSInteger)targetIndex
                 flowLayout:(UICollectionViewFlowLayout *)flowLayout
                   maxWidth:(CGFloat)maxWidth
                 baseHeight:(CGFloat)baseHeight
             itemMaxWhScale:(CGFloat)itemMaxWhScale
                     maxCol:(NSInteger)maxCol;

/*!
 @method
 @brief 计算所有item的布局
 @param items --- 所有遵守布局协议的元素
 @param targetRow --- 从哪一行开始进行计算
 @param liquidLayout --- JPLiquidLayout，里面已经包含了maxWidth、baseHeight、itemMaxWhScale、maxCol
 @discussion 使用liquidLayout配置
 */
+ (CGFloat)calculateItemFrames:(NSArray<NSObject<JPLiquidLayoutProtocol> *> *)items
                    targetRow:(NSInteger)targetRow
                  liquidLayout:(JPLiquidLayout *)liquidLayout;


/*!
 @method
 @brief 更新所有item的布局
 @param items --- 所有遵守布局协议的元素
 @param targetIndex --- 从哪一个开始更新
 @param liquidLayout --- JPLiquidLayout，里面已经包含了maxWidth、baseHeight、itemMaxWhScale、maxCol
 @discussion 使用liquidLayout配置
 */
+ (CGFloat)updateItemFrames:(NSArray<NSObject<JPLiquidLayoutProtocol> *> *)items
                targetIndex:(NSInteger)targetIndex
               liquidLayout:(JPLiquidLayout *)liquidLayout;

@end
