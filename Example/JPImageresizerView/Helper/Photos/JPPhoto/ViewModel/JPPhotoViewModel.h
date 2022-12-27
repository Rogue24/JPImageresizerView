//
//  JPPhotoViewModel.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JPLiquidLayoutTool.h>
#import "JPPhotoTool.h"

@interface JPPhotoViewModel : NSObject <JPLiquidLayoutProtocol>

- (instancetype)initWithAsset:(PHAsset *)asset;

@property (nonatomic, assign) CGFloat jp_whScale;
@property (nonatomic, assign) NSInteger jp_colIndex;
@property (nonatomic, assign) NSInteger jp_rowIndex;
@property (nonatomic, assign) CGRect jp_itemFrame;
@property (nonatomic, assign) BOOL jp_isSetedDone;

/** asset对象 */
@property (nonatomic, strong) PHAsset *asset;

/** 缩略图的尺寸 */
@property (nonatomic, assign, readonly) CGSize abbPhotoSize;

/** 大图的尺寸 */
@property (nonatomic, assign, readonly) CGSize bigPhotoSize;

/** 原图的尺寸 */
@property (nonatomic, assign, readonly) CGSize originPhotoSize;

/** 是否只获取最终照片 */
@property (nonatomic, assign) BOOL isJustGetFinalPhoto;

/** 是否被选中 */
@property (nonatomic, assign) BOOL isSelected;

@end
