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
                   blurEffect:(UIBlurEffect *_Nullable)blurEffect
                      bgColor:(UIColor *_Nullable)bgColor
                    maskAlpha:(CGFloat)maskAlpha;

- (BOOL)isBlur;
- (UIBlurEffect *_Nullable)blurEffect;
- (UIColor *_Nullable)bgColor;
- (CGFloat)maskAlpha;
- (BOOL)isMaskAlpha;

- (void)setIsBlur:(BOOL)isBlur duration:(NSTimeInterval)duration;
- (void)setBlurEffect:(UIBlurEffect *_Nullable)blurEffect duration:(NSTimeInterval)duration;
- (void)setBgColor:(UIColor *_Nullable)bgColor duration:(NSTimeInterval)duration;
- (void)setMaskAlpha:(BOOL)maskAlpha duration:(NSTimeInterval)duration;
- (void)setIsMaskAlpha:(BOOL)isMaskAlpha duration:(NSTimeInterval)duration;

- (void)setupIsBlur:(BOOL)isBlur
         blurEffect:(UIBlurEffect *_Nullable)blurEffect
            bgColor:(UIColor *_Nullable)bgColor
          maskAlpha:(CGFloat)maskAlpha
        isMaskAlpha:(BOOL)isMaskAlpha
           duration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
