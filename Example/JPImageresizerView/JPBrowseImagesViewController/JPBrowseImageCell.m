//
//  JPBrowseImageCell.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImageCell.h"
#import "JPBrowseImagesViewController.h"

@interface JPBrowseImageCell () <UIScrollViewDelegate>
@property (nonatomic, weak) UIPanGestureRecognizer *panGR;
@end

@implementation JPBrowseImageCell
{
    BOOL _isHideProgress;
    BOOL _recover;
    BOOL _canPan;
    
    CGFloat _screenCenterY;
    CGFloat _currentCenterY;
    CGPoint _beginPosition;
}

#pragma mark - 初始化

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __setup];
    }
    return self;
}

- (void)__setup {
    self.backgroundColor = UIColor.clearColor;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [scrollView jp_contentInsetAdjustmentNever];
    scrollView.frame = JPPortraitScreenBounds;
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    _scrollView = scrollView;
    _screenCenterY = scrollView.bounds.size.height * 0.5;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, JPHalfOfDiff(JPPortraitScreenHeight, JPPortraitScreenWidth), JPPortraitScreenWidth, JPPortraitScreenWidth)];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = UIColor.lightGrayColor;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [scrollView addSubview:imageView];
    _imageView = imageView;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.scrollView addGestureRecognizer:tapGR];
    
    // 双击放大、还原
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGR.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapGR];

    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.scrollView addGestureRecognizer:panGR];
    self.panGR = panGR;
    
    // 设置双击、拖拽的优先级比单击高
    [tapGR requireGestureRecognizerToFail:doubleTapGR];
    [tapGR requireGestureRecognizerToFail:panGR];
    
    JPBrowseImageProgressLayer *progressLayer = [JPBrowseImageProgressLayer browseImageProgressLayer];
    progressLayer.hidden = YES;
    [self.layer addSublayer:progressLayer];
    _progressLayer = progressLayer;
    _isHideProgress = YES;
}

#pragma mark - API

- (void)hideImageView {
    self.imageView.hidden = YES;
}

- (void)showImageView {
    self.progressLayer.hidden = _isHideProgress;
    self.imageView.hidden = NO;
    self.isDisplaying = YES;
}

- (void)setPanGRDelegate:(id<UIGestureRecognizerDelegate>)panGRDelegate {
    // 让控制器成为代理，能同时执行collectionView和pan手势不冲突
    self.panGR.delegate = panGRDelegate;
}

- (void)setModel:(JPBrowseImageModel *)model index:(NSInteger)index {
    _model = model;
    _index = index;
    
    _isDisplaying = NO;
    _isHideProgress = YES;
    _isSetingImage = YES;
    _isSetImageSuccess = NO;
    
    self.scrollView.panGestureRecognizer.enabled = YES;
    self.scrollView.pinchGestureRecognizer.enabled = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    [self __resetImageViewWithModel:model];
    self.progressLayer.hidden = YES;
    self.progressLayer.progress = 0;
    [CATransaction commit];
    
    if ([self.superVC.delegate respondsToSelector:@selector(cellRequestImage:index:progressBlock:completeBlock:)]) {
        @jp_weakify(self);
        [self.superVC.delegate cellRequestImage:self index:index progressBlock:^(NSInteger kIndex, JPBrowseImageModel *kModel, float percent) {
            @jp_strongify(self);
            if (!self || !self.superVC.isShowProgress || self.index != kIndex || self.model != kModel) return;
            if (!self.imageView.hidden && self.progressLayer.hidden) self.progressLayer.hidden = NO;
            self->_isHideProgress = NO;
            self.progressLayer.progress = percent;
        } completeBlock:^(NSInteger kIndex, JPBrowseImageModel *kModel, UIImage *resultImage) {
            @jp_strongify(self);
            if (!self || self.isDismiss || self.index != kIndex || self.model != kModel) return;
            
            self->_isSetingImage = NO;
            self->_isHideProgress = YES;
            self.progressLayer.hidden = YES;
            
            if (resultImage) {
                self.imageView.image = resultImage;
                self->_isSetImageSuccess = YES;
                self->_canPan = NO;
                if (!CGSizeEqualToSize(model.imageSize, resultImage.size)) {
                    model.imageSize = resultImage.size;
                    [self __resetImageViewWithModel:model];
                }
            } else if (self.isDisplaying && [self.superVC.delegate respondsToSelector:@selector(requestImageFailWithModel:index:)]) {
                [self.superVC.delegate requestImageFailWithModel:kModel index:kIndex];
            }
        }];
    }
}

- (void)setIsDisplaying:(BOOL)isDisplaying {
    _isDisplaying = isDisplaying;
    if (isDisplaying &&
        !self.isSetingImage &&
        !self.isSetImageSuccess &&
        [self.superVC.delegate respondsToSelector:@selector(requestImageFailWithModel:index:)]) {
        [self.superVC.delegate requestImageFailWithModel:self.model index:self.index];
    }
}

#pragma mark - 私有方法

- (void)__resetImageViewWithModel:(JPBrowseImageModel *)model {
    UIScrollView *scrollView = self.scrollView;
    UIImageView *imageView = self.imageView;
    
    scrollView.maximumZoomScale = model.maximumScale;
    scrollView.zoomScale = scrollView.minimumZoomScale;
    
    imageView.backgroundColor = imageView.image ? UIColor.blackColor : UIColor.lightGrayColor;
    imageView.contentMode = model.contentMode;
    imageView.frame = (CGRect){CGPointZero, model.contentSize};
    
    scrollView.contentSize = model.contentSize;
    scrollView.contentInset = model.contentInset;
    scrollView.contentOffset = CGPointMake(-model.contentInset.left, -model.contentInset.top);
}

- (void)__resetScrollView:(BOOL)isPanEnd anchorPoint:(CGPoint)anchorPoint {
    UIScrollView *scrollView = self.scrollView;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    scrollView.layer.masksToBounds = isPanEnd;
    scrollView.layer.anchorPoint = anchorPoint;
    scrollView.layer.position = CGPointMake(scrollView.bounds.size.width * anchorPoint.x,
                                            scrollView.bounds.size.height * anchorPoint.y);
    if (self.imageView.image) self.imageView.backgroundColor = isPanEnd ? UIColor.clearColor : UIColor.blackColor;
    [CATransaction commit];
    
    // cell已经结束拖动，让collectionView能滚动
    self.superVC.collectionView.scrollEnabled = isPanEnd;
    scrollView.panGestureRecognizer.enabled = isPanEnd;
    scrollView.pinchGestureRecognizer.enabled = isPanEnd;
}

- (void)__resetContentInset {
    CGFloat zoomScale = self.scrollView.zoomScale;
    if (zoomScale < 1) {
        self.scrollView.contentInset = self.model.contentInset;
    } else {
        CGFloat h = self.imageView.bounds.size.height * zoomScale;
        CGFloat verInset;
        if (h > self.scrollView.bounds.size.height) {
            verInset = 0;
        } else {
            verInset = JPHalfOfDiff(self.scrollView.bounds.size.height, h);
        }
        CGFloat topInset = verInset < JPStatusBarH ? JPStatusBarH : verInset;
        CGFloat bottomInset = verInset < JPDiffTabBarH ? JPDiffTabBarH : verInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
    }
}

#pragma mark - 手势监听

- (void)tap:(UITapGestureRecognizer *)tapGR {
    if (!self.superVC.isShowNavigationBar) self.progressLayer.hidden = YES;
    !self.singleClickBlock ? : self.singleClickBlock();
}

// 双击放大、还原
- (void)doubleTap:(UITapGestureRecognizer *)doubleTapGR {
    if (!self.progressLayer.hidden) return;
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat scale = self.scrollView.maximumZoomScale;
        CGFloat sw = self.scrollView.bounds.size.width;
        CGFloat sh = self.scrollView.bounds.size.height;
        CGFloat iw = self.imageView.bounds.size.width;
        CGFloat ih = self.imageView.bounds.size.height;
        CGPoint tp = [doubleTapGR locationInView:self.imageView];
        if (tp.x < 0) {
            tp.x = 0;
        } else if (tp.x > iw) {
            tp.x = iw;
        }
        if (tp.y < 0) {
            tp.y = 0;
        } else if (tp.y > ih) {
            tp.y = ih;
        }
        CGFloat w = iw / scale;
        CGFloat h = w * (sh / sw);
        CGFloat x = tp.x - w * 0.5;
        CGFloat y = tp.y - h * 0.5;
        if (x < 0) {
            x = 0;
        } else if (x > (iw - w)) {
            x = iw - w;
        }
        if (y < 0) {
            y = 0;
        } else if (y > (ih - h)) {
            y = ih - h;
        }
        [self.scrollView zoomToRect:CGRectMake(x, y, w, h) animated:YES];
    }
}

- (void)pan:(UIPanGestureRecognizer *)panGR {
    if (!self.progressLayer.hidden ||
        self.isSetingImage ||
        self.scrollView.zooming ||
        self.scrollView.contentOffset.y > 0) return;
    
    UIScrollView *scrollView = self.scrollView;
    UIView *bgView = self.superVC.bgView;
    
    CGPoint translation = [panGR translationInView:self];
    [panGR setTranslation:CGPointZero inView:self];
    
    if (panGR.state == UIGestureRecognizerStateBegan) {
        _recover = YES;
        _canPan = YES;
        
        bgView.alpha = 1;
        
        // 判断是否为垂直方向（fabs：求绝对值）
        CGPoint velocity = [panGR velocityInView:self];
        BOOL isVerticalGesture = (fabs(velocity.y) > fabs(velocity.x)) && velocity.y > 0;
        if (!isVerticalGesture) {
            _canPan = NO;
            return;
        }
        
        _currentCenterY = _screenCenterY;
        _beginPosition = [panGR locationInView:self];
        CGPoint anchorPoint = CGPointMake(_beginPosition.x / scrollView.bounds.size.width,
                                          _beginPosition.y / scrollView.bounds.size.height);
        [self __resetScrollView:NO anchorPoint:anchorPoint];
        
        !self.beginPanBlock ? : self.beginPanBlock();
    }
    
    if (panGR.state == UIGestureRecognizerStateChanged) {
        // 如果不能滚动，就不要进行形变操作
        if (!_canPan) return;
        
        _currentCenterY += translation.y;
        
        CGFloat sizeScale = 1;
        CGFloat bgAlpha = 1;
        if (_currentCenterY > _screenCenterY) {
            CGFloat currMargin = _currentCenterY - _screenCenterY;
            
            CGFloat diffMargin = _screenCenterY * 0.5;
            _recover = currMargin <= diffMargin;
            
            CGFloat scale = currMargin / _screenCenterY;
            if (scale > 1) scale = 1;
            
            bgAlpha = 1 - scale;
            
            // 1 - 0.4 = 0.6 为最大缩放比例
            sizeScale = (scrollView.bounds.size.width * (1 - scale * 0.4)) / scrollView.frame.size.width;
        } else {
            _recover = YES;
        }
        
        // 缩放
        CATransform3D transform = CATransform3DScale(scrollView.layer.transform, sizeScale, sizeScale, 1);
        // 位移
        CGPoint position = [panGR locationInView:self];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        bgView.alpha = bgAlpha; // 背景透明度
        scrollView.layer.transform = transform;
        scrollView.layer.position = position;
        [CATransaction commit];
    }
    
    if (panGR.state == UIGestureRecognizerStateEnded ||
        panGR.state == UIGestureRecognizerStateCancelled ||
        panGR.state == UIGestureRecognizerStateFailed) {
        
        if (!_canPan) {
            bgView.alpha = 1;
            if (!self.superVC.collectionView.scrollEnabled) {
                [self __resetScrollView:YES anchorPoint:CGPointMake(0.5, 0.5)];
            }
            return;
        }
        
        _canPan = NO;
        
        CGPoint velocity = [panGR velocityInView:self];
//        JPLog(@"结束时的速度 %@", NSStringFromCGPoint(velocity));
        BOOL isDismiss = (velocity.y > 1000 || !_recover);
        
        if (isDismiss) {
            [self.superVC dismiss];
        } else {
            [UIView animateWithDuration:0.3 delay:0 options:kNilOptions animations:^{
                scrollView.layer.transform = CATransform3DIdentity;
                scrollView.layer.position = self->_beginPosition;
                bgView.alpha = 1;
            } completion:^(BOOL finished) {
                [self __resetScrollView:YES anchorPoint:CGPointMake(0.5, 0.5)];
            }];
            
            !self.endPanBlock ? : self.endPanBlock();
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (!self.progressLayer.hidden) {
        return nil;
    } else {
        return self.imageView;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.panGR.enabled = NO;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self __resetContentInset];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self __resetContentInset];
    self.panGR.enabled = YES;
}

@end


@interface JPBrowseImageProgressLayer ()
@property (nonatomic, weak) CALayer *bgLayer;
@property (nonatomic, weak) CAShapeLayer *progressLayer;
@end

@implementation JPBrowseImageProgressLayer

+ (instancetype)browseImageProgressLayer {
    JPBrowseImageProgressLayer *bipLayer = [JPBrowseImageProgressLayer layer];
    bipLayer.frame = JPPortraitScreenBounds;
    bipLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    
    CGFloat w = 40;
    CGFloat h = 40;
    CGFloat x = JPHalfOfDiff(JPPortraitScreenWidth, w);
    CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight, h);
    
    CALayer *bgLayer = [CALayer layer];
    bgLayer.frame = CGRectMake(x, y, w, h);
    bgLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
    bgLayer.masksToBounds = YES;
    bgLayer.cornerRadius = 20;
    [bipLayer addSublayer:bgLayer];
    bipLayer.bgLayer = bgLayer;
    
    CGFloat lineWidth = 3;
    
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.frame = bgLayer.bounds;
    progressLayer.fillColor = UIColor.clearColor.CGColor;
    progressLayer.lineWidth = lineWidth;
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.7].CGColor;
    progressLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(20, 20) radius:17.5 startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES].CGPath;
    progressLayer.strokeStart = 0.0;
    progressLayer.strokeEnd = 0.05;
    [bgLayer addSublayer:progressLayer];
    bipLayer.progressLayer = progressLayer;
    
    return bipLayer;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressLayer.strokeEnd = progress;
}

@end
