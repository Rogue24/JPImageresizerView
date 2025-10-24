//
//  JPImageresizerBlurView.h
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPImageresizerBlurView : UIView
- (instancetype)initWithFrame:(CGRect)frame
                   appearance:(JPImageresizerAppearance *)appearance
                       isBlur:(BOOL)isBlur
                  isMaskAlpha:(BOOL)isMaskAlpha
                 cornerRadius:(CGFloat)cornerRadius;

@property (nonatomic, strong) JPImageresizerAppearance *appearance;
@property (nonatomic, assign) BOOL isBlur;
@property (nonatomic, assign) BOOL isMaskAlpha;
@property (nonatomic, assign) CGFloat cornerRadius;

- (void)setAppearance:(JPImageresizerAppearance *)appearance duration:(NSTimeInterval)duration;
- (void)setIsBlur:(BOOL)isBlur duration:(NSTimeInterval)duration;
- (void)setIsMaskAlpha:(BOOL)isMaskAlpha duration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
