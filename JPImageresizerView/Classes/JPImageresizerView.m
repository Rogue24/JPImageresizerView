//
//  JPImageresizerView.m
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerView.h"

#ifdef DEBUG
#define JPIRLog(...) printf("%s %s 第%d行: %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define JPIRLog(...)
#endif

@interface JPImageresizerView () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *allDirections;
@property (nonatomic, assign) NSInteger directionIndex;
@end

@implementation JPImageresizerView
{
    UIEdgeInsets _contentInsets;
    UIViewAnimationOptions _animationOption;
}

#pragma mark - setter

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    [self.frameView updateFrameType:frameType];
}

- (void)setBlurEffect:(UIBlurEffect *)blurEffect {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:blurEffect bgColor:self.bgColor maskAlpha:self.maskAlpha animated:YES];
}

- (void)setBgColor:(UIColor *)bgColor {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:self.blurEffect bgColor:bgColor maskAlpha:self.maskAlpha animated:YES];
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    [self.frameView setupStrokeColor:self.strokeColor blurEffect:self.blurEffect bgColor:self.bgColor maskAlpha:maskAlpha animated:YES];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [self.frameView setupStrokeColor:strokeColor blurEffect:self.blurEffect bgColor:self.bgColor maskAlpha:self.maskAlpha animated:YES];
}

- (void)setResizeImage:(UIImage *)resizeImage {
    [self setResizeImage:resizeImage animated:YES transition:UIViewAnimationTransitionCurlUp];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    [self.frameView setResizeWHScale:resizeWHScale isToBeArbitrarily:NO animated:YES];
}

- (void)setInitialResizeWHScale:(CGFloat)initialResizeWHScale {
    self.frameView.initialResizeWHScale = initialResizeWHScale;
}

- (void)setEdgeLineIsEnabled:(BOOL)edgeLineIsEnabled {
    _edgeLineIsEnabled = edgeLineIsEnabled;
    self.frameView.edgeLineIsEnabled = edgeLineIsEnabled;
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

- (void)setDirectionIndex:(NSInteger)directionIndex {
    NSInteger maxIndex = self.allDirections.count - 1;
    NSInteger minIndex = 0;
    if (directionIndex < minIndex) {
        directionIndex = maxIndex;
    } else if (directionIndex > maxIndex) {
        directionIndex = minIndex;
    }
    _directionIndex = directionIndex;
}

- (void)setAnimationCurve:(JPAnimationCurve)animationCurve {
    _animationCurve = animationCurve;
    _frameView.animationCurve = animationCurve;
    switch (animationCurve) {
        case JPAnimationCurveEaseInOut:
            _animationOption = UIViewAnimationOptionCurveEaseInOut;
            break;
        case JPAnimationCurveEaseIn:
            _animationOption = UIViewAnimationOptionCurveEaseIn;
            break;
        case JPAnimationCurveEaseOut:
            _animationOption = UIViewAnimationOptionCurveEaseOut;
            break;
        case JPAnimationCurveLinear:
            _animationOption = UIViewAnimationOptionCurveLinear;
            break;
    }
}

- (void)setIsLockResizeFrame:(BOOL)isLockResizeFrame {
    self.frameView.panGR.enabled = !isLockResizeFrame;
}

- (void)setVerticalityMirror:(BOOL)verticalityMirror {
    [self setVerticalityMirror:verticalityMirror animated:YES];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror {
    [self setHorizontalMirror:horizontalMirror animated:YES];
}

- (void)setIsPreview:(BOOL)isPreview {
    [self setIsPreview:isPreview animated:YES];
}

- (void)setBorderImage:(UIImage *)borderImage {
    self.frameView.borderImage = borderImage;
}

- (void)setBorderImageRectInset:(CGPoint)borderImageRectInset {
    self.frameView.borderImageRectInset = borderImageRectInset;
}

- (void)setIsShowMidDots:(BOOL)isShowMidDots {
    self.frameView.isShowMidDots = isShowMidDots;
}

#pragma mark - getter

- (JPImageresizerFrameType)frameType {
    return _frameView.frameType;
}

- (CGSize)baseContentMaxSize {
    return _frameView.baseContentMaxSize;
}

- (UIBlurEffect *)blurEffect {
    return _frameView.blurEffect;
}

- (UIColor *)bgColor {
    return _frameView.bgColor;
}

- (CGFloat)maskAlpha {
    return _frameView.maskAlpha;
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

- (CGFloat)initialResizeWHScale {
    return _frameView.initialResizeWHScale;
}

- (CGFloat)imageresizeWHScale {
    CGFloat w = _frameView.imageresizerFrame.size.width;
    CGFloat h = _frameView.imageresizerFrame.size.height;
    if (w > 0.0 && h > 0.0) {
        return (w / h);
    }
    return 0.0;
}

- (BOOL)isLockResizeFrame {
    return !_frameView.panGR.enabled;
}

- (BOOL)isPreview {
    return _frameView.isPreview;
}

- (UIImage *)borderImage {
    return _frameView.borderImage;
}

- (CGPoint)borderImageRectInset {
    return _frameView.borderImageRectInset;
}

- (BOOL)isShowMidDots {
    return _frameView.isShowMidDots;
}

#pragma mark - init

+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure *)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    JPImageresizerView *imageresizerView = [[self alloc] initWithResizeImage:configure.resizeImage
                                       frame:configure.viewFrame
                                   frameType:configure.frameType
                              animationCurve:configure.animationCurve blurEffect:configure.blurEffect
                                     bgColor:configure.bgColor
                                   maskAlpha:configure.maskAlpha
                                 strokeColor:configure.strokeColor
                               resizeWHScale:configure.resizeWHScale
                               contentInsets:configure.contentInsets
                                 borderImage:configure.borderImage
                        borderImageRectInset:configure.borderImageRectInset
                            maximumZoomScale:configure.maximumZoomScale
                               isRoundResize:configure.isRoundResize
                               isShowMidDots:configure.isShowMidDots
                   imageresizerIsCanRecovery:imageresizerIsCanRecovery
                imageresizerIsPrepareToScale:imageresizerIsPrepareToScale];
    imageresizerView.edgeLineIsEnabled = configure.edgeLineIsEnabled;
    return imageresizerView;
}

- (instancetype)initWithResizeImage:(UIImage *)resizeImage
                              frame:(CGRect)frame
                          frameType:(JPImageresizerFrameType)frameType
                     animationCurve:(JPAnimationCurve)animationCurve
                         blurEffect:(UIBlurEffect *)blurEffect
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha
                        strokeColor:(UIColor *)strokeColor
                      resizeWHScale:(CGFloat)resizeWHScale
                      contentInsets:(UIEdgeInsets)contentInsets
                        borderImage:(UIImage *)borderImage
               borderImageRectInset:(CGPoint)borderImageRectInset
                   maximumZoomScale:(CGFloat)maximumZoomScale
                      isRoundResize:(BOOL)isRoundResize
                      isShowMidDots:(BOOL)isShowMidDots
          imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
       imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    
    NSAssert((frame.size.width != 0 && frame.size.height != 0), @"must have width and height.");
    
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.layer.backgroundColor = bgColor.CGColor;
        
        _contentInsets = contentInsets;
        
        CGFloat contentWidth = (self.bounds.size.width - _contentInsets.left - _contentInsets.right);
        CGFloat contentHeight = (self.bounds.size.height - _contentInsets.top - _contentInsets.bottom);
        CGSize baseContentMaxSize = CGSizeMake(contentWidth, contentHeight);
        
        self.allDirections = [@[@(JPImageresizerVerticalUpDirection),
                                @(JPImageresizerHorizontalLeftDirection),
                                @(JPImageresizerVerticalDownDirection),
                                @(JPImageresizerHorizontalRightDirection)] mutableCopy];
        
        self.animationCurve = animationCurve;
        
        [self __setupScrollViewWithBaseContentMaxSize:baseContentMaxSize maxZoomScale:maximumZoomScale];
        [self __setupImageViewWithImage:resizeImage];
        
        JPImageresizerFrameView *frameView =
        [[JPImageresizerFrameView alloc] initWithFrame:self.scrollView.frame
                                    baseContentMaxSize:baseContentMaxSize
                                             frameType:frameType
                                        animationCurve:animationCurve
                                            blurEffect:blurEffect
                                               bgColor:bgColor
                                             maskAlpha:maskAlpha
                                           strokeColor:strokeColor
                                         resizeWHScale:resizeWHScale
                                            scrollView:self.scrollView
                                             imageView:self.imageView
                                           borderImage:borderImage
                                  borderImageRectInset:borderImageRectInset
                                         isRoundResize:isRoundResize
                                         isShowMidDots:isShowMidDots
                             imageresizerIsCanRecovery:imageresizerIsCanRecovery
                          imageresizerIsPrepareToScale:imageresizerIsPrepareToScale];
        
        __weak typeof(self) wSelf = self;
        
        frameView.isVerticalityMirror = ^BOOL{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return NO;
            return sSelf.verticalityMirror;
        };
        
        frameView.isHorizontalMirror = ^BOOL{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return NO;
            return sSelf.horizontalMirror;
        };
        
        [self addSubview:frameView];
        _frameView = frameView;
    }
    return self;
}

#pragma mark - private method

- (void)__setupScrollViewWithBaseContentMaxSize:(CGSize)baseContentMaxSize maxZoomScale:(CGFloat)maxZoomScale {
    CGFloat w; // = hypot(self.bounds.size.width, self.bounds.size.height);
    CGFloat h;
    if (self.bounds.size.height > self.bounds.size.width) {
        h = self.bounds.size.height * 2;
        w = h;
    } else {
        w = self.bounds.size.width * 2;
        h = w;
    }
    CGFloat x = (baseContentMaxSize.width - w) * 0.5 + _contentInsets.left;
    CGFloat y = (baseContentMaxSize.height - h) * 0.5 + _contentInsets.top;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(x, y, w, h);
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = maxZoomScale > 1.0 ? maxZoomScale : 1.0;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.clipsToBounds = NO;
    scrollView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)__setupImageViewWithImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imageView];
    _imageView = imageView;
    [self __updateImageViewFrameWithImage:image];
}

- (void)__updateImageViewFrameWithImage:(UIImage *)image {
    NSAssert(image != nil, @"resizeImage cannot be nil.");
    CGFloat maxWidth = self.frame.size.width - _contentInsets.left - _contentInsets.right;
    CGFloat maxHeight = self.frame.size.height - _contentInsets.top - _contentInsets.bottom;
    CGFloat imgViewW = maxWidth;
    CGFloat imgViewH = imgViewW * (image.size.height / image.size.width);
    if (imgViewH > maxHeight) {
        imgViewH = maxHeight;
        imgViewW = imgViewH * (image.size.width / image.size.height);
    }
    CGRect imageViewBounds = CGRectMake(0, 0, imgViewW, imgViewH);
    self.imageView.bounds = imageViewBounds;
    
    self.scrollView.layer.transform = CATransform3DIdentity;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    self.imageView.frame = imageViewBounds;
    self.scrollView.contentSize = imageViewBounds.size;
    
    CGFloat horInset = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5;
    CGFloat verInset = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5;
    self.scrollView.contentInset = UIEdgeInsetsMake(verInset, horInset, verInset, horInset);
    self.scrollView.contentOffset = CGPointMake(-horInset, -verInset);
}

- (void)__updateSubviewLayouts:(UIImage *)image duration:(NSTimeInterval)duration {
    if (self.horizontalMirror) [self setHorizontalMirror:NO animated:NO];
    if (self.verticalityMirror) [self setVerticalityMirror:NO animated:NO];
    self.directionIndex = 0;
    [self __updateImageViewFrameWithImage:image];
    [self.frameView updateImageOriginFrameWithDuration:duration];
}

- (void)__changeMirror:(BOOL)isHorizontalMirror animated:(BOOL)isAnimated {
    CATransform3D transform = self.layer.transform;
    BOOL mirror;
    if (isHorizontalMirror) {
        transform = CATransform3DRotate(transform, M_PI, 1, 0, 0);
        mirror = _horizontalMirror;
    } else {
        transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
        mirror = _verticalityMirror;
    }
    
    [self.frameView willMirror:isAnimated];
    
    __weak typeof(self) wSelf = self;
    void (^animateBlock)(CATransform3D aTransform) = ^(CATransform3D aTransform){
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        sSelf.layer.transform = aTransform;
        if (isHorizontalMirror) {
            [sSelf.frameView horizontalMirrorWithDiffY:(mirror ? sSelf->_contentInsets.bottom : sSelf->_contentInsets.top)];
        } else {
            [sSelf.frameView verticalityMirrorWithDiffX:(mirror ? sSelf->_contentInsets.right : sSelf->_contentInsets.left)];
        }
    };
    
    if (isAnimated) {
        // 做3d旋转时会遮盖住上层的控件，设置为-500即可
        self.layer.zPosition = -500;
        transform.m34 = 1.0 / 1500.0;
        if (isHorizontalMirror) {
            transform.m34 *= -1.0;
        }
        if (mirror) {
            transform.m34 *= -1.0;
        }
        [UIView animateWithDuration:0.45 delay:0 options:_animationOption animations:^{
            animateBlock(transform);
        } completion:^(BOOL finished) {
            self.layer.zPosition = 0;
            [self.frameView mirrorDone];
        }];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        animateBlock(transform);
        [CATransaction commit];
        [self.frameView mirrorDone];
    }
}

- (void)__recoveryByTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily isToRoundResize:(BOOL)isToRoundResize {
    if (!self.frameView.isCanRecovery) {
        JPIRLog(@"jp_tip: 已经是初始状态，不需要重置");
        return;
    }
    
    if (isToRoundResize) {
        [self.frameView willRecoveryToRoundResize];
    } else {
        [self.frameView willRecoveryByResizeWHScale:targetResizeWHScale isToBeArbitrarily:isToBeArbitrarily];
    }
    
    self.directionIndex = 0;
    
    _horizontalMirror = NO;
    _verticalityMirror = NO;
    
    CGFloat x = (self.baseContentMaxSize.width - self.scrollView.bounds.size.width) * 0.5 + _contentInsets.left;
    CGFloat y = (self.baseContentMaxSize.height - self.scrollView.bounds.size.height) * 0.5 + _contentInsets.top;
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = x;
    frame.origin.y = y;
    
    // 做3d旋转时会遮盖住上层的控件，设置为-500即可
    self.layer.zPosition = -500;
    NSTimeInterval duration = 0.45;
    [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
        
        self.layer.transform = CATransform3DIdentity;
        self.scrollView.layer.transform = CATransform3DIdentity;
        self.frameView.layer.transform = CATransform3DIdentity;
        
        self.scrollView.frame = frame;
        self.frameView.frame = frame;
        
        [self.frameView recoveryWithDuration:duration];
        
    } completion:^(BOOL finished) {
        [self.frameView recoveryDone];
        self.layer.zPosition = 0;
    }];
}

#pragma mark - puild method

- (void)setResizeImage:(UIImage *)resizeImage animated:(BOOL)isAnimated transition:(UIViewAnimationTransition)transition {
    NSAssert(resizeImage != nil, @"resizeImage cannot be nil.");
    if (isAnimated) {
        if (transition == UIViewAnimationTransitionNone) {
            NSTimeInterval duration = 0.3;
            [UIView transitionWithView:self.imageView duration:duration options:(_animationOption | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
                self.imageView.image = resizeImage;
            } completion:nil];
            [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
                [self __updateSubviewLayouts:resizeImage duration:duration];
            } completion:nil];
        } else {
            NSTimeInterval duration = 0.45;
            [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
                [UIView setAnimationTransition:transition forView:self.imageView cache:YES];
                self.imageView.image = resizeImage;
                [self __updateSubviewLayouts:resizeImage duration:duration];
            } completion:nil];
        }
    } else {
        self.imageView.image = resizeImage;
        [self __updateSubviewLayouts:resizeImage duration:0];
    }
}

- (void)setupStrokeColor:(UIColor *)strokeColor
              blurEffect:(UIBlurEffect *)blurEffect
                 bgColor:(UIColor *)bgColor
               maskAlpha:(CGFloat)maskAlpha
                animated:(BOOL)isAnimated {
    [self.frameView setupStrokeColor:strokeColor
                          blurEffect:blurEffect
                             bgColor:bgColor
                           maskAlpha:maskAlpha
                            animated:isAnimated];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪宽高比暂不可设置，此时应该将设置按钮设为不可点或隐藏");
        return;
    }
    [self.frameView setResizeWHScale:resizeWHScale isToBeArbitrarily:isToBeArbitrarily animated:isAnimated];
}

- (void)roundResize:(BOOL)isAnimated {
    [self.frameView roundResize:isAnimated];
}

- (BOOL)isRoundResizing {
    return self.frameView.isRoundResizing;
}

- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_verticalityMirror == verticalityMirror) return;
    _verticalityMirror = verticalityMirror;
    [self __changeMirror:NO animated:isAnimated];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_horizontalMirror == horizontalMirror) return;
    _horizontalMirror = horizontalMirror;
    [self __changeMirror:YES animated:isAnimated];
}

- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated {
    [self.frameView setIsPreview:isPreview animated:isAnimated];
    self.scrollView.userInteractionEnabled = !isPreview;
}

- (void)updateResizeImage:(UIImage *)resizeImage {
    self.imageView.image = resizeImage;
    [self __updateSubviewLayouts:resizeImage duration:0];
}

- (void)rotation {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，旋转功能暂不可用，此时应该将旋转按钮设为不可点或隐藏");
        return;
    }
    
    BOOL isNormal = _verticalityMirror == _horizontalMirror;
    
    CGFloat angle = (self.isClockwiseRotation ? 1.0 : -1.0) * (isNormal ? 1.0 : -1.0) * M_PI_2;
    CATransform3D svTransform = CATransform3DRotate(self.scrollView.layer.transform, angle, 0, 0, 1);
    CATransform3D fvTransform = CATransform3DRotate(self.frameView.layer.transform, angle, 0, 0, 1);
    
    self.directionIndex += (isNormal ? 1 : -1);
    JPImageresizerRotationDirection direction = [self.allDirections[self.directionIndex] integerValue];
    
    NSTimeInterval duration = 0.25;
    [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
        self.scrollView.layer.transform = svTransform;
        self.frameView.layer.transform = fvTransform;
        [self.frameView rotationWithDirection:direction rotationDuration:duration];
    } completion:nil];
}

- (void)recoveryToRoundResize {
    [self __recoveryByTargetResizeWHScale:1 isToBeArbitrarily:NO isToRoundResize:YES];
}

- (void)recoveryByCurrentResizeWHScale {
    [self __recoveryByTargetResizeWHScale:self.resizeWHScale isToBeArbitrarily:NO isToRoundResize:NO];
}

- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily {
    [self __recoveryByTargetResizeWHScale:self.initialResizeWHScale isToBeArbitrarily:isToBeArbitrarily isToRoundResize:NO];
}

- (void)recoveryByTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily {
    [self __recoveryByTargetResizeWHScale:targetResizeWHScale isToBeArbitrarily:isToBeArbitrarily isToRoundResize:NO];
}

- (void)originImageresizerWithComplete:(void (^)(UIImage *))complete {
    [self imageresizerWithComplete:complete compressScale:1.0];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete compressScale:(CGFloat)compressScale {
    if (self.frameView.isPrepareToScale) {
        JPIRLog(@"jp_tip: 裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !complete ? : complete(nil);
        return;
    }
    if (compressScale <= 0) {
        JPIRLog(@"jp_tip: 压缩比例不能小于或等于0");
        !complete ? : complete(nil);
        return;
    }
    [self.frameView imageresizerWithComplete:complete compressScale:compressScale];
}

- (void)updateFrame:(CGRect)frame contentInsets:(UIEdgeInsets)contentInsets duration:(NSTimeInterval)duration {
    if (CGSizeEqualToSize(self.bounds.size, frame.size)) {
        if (UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
            self.frame = frame;
            return;
        }
    }
    _contentInsets = contentInsets;
    [self.frameView superViewUpdateFrame:frame contentInsets:contentInsets duration:duration];
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
