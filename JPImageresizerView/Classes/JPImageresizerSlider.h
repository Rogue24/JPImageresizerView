//
//  JPImageresizerSlider.h
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/8.
//

#import <UIKit/UIKit.h>

@interface JPImageresizerSlider : UIView
+ (CGFloat)viewHeight;
+ (instancetype)imageresizerSlider:(float)seconds second:(float)second;
- (void)setImageresizerFrame:(CGRect)imageresizerFrame isRoundResize:(BOOL)isRoundResize;
- (void)resetSeconds:(float)seconds second:(float)second;
- (float)seconds;
@property (nonatomic) float second;
@property (nonatomic, copy) void (^sliderBeginBlock)(float second, float totalSecond);
@property (nonatomic, copy) void (^sliderDragingBlock)(float second, float totalSecond);
@property (nonatomic, copy) void (^sliderEndBlock)(float second, float totalSecond);
@end
