//
//  JPImageresizerBlurView.h
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPImageresizerBlurView : UIView
- (instancetype)initWithFrame:(CGRect)frame
                       effect:(UIVisualEffect *_Nullable)effect
                      bgColor:(UIColor *_Nullable)bgColor
                    maskAlpha:(CGFloat)maskAlpha;

- (BOOL)isBlur;
- (UIVisualEffect *_Nullable)effect;
- (UIColor *_Nullable)bgColor;
- (CGFloat)maskAlpha;
- (BOOL)isMaskAlpha;

- (void)setIsBlur:(BOOL)isBlur duration:(NSTimeInterval)duration;
- (void)setEffect:(UIVisualEffect *_Nullable)effect duration:(NSTimeInterval)duration;
- (void)setBgColor:(UIColor *_Nullable)bgColor duration:(NSTimeInterval)duration;
- (void)setMaskAlpha:(CGFloat)maskAlpha duration:(NSTimeInterval)duration;
- (void)setIsMaskAlpha:(BOOL)isMaskAlpha duration:(NSTimeInterval)duration;

- (void)setupIsBlur:(BOOL)isBlur
             effect:(UIVisualEffect *_Nullable)effect
            bgColor:(UIColor *_Nullable)bgColor
          maskAlpha:(CGFloat)maskAlpha
        isMaskAlpha:(BOOL)isMaskAlpha
           duration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
