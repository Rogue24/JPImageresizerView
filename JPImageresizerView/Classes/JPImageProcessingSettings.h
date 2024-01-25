//
//  JPImageProcessingSettings.h
//  JPImageresizerView
//
//  Created by aa on 2024/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPImageProcessingSettings : NSObject

/** 背景色 */
@property (nonatomic, strong) UIColor *_Nullable backgroundColor;
/** 圆角 */
@property (nonatomic, assign) CGFloat cornerRadius;

/** 边框大小 */
@property (nonatomic, assign) CGFloat borderWidth;
/** 边框颜色 */
@property (nonatomic, strong) UIColor *_Nullable borderColor;

/** 轮廓描边大小 */
@property (nonatomic, assign) CGFloat outlineStrokeWidth;
/** 轮廓描边颜色 */
@property (nonatomic, strong) UIColor *_Nullable outlineStrokeColor;

/** 内容边距 */
@property (nonatomic, assign) UIEdgeInsets padding;

/** 是否只绘制图像轮廓 */
@property (nonatomic, assign) BOOL isOnlyDrawOutline;

/** 是否需要图像处理 */
@property (readonly) BOOL isNeedProcessing;

@end

NS_ASSUME_NONNULL_END
