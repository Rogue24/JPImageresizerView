//
//  JPImageresizerFrameView.h
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/11.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerTypedef.h"
@class JPImageresizerSlider;

@interface JPImageresizerProxy : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@property (nonatomic, weak) id target;
@end

@interface JPImageresizerFrameView : UIView

- (instancetype)initWithFrame:(CGRect)frame
           baseContentMaxSize:(CGSize)baseContentMaxSize
                    frameType:(JPImageresizerFrameType)frameType
               animationCurve:(JPAnimationCurve)animationCurve
                   blurEffect:(UIBlurEffect *)blurEffect
                      bgColor:(UIColor *)bgColor
                    maskAlpha:(CGFloat)maskAlpha
                  strokeColor:(UIColor *)strokeColor
                resizeWHScale:(CGFloat)resizeWHScale
                isRoundResize:(BOOL)isRoundResize
                    maskImage:(UIImage *)maskImage
                isArbitrarily:(BOOL)isArbitrarily
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView
                  borderImage:(UIImage *)borderImage
         borderImageRectInset:(CGPoint)borderImageRectInset
                isShowMidDots:(BOOL)isShowMidDots
           isBlurWhenDragging:(BOOL)isBlurWhenDragging
      isShowGridlinesWhenIdle:(BOOL)isShowGridlinesWhenIdle
  isShowGridlinesWhenDragging:(BOOL)isShowGridlinesWhenDragging
                    gridCount:(NSUInteger)gridCount
    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale
          isVerticalityMirror:(BOOL(^)(void))isVerticalityMirror
           isHorizontalMirror:(BOOL(^)(void))isHorizontalMirror
             resizeObjWhScale:(CGFloat(^)(void))resizeObjWhScale;

@property (nonatomic, copy) BOOL (^isVerticalityMirror)(void);
@property (nonatomic, copy) BOOL (^isHorizontalMirror)(void);
@property (nonatomic, copy) CGFloat (^resizeObjWhScale)(void);

@property (nonatomic, assign, readonly) CGSize baseContentMaxSize;

@property (nonatomic, weak, readonly) UIPanGestureRecognizer *panGR;

@property (nonatomic, assign, readonly) JPImageresizerFrameType frameType;

@property (nonatomic, assign, readonly) NSTimeInterval defaultDuration;

@property (nonatomic, assign) JPAnimationCurve animationCurve;

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic) UIBlurEffect *blurEffect;
@property (nonatomic) UIColor *bgColor;
@property (nonatomic) CGFloat maskAlpha;
- (void)setupStrokeColor:(UIColor *)strokeColor
              blurEffect:(UIBlurEffect *)blurEffect
                 bgColor:(UIColor *)bgColor
               maskAlpha:(CGFloat)maskAlpha
                animated:(BOOL)isAnimated;

@property (nonatomic, assign, readonly) CGRect imageresizerFrame;
@property (readonly) CGFloat imageresizerWHScale;

@property (nonatomic, assign) CGFloat resizeWHScale;
- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

@property (nonatomic, assign) BOOL isRoundResize;
- (void)setIsRoundResize:(BOOL)isRoundResize isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

@property (nonatomic, strong) UIImage *maskImage;
- (void)setMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

@property (nonatomic, assign) BOOL isArbitrarily;
- (void)setIsArbitrarily:(BOOL)isArbitrarily animated:(BOOL)isAnimated;

@property (nonatomic, assign) BOOL isPreview;
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated;

@property (nonatomic, assign) CGFloat initialResizeWHScale;

@property (nonatomic, assign) BOOL edgeLineIsEnabled;

@property (nonatomic, assign, readonly) BOOL isCanRecovery;
@property (nonatomic, copy) JPImageresizerIsCanRecoveryBlock imageresizerIsCanRecovery;

@property (nonatomic, assign) BOOL isPrepareToScale;
@property (nonatomic, copy) JPImageresizerIsPrepareToScaleBlock imageresizerIsPrepareToScale;

@property (nonatomic, assign, readonly) JPImageresizerRotationDirection direction;

@property (nonatomic, strong) UIImage *borderImage;
@property (nonatomic, assign) CGPoint borderImageRectInset;

@property (nonatomic, assign) BOOL isShowMidDots;
@property (nonatomic, assign) BOOL isBlurWhenDragging;
@property (nonatomic, assign) BOOL isShowGridlinesWhenIdle;
@property (nonatomic, assign) BOOL isShowGridlinesWhenDragging;
@property (nonatomic, assign) NSUInteger gridCount;

- (void)updateFrameType:(JPImageresizerFrameType)frameType;

- (void)updateImageOriginFrameWithDuration:(NSTimeInterval)duration;

- (void)startImageresizer;
- (void)endedImageresizer;

- (NSTimeInterval)willRotationWithDirection:(JPImageresizerRotationDirection)direction;
- (void)rotatingWithDuration:(NSTimeInterval)duration;
- (void)rotationDone;

- (NSTimeInterval)willMirror:(BOOL)isHorizontalMirror diffValue:(CGFloat)diffValue afterFrame:(CGRect *)afterFrame animated:(BOOL)isAnimated;
- (void)mirrorDone;

- (NSTimeInterval)willRecoveryToResizeWHScale:(CGFloat)resizeWHScale
                              orToRoundResize:(BOOL)isRoundResize
                                orToMaskImage:(UIImage *)maskImage
                            isToBeArbitrarily:(BOOL)isToBeArbitrarily
                                     animated:(BOOL)isAnimated;
- (void)recoveryWithDuration:(NSTimeInterval)duration;
- (void)recoveryDone:(BOOL)isUpdateMaskImage;

- (void)recoveryToSavedHistoryWithDirection:(JPImageresizerRotationDirection)direction imageresizerFrame:(CGRect)imageresizerFrame isToBeArbitrarily:(BOOL)isToBeArbitrarily;

- (void)superViewUpdateFrame:(CGRect)superViewFrame contentInsets:(UIEdgeInsets)contentInsets duration:(NSTimeInterval)duration;

@property (nonatomic, weak) UIView *playerView;
@property (nonatomic, weak) JPImageresizerSlider *slider;

- (JPCropConfigure)currentCropConfigure;
@end
