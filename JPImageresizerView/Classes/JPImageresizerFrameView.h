//
//  JPImageresizerFrameView.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/11.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPImageMaskView;

typedef NS_ENUM(NSUInteger, JPImageresizerRotationDirection) {
    JPImageresizerVerticalUpDirection = 0,
    JPImageresizerHorizontalLeftDirection,
    JPImageresizerVerticalDownDirection,
    JPImageresizerHorizontalRightDirection
};

@interface JPImageresizerFrameView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  strokeColor:(UIColor *)strokeColor
                    fillColor:(UIColor *)fillColor
                    maskAlpha:(CGFloat)maskAlpha
               maxResizeFrame:(CGRect)maxResizeFrame
                resizeWHScale:(CGFloat)resizeWHScale
                   scrollView:(UIScrollView *)scrollView
                    imageView:(JPImageMaskView *)imageView
    imageresizerIsCanRecovery:(void(^)(BOOL isCanRecovery))imageresizerIsCanRecovery;

@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, assign) CGFloat maskAlpha;

@property (nonatomic, assign) CGFloat resizeWHScale;

@property (nonatomic, assign) CGRect maxResizeFrame;

@property (nonatomic, copy) void (^imageresizerIsCanRecovery)(BOOL isCanRecovery);

@property (nonatomic, assign) CGRect imageresizerFrame;

@property (nonatomic, assign, readonly) JPImageresizerRotationDirection rotationDirection;

@property (nonatomic, assign, readonly) BOOL isCanRecovery;

- (void)startImageresizer;
- (void)endedImageresizer;

- (void)willRotationWithImageMaskFrame:(CGRect)imageMaskFrame;
- (void)updateRotationDirection:(JPImageresizerRotationDirection)rotationDirection;
- (void)endedRotation;

- (void)willRecovery;
- (void)recovery;

- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete;

@end
