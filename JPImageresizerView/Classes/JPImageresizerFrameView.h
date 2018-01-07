//
//  JPImageresizerFrameView.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/11.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerView.h"

typedef NS_ENUM(NSUInteger, JPImageresizerRotationDirection) {
    JPImageresizerVerticalUpDirection = 0,
    JPImageresizerHorizontalLeftDirection,
    JPImageresizerVerticalDownDirection,
    JPImageresizerHorizontalRightDirection
};

@interface JPImageresizerFrameView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  contentSize:(CGSize)contentSize
                     maskType:(JPImageresizerMaskType)maskType
                    frameType:(JPImageresizerFrameType)frameType
               animationCurve:(JPAnimationCurve)animationCurve
                  strokeColor:(UIColor *)strokeColor
                    fillColor:(UIColor *)fillColor
                    maskAlpha:(CGFloat)maskAlpha
                verBaseMargin:(CGFloat)verBaseMargin
                horBaseMargin:(CGFloat)horBaseMargin
                resizeWHScale:(CGFloat)resizeWHScale
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView
    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

@property (nonatomic, assign, readonly) JPImageresizerMaskType maskType;

@property (nonatomic, assign, readonly) JPImageresizerFrameType frameType;

@property (nonatomic, weak, readonly) UIPanGestureRecognizer *panGR;

@property (nonatomic, assign) JPAnimationCurve animationCurve;

@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, assign) CGFloat maskAlpha;

@property (nonatomic, assign, readonly) CGRect imageresizerFrame;

@property (nonatomic, assign) CGFloat resizeWHScale;
- (void)setResizeWHScale:(CGFloat)resizeWHScale animated:(BOOL)isAnimated;

@property (nonatomic, assign, readonly) BOOL isCanRecovery;
@property (nonatomic, copy) JPImageresizerIsCanRecoveryBlock imageresizerIsCanRecovery;

@property (nonatomic, assign, readonly) BOOL isPrepareToScale;
@property (nonatomic, copy) JPImageresizerIsPrepareToScaleBlock imageresizerIsPrepareToScale;

@property (nonatomic, assign, readonly) JPImageresizerRotationDirection rotationDirection;

@property (nonatomic, readonly) BOOL isHorizontalDirection;

@property (nonatomic, assign, readonly) CGFloat sizeScale;

@property (nonatomic, assign, readonly) CGFloat scrollViewMinZoomScale;

@property (nonatomic, assign) BOOL isRotatedAutoScale;

@property (nonatomic, copy) BOOL (^isVerticalityMirror)(void);
@property (nonatomic, copy) BOOL (^isHorizontalMirror)(void);

- (void)updateFrameType:(JPImageresizerFrameType)frameType;

- (void)updateImageresizerFrameWithVerBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin;

- (void)startImageresizer;
- (void)endedImageresizer;

- (void)rotationWithDirection:(JPImageresizerRotationDirection)direction rotationDuration:(NSTimeInterval)rotationDuration;

- (void)willRecovery;
- (void)recovery;
- (void)recoveryDone;

- (void)willMirror:(BOOL)animated;
- (void)verticalityMirrorWithDiffX:(CGFloat)diffX;
- (void)horizontalMirrorWithDiffY:(CGFloat)diffY;
- (void)mirrorDone;

- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete;

@end
