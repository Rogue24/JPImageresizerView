//
//  JPBlurView.h
//  JPImageresizerView
//
//  Created by 周健平 on 2019/12/18.
//

#import <UIKit/UIKit.h>

@interface JPBlurView : UIView
- (instancetype)initWithFrame:(CGRect)frame blurEffect:(UIBlurEffect *)blurEffect fillColor:(UIColor *)fillColor;
- (UIBlurEffect *)blurEffect;
- (UIColor *)fillColor;
- (BOOL)isBlur;

- (void)setBlurEffect:(UIBlurEffect *)blurEffect animated:(BOOL)isAnimated;
- (void)setFillColor:(UIColor *)fillColor animated:(BOOL)isAnimated;
- (void)setIsBlur:(BOOL)isBlur animated:(BOOL)isAnimated;
- (void)setBlurEffect:(UIBlurEffect *)blurEffect fillColor:(UIColor *)fillColor isBlur:(BOOL)isBlur animated:(BOOL)isAnimated;
@end
