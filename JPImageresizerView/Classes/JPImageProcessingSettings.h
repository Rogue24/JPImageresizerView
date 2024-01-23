//
//  JPImageProcessingSettings.h
//  JPImageresizerView
//
//  Created by aa on 2024/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPImageProcessingSettings : NSObject
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *_Nullable backgroundColor;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *_Nullable borderColor;

@property (nonatomic, assign) CGFloat outlineStrokeWidth;
@property (nonatomic, strong) UIColor *_Nullable outlineStrokeColor;

@property (nonatomic, assign) UIEdgeInsets padding;

@property (nonatomic, assign) BOOL isOnlyDrawOutline;

@property (readonly) BOOL isNeedProcessing;
@end

NS_ASSUME_NONNULL_END
