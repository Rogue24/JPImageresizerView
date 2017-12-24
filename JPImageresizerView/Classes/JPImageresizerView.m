//
//  JPImageresizerView.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerView.h"
#import "JPImageresizerFrameView.h"

@interface JPImageresizerView () <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) JPImageresizerFrameView *frameView;

@property (nonatomic, strong) NSMutableArray *allDirections;
@property (nonatomic, assign) NSInteger directionIndex;

@end

@implementation JPImageresizerView
{
    CGFloat _verticalInset;
    CGFloat _horizontalInset;
}

#pragma mark - setter

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    [self.frameView updateFrameType:frameType];
}

- (void)setBgColor:(UIColor *)bgColor {
    if (bgColor == [UIColor clearColor]) bgColor = [UIColor blackColor];
    self.backgroundColor = bgColor;
    if (_frameView) _frameView.fillColor = bgColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    if (_frameView) _frameView.maskAlpha = maskAlpha;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.frameView.strokeColor = strokeColor;
}

- (void)setResizeImage:(UIImage *)resizeImage {
    self.imageView.image = resizeImage;
    [self updateSubviewLayouts];
}

- (void)setVerBaseMargin:(CGFloat)verBaseMargin {
    _verBaseMargin = verBaseMargin;
    [self updateSubviewLayouts];
}

- (void)setHorBaseMargin:(CGFloat)horBaseMargin {
    _horBaseMargin = horBaseMargin;
    [self updateSubviewLayouts];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    self.frameView.resizeWHScale = resizeWHScale;
}

- (void)setIsClockwiseRotation:(BOOL)isClockwiseRotation {
    if (_isClockwiseRotation == isClockwiseRotation) return;
    _isClockwiseRotation = isClockwiseRotation;
    [self.allDirections exchangeObjectAtIndex:1 withObjectAtIndex:3];
    if (self.directionIndex == 1) {
        self.directionIndex = 3;
    } else if (self.directionIndex == 3) {
        self.directionIndex = 1;
    }
}

#pragma mark - getter

- (JPImageresizerFrameType)frameType {
    return self.frameView.frameType;
}

- (UIColor *)bgColor {
    return self.backgroundColor;
}

- (UIColor *)strokeColor {
    return _frameView.strokeColor;
}

- (UIImage *)resizeImage {
    return _imageView.image;
}

- (CGFloat)resizeWHScale {
    return _frameView.resizeWHScale;
}

- (CGFloat)maskAlpha {
    return _frameView.maskAlpha;
}

#pragma mark - init

+ (JPImageresizerView *)imageresizerViewWithFrame:(CGRect)frame
                                      resizeImage:(UIImage *)resizeImage
                                    resizeWHScale:(CGFloat)resizeWHScale
                        imageresizerIsCanRecovery:(void (^)(BOOL))imageresizerIsCanRecovery {
    return [[self alloc] initWithFrame:frame
                             frameType:JPConciseFrameType 
                           resizeImage:resizeImage
                           strokeColor:[UIColor whiteColor]
                               bgColor:[UIColor blackColor]
                             maskAlpha:0.75
                         verBaseMargin:10
                         horBaseMargin:10
                         resizeWHScale:resizeWHScale
             imageresizerIsCanRecovery:imageresizerIsCanRecovery];
}

- (instancetype)initWithFrame:(CGRect)frame
                    frameType:(JPImageresizerFrameType)frameType
                  resizeImage:(UIImage *)resizeImage
                  strokeColor:(UIColor *)strokeColor
                      bgColor:(UIColor *)bgColor
                    maskAlpha:(CGFloat)maskAlpha
                verBaseMargin:(CGFloat)verBaseMargin
                horBaseMargin:(CGFloat)horBaseMargin
                resizeWHScale:(CGFloat)resizeWHScale
    imageresizerIsCanRecovery:(void(^)(BOOL isCanRecovery))imageresizerIsCanRecovery {
    if (self = [super initWithFrame:frame]) {
        _verBaseMargin = verBaseMargin;
        _horBaseMargin = horBaseMargin;
        self.bgColor = bgColor;
        [self setupBase];
        [self setupScorllView];
        [self setupImageViewWithImage:resizeImage];
        [self setupFrameViewWithFrameType:frameType
                              strokeColor:strokeColor
                                maskAlpha:maskAlpha
                            resizeWHScale:resizeWHScale
                       isCanRecoveryBlock:imageresizerIsCanRecovery];
    }
    return self;
}

- (void)setupBase {
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.allDirections = [@[@(JPImageresizerVerticalUpDirection),
                            @(JPImageresizerHorizontalLeftDirection),
                            @(JPImageresizerVerticalDownDirection),
                            @(JPImageresizerHorizontalRightDirection)] mutableCopy];
}

- (void)setupScorllView {
    CGFloat h = self.frame.size.height;
    CGFloat w = h * h / self.frame.size.width;
    CGFloat x = (self.frame.size.width - w) * 0.5;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(x, 0, w, h);
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 10.0;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.clipsToBounds = NO;
    if (@available(iOS 11.0, *)) scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)setupImageViewWithImage:(UIImage *)image {
    CGFloat maxW = self.frame.size.width - 2 * self.horBaseMargin;
    CGFloat maxH = self.frame.size.height - 2 * self.verBaseMargin;
    CGFloat whScale = image.size.width / image.size.height;
    CGFloat w = maxW;
    CGFloat h = w / whScale;
    if (h > maxH) {
        h = maxH;
        w = h * whScale;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, w, h);
    imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imageView];
    self.imageView = imageView;
    
    _verticalInset = (self.scrollView.bounds.size.height - h) * 0.5;
    _horizontalInset = (self.scrollView.bounds.size.width - self.frame.size.width) * 0.5 + self.horBaseMargin + (maxW - w) * 0.5;
    self.scrollView.contentSize = imageView.bounds.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(_verticalInset, _horizontalInset, _verticalInset, _horizontalInset);
    self.scrollView.contentOffset = CGPointMake(-_horizontalInset, -_verticalInset);
}

- (void)setupFrameViewWithFrameType:(JPImageresizerFrameType)frameType
                        strokeColor:(UIColor *)strokeColor
                            maskAlpha:(CGFloat)maskAlpha
                        resizeWHScale:(CGFloat)resizeWHScale
                   isCanRecoveryBlock:(void(^)(BOOL isCanRecovery))isCanRecoveryBlock {
    JPImageresizerFrameView *frameView =
        [[JPImageresizerFrameView alloc] initWithFrame:self.scrollView.frame
                                             frameType:frameType
                                           strokeColor:strokeColor
                                             fillColor:self.bgColor
                                             maskAlpha:maskAlpha
                                         verBaseMargin:_verBaseMargin
                                         horBaseMargin:_horBaseMargin
                                         resizeWHScale:resizeWHScale
                                            scrollView:self.scrollView
                                             imageView:self.imageView
                             imageresizerIsCanRecovery:isCanRecoveryBlock];
    [self addSubview:frameView];
    self.frameView = frameView;
}

#pragma mark - private method

- (void)updateSubviewLayouts {
    self.directionIndex = 0;
    
    self.scrollView.layer.transform = CATransform3DIdentity;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    CGFloat maxW = self.frame.size.width - 2 * self.horBaseMargin;
    CGFloat maxH = self.frame.size.height - 2 * self.verBaseMargin;
    CGFloat whScale = self.imageView.image.size.width / self.imageView.image.size.height;
    CGFloat w = maxW;
    CGFloat h = w / whScale;
    if (h > maxH) {
        h = maxH;
        w = h * whScale;
    }
    self.imageView.frame = CGRectMake(0, 0, w, h);
    
    _verticalInset = (self.scrollView.bounds.size.height - h) * 0.5;
    _horizontalInset = (self.scrollView.bounds.size.width - self.frame.size.width) * 0.5 + self.horBaseMargin + (maxW - w) * 0.5;
    
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(_verticalInset, _horizontalInset, _verticalInset, _horizontalInset);
    self.scrollView.contentOffset = CGPointMake(-_horizontalInset, -_verticalInset);
    
    [self.frameView updateImageresizerFrameWithVerBaseMargin:_verBaseMargin horBaseMargin:_horBaseMargin];
}

#pragma mark - puild method

- (void)updateResizeImage:(UIImage *)resizeImage verBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin {
    self.imageView.image = resizeImage;
    _verBaseMargin = verBaseMargin;
    _horBaseMargin = horBaseMargin;
    [self updateSubviewLayouts];
}

- (void)rotation {
    
    self.directionIndex += 1;
    if (self.directionIndex > self.allDirections.count - 1) self.directionIndex = 0;
    
    JPImageresizerRotationDirection direction = [self.allDirections[self.directionIndex] integerValue];
    
    CGFloat scale;
    if (direction == JPImageresizerHorizontalLeftDirection ||
        direction == JPImageresizerHorizontalRightDirection) {
        scale = self.frame.size.width / self.scrollView.bounds.size.height;
    } else {
        scale = self.scrollView.bounds.size.height / self.frame.size.width;
    }
    
    CGFloat angle = (self.isClockwiseRotation ? 1.0 : -1.0) * M_PI * 0.5;
    
    CATransform3D svTransform = self.scrollView.layer.transform;
    svTransform = CATransform3DScale(svTransform, scale, scale, 1);
    svTransform = CATransform3DRotate(svTransform, angle, 0, 0, 1);
    
    CATransform3D fvTransform = self.frameView.layer.transform;
    fvTransform = CATransform3DScale(fvTransform, scale, scale, 1);
    fvTransform = CATransform3DRotate(fvTransform, angle, 0, 0, 1);
    
    NSTimeInterval duration = 0.17;
    [self.frameView rotationWithDirection:direction rotationDuration:duration];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.scrollView.layer.transform = svTransform;
        self.frameView.layer.transform = fvTransform;
    } completion:nil];
}

- (void)recovery {
    if (!self.frameView.isCanRecovery) return;
    
    [self.frameView willRecovery];
    
    self.scrollView.minimumZoomScale = 1;
    self.directionIndex = 0;
    
    [UIView animateWithDuration:0.35 animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(_verticalInset, _horizontalInset, _verticalInset, _horizontalInset);
        self.scrollView.zoomScale = 1;
        self.scrollView.layer.transform = CATransform3DIdentity;
        self.frameView.layer.opacity = 0;
        self.frameView.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        [self.frameView recovery];
    }];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete {
    [self.frameView imageresizerWithComplete:complete];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.frameView endedImageresizer];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self.frameView endedImageresizer];
}

@end
