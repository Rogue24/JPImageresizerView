//
//  JPImageresizerAppearance.h
//  JPImageresizerView
//
//  Created by aa on 2025/10/11.
//
//  外观配置
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPImageresizerAppearance : NSObject
- (instancetype)initWithStrokeColor:(UIColor *_Nullable)strokeColor
                           bgEffect:(UIVisualEffect *_Nullable)bgEffect
                            bgColor:(UIColor *_Nullable)bgColor
                          maskAlpha:(CGFloat)maskAlpha;
@property (nonatomic, strong) UIColor *_Nullable strokeColor;
@property (nonatomic, strong) UIVisualEffect *_Nullable bgEffect;
@property (nonatomic, strong) UIColor *_Nullable bgColor;
@property (nonatomic, assign) CGFloat maskAlpha;
@end

NS_ASSUME_NONNULL_END
