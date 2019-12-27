//
//  JPImageresizerBlurView.h
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import <UIKit/UIKit.h>

@interface JPImageresizerBlurView : UIView
- (instancetype)initWithFrame:(CGRect)frame
                   blurEffect:(UIBlurEffect *)blurEffect
                      bgColor:(UIColor *)bgColor
                    maskAlpha:(CGFloat)maskAlpha;

- (BOOL)isBlur;
- (UIBlurEffect *)blurEffect;
- (UIColor *)bgColor;
- (CGFloat)maskAlpha;
- (BOOL)isMaskAlpha;

- (void)setIsBlur:(BOOL)isBlur duration:(NSTimeInterval)duration;
- (void)setBlurEffect:(UIBlurEffect *)blurEffect duration:(NSTimeInterval)duration;
- (void)setBgColor:(UIColor *)bgColor duration:(NSTimeInterval)duration;
- (void)setMaskAlpha:(BOOL)maskAlpha duration:(NSTimeInterval)duration;
- (void)setIsMaskAlpha:(BOOL)isMaskAlpha duration:(NSTimeInterval)duration;

- (void)setupIsBlur:(BOOL)isBlur
         blurEffect:(UIBlurEffect *)blurEffect
            bgColor:(UIColor *)bgColor
          maskAlpha:(CGFloat)maskAlpha
        isMaskAlpha:(BOOL)isMaskAlpha
           duration:(NSTimeInterval)duration;
@end
