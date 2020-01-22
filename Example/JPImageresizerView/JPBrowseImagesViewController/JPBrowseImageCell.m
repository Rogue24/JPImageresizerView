//
//  JPBrowseImageCell.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImageCell.h"
#import "JPBrowseImagesViewController.h"
//#import <PhotosUI/PhotosUI.h>

@interface JPBrowseImageCell () <UIScrollViewDelegate>
@property (nonatomic, weak) UIPanGestureRecognizer *panGR;
@property (nonatomic, assign) CGFloat imageViewCenterY;
@property (nonatomic, assign) CGFloat screenCenterY;
@property (nonatomic, assign) BOOL recover;
@property (nonatomic, assign) BOOL canPan;
@property (nonatomic, assign) BOOL isHideProgress;

//@property (nonatomic, weak) PHLivePhotoView *livePHView;
@property (nonatomic, weak) UIImageView *originImgView;

@property (nonatomic, assign) CGRect panBeginImgViewFrame;
@property (nonatomic, assign) CGPoint panBeginImgViewPosition;
@property (nonatomic, assign) CATransform3D panBeginImgViewTransform;
@end

@implementation JPBrowseImageCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11.0, *)) scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.frame = [UIScreen mainScreen].bounds;
    CGFloat diffStatusBarH = 0;
    CGFloat diffTabBarH = 0;
    BOOL isX = [UIScreen mainScreen].bounds.size.height > 736.0;
    if (isX) {
        diffStatusBarH += 24;
        diffTabBarH += 34;
    }
    scrollView.contentInset = UIEdgeInsetsMake(diffStatusBarH, 0, diffTabBarH, 0);
    scrollView.contentSize = CGSizeMake(0, scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom);
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 1.0;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [scrollView addSubview:imageView];
    self.imageView = imageView;
    
//    PHLivePhotoView *livePHView = [[PHLivePhotoView alloc] init];
//    livePHView.userInteractionEnabled = YES;
//    livePHView.backgroundColor = InfiniteePicBgColor;
//    livePHView.contentMode = UIViewContentModeScaleAspectFill;
//    livePHView.layer.masksToBounds = YES;
//    [scrollView addSubview:livePHView];
//    self.livePHView = livePHView;
    
    self.screenCenterY = scrollView.bounds.size.height * 0.5;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.scrollView addGestureRecognizer:tapGR];
    
    //双击放大、还原
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargeOrReturn:)];
    doubleTapGR.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapGR];

    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.scrollView addGestureRecognizer:panGR];
    // 公开pan手势，让控制器成为代理，能同时执行collectionView和pan手势不冲突
    self.panGR = panGR;
    
    // 设置双击优先级比单击高
    [tapGR requireGestureRecognizerToFail:doubleTapGR];
    [tapGR requireGestureRecognizerToFail:panGR];
    
    JPBrowseImageProgressLayer *progressLayer = [JPBrowseImageProgressLayer browseImageProgressLayer];
    progressLayer.hidden = YES;
    [self.layer addSublayer:progressLayer];
    self.progressLayer = progressLayer;
    
    self.isHideProgress = YES;
}

- (void)hideImageView {
    self.imageView.hidden = YES;
}

- (void)showImageView {
    self.progressLayer.hidden = self.isHideProgress;
    self.imageView.hidden = NO;
    self.isDisplaying = YES;
}

- (void)setPanGRDelegate:(id<UIGestureRecognizerDelegate>)panGRDelegate {
    self.panGR.delegate = panGRDelegate;
}

- (void)setModel:(JPBrowseImageModel *)model index:(NSInteger)index {
    _model = model;
    _index = index;
    
    _isDisplaying = NO;
    self.isHideProgress = YES;
    self.isSetingImage = YES;
    self.isSetImageSuccess = NO;
    
    self.scrollView.panGestureRecognizer.enabled = YES;
    self.scrollView.pinchGestureRecognizer.enabled = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    [self resetImageViewWithModel:model];
    self.progressLayer.hidden = YES;
    self.progressLayer.progress = 0;
    [CATransaction commit];
    
    if ([self.superVC.delegate respondsToSelector:@selector(cellRequestImage:index:progressBlock:completeBlock:)]) {
        __weak typeof(self) wSelf = self;
        [self.superVC.delegate cellRequestImage:self index:index progressBlock:^(NSInteger kIndex, JPBrowseImageModel *kModel, float percent) {
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf || !sSelf.isShowProgress || sSelf.index != kIndex || sSelf.model != kModel) return;
            if (!sSelf.imageView.hidden && sSelf.progressLayer.hidden) sSelf.progressLayer.hidden = NO;
            sSelf.isHideProgress = NO;
            sSelf.progressLayer.progress = percent;
        } completeBlock:^(NSInteger kIndex, JPBrowseImageModel *kModel, UIImage *resultImage) {
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf || sSelf.isDismiss || sSelf.index != kIndex || sSelf.model != kModel) return;
            
            sSelf.isSetingImage = NO;
            sSelf.progressLayer.hidden = YES;
            sSelf.isHideProgress = YES;
            
            if (resultImage) {
                sSelf.imageView.image = resultImage;
                sSelf.isSetImageSuccess = YES;
                CGSize pictureSize = resultImage.size;
                if (sSelf.model.pictureFrame.size.width != pictureSize.width ||
                    sSelf.model.pictureFrame.size.height != pictureSize.height) {
                    CGRect contentFrame = self.superVC.contentFrame;
                    CGFloat w = contentFrame.size.width;
                    CGFloat h = (CGFloat)((NSInteger)(w * pictureSize.height / pictureSize.width));
                    CGFloat y = contentFrame.origin.y + (contentFrame.size.height - h) * 0.5;
                    if (y < contentFrame.origin.y) y = contentFrame.origin.y;
                    CGRect pictureFrame = CGRectMake(0, y, w, h);
                    sSelf.model.pictureFrame = pictureFrame;
                    
                    sSelf.canPan = NO;
                    sSelf.panGR.enabled = NO;
                    [sSelf resetImageViewWithModel:model];
                    sSelf.panGR.enabled = YES;
                }
            } else if (sSelf.isDisplaying && [sSelf.superVC.delegate respondsToSelector:@selector(requestImageFailWithModel:index:)]) {
                [sSelf.superVC.delegate requestImageFailWithModel:kModel index:kIndex];
            }
        }];
    }
}

- (void)resetImageViewWithModel:(JPBrowseImageModel *)model {
    self.scrollView.maximumZoomScale = model.maximumScale;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.contentSize = CGSizeMake(0, model.pictureFrame.size.height);
    self.scrollView.contentOffset = CGPointZero;
    
    self.imageView.backgroundColor = self.imageView.image ? [UIColor blackColor] : [UIColor lightGrayColor];
    self.imageView.contentMode = model.contentMode;
    self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.imageView.layer.position = CGPointMake(CGRectGetMidX(model.pictureFrame), CGRectGetMidY(model.pictureFrame));
    self.imageView.layer.transform = CATransform3DIdentity;
    self.imageView.layer.frame = model.pictureFrame;
    
    self.superVC.bgView.alpha = 1;
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

#pragma mark - 手势监听

- (void)dismiss:(UITapGestureRecognizer *)tapGR {
    self.isShowProgress = NO;
    self.progressLayer.hidden = YES;
    
    if (self.model.infoModel) {
        !self.singleClickBlock ? : self.singleClickBlock();
        return;
    }
    
    if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        } completion:^(BOOL finished) {
            !self.singleClickBlock ? : self.singleClickBlock();
        }];
    } else {
        !self.singleClickBlock ? : self.singleClickBlock();
    }
}

// 双击放大、还原
- (void)enlargeOrReturn:(UITapGestureRecognizer *)doubleTapGR {
    if (!self.progressLayer.hidden) return;
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [doubleTapGR locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.scrollView.frame.size.width / newZoomScale;
        CGFloat ysize = self.scrollView.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize / 2, touchPoint.y - ysize / 2, xsize, ysize) animated:YES];
    }
}

- (void)pan:(UIPanGestureRecognizer *)panGR {
    if (!self.progressLayer.hidden || self.isSetingImage) return;
    if (self.scrollView.contentOffset.y > 0) return;
    
    CGPoint velocity = [panGR velocityInView:self.imageView];
    CGPoint translation = [panGR translationInView:self.imageView];
    [panGR setTranslation:CGPointZero inView:self.imageView];
    
    CGFloat diffMargin = self.screenCenterY * 0.5;
    
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.recover = YES;
        self.canPan = YES;
        
        self.superVC.bgView.alpha = 1;
        
        // 判断是否为垂直方向（fabs：求绝对值）
        BOOL isVerticalGesture = (fabs(velocity.y) > fabs(velocity.x)) && velocity.y > 0;
        
        if (isVerticalGesture) {
            self.superVC.collectionView.scrollEnabled = NO;
            self.scrollView.panGestureRecognizer.enabled = NO;
            self.scrollView.pinchGestureRecognizer.enabled = NO;
        } else {
            self.canPan = NO;
            return;
        }
        
        self.imageViewCenterY = self.imageView.frame.origin.y + self.imageView.frame.size.height * 0.5;
        if (self.imageViewCenterY > self.screenCenterY) self.imageViewCenterY = self.screenCenterY;
        
        self.panBeginImgViewFrame = self.imageView.frame;
        self.panBeginImgViewPosition = self.imageView.layer.position;
        self.panBeginImgViewTransform = self.imageView.layer.transform;
        
        // 要先设置position再设置anchorPoint，不然会瞬间挪动
        CGPoint point = [panGR locationInView:self.imageView];
        CGPoint position = CGPointMake(point.x + self.imageView.frame.origin.x, point.y + self.imageView.frame.origin.y);
        CGPoint anchorPoint = CGPointMake(point.x / self.imageView.frame.size.width, point.y / self.imageView.frame.size.height);
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.imageView.layer.position = position;
        self.imageView.layer.anchorPoint = anchorPoint;
        if (self.imageView.image) self.imageView.backgroundColor = UIColor.clearColor;
        [CATransaction commit];
        
        if (self.model.infoModel && self.beginPanBlock) self.beginPanBlock();
    }
    
    if (panGR.state == UIGestureRecognizerStateChanged) {
        
        // 如果不能滚动，或者collectionView正在滚动，就不要进行形变操作
        if (!self.canPan || self.superVC.collectionView.isDragging) return;
        
        self.superVC.collectionView.scrollEnabled = NO;
        self.scrollView.panGestureRecognizer.enabled = NO;
        self.scrollView.pinchGestureRecognizer.enabled = NO;
        
        self.imageViewCenterY += translation.y;
        CGFloat sizeScale = 1;
        CGFloat bgAlpha = 1;
        CGFloat x = 0;
        CGFloat y = 0;
        if (self.imageViewCenterY > self.screenCenterY) {
            CGFloat currMargin = self.imageViewCenterY - self.screenCenterY;
            self.recover = currMargin <= diffMargin;
            CGFloat scale = currMargin / (diffMargin * 2);
            if (scale > 1) scale = 1;
            bgAlpha = 1 - scale;
            // 1 - 0.4 = 0.6 为最大缩放比例
            sizeScale = (self.panBeginImgViewFrame.size.width * (1 - scale * 0.4)) / self.imageView.frame.size.width;
        } else {
            self.recover = YES;
        }
        
        CATransform3D transform = self.imageView.layer.transform;
        transform = CATransform3DScale(transform, sizeScale, sizeScale, 1); // 缩放
        transform = CATransform3DTranslate(transform, translation.x - x, translation.y - y, 0); // 位置
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.superVC.bgView.alpha = bgAlpha; // 背景透明度
        self.imageView.layer.transform = transform;
        [CATransaction commit];
    }
    
    if (panGR.state == UIGestureRecognizerStateEnded ||
        panGR.state == UIGestureRecognizerStateCancelled ||
        panGR.state == UIGestureRecognizerStateFailed) {
        
        if (!self.canPan) {
            self.superVC.collectionView.scrollEnabled = YES;
            self.scrollView.panGestureRecognizer.enabled = YES;
            self.scrollView.pinchGestureRecognizer.enabled = YES;
            return;
        }
        
//        JPLog(@"结束时的速度 %@", NSStringFromCGPoint(velocity));
        BOOL isDismiss = (velocity.y > 1000 || !self.recover);
        
        CGRect frame = self.imageView.frame;
        if (isDismiss) {
            CGPoint offset = self.scrollView.contentOffset;
            frame.origin.x -= offset.x;
            frame.origin.y -= offset.y;
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
            self.scrollView.contentOffset = CGPointZero;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.imageView.layer.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        self.imageView.layer.transform = CATransform3DIdentity;
        self.imageView.layer.frame = frame;
        [CATransaction commit];
        
        if (isDismiss) {
            [self.superVC dismiss];
        } else {
            [UIView animateWithDuration:0.3 delay:0 options:kNilOptions animations:^{
                self.imageView.layer.frame = self.panBeginImgViewFrame;
                self.superVC.bgView.alpha = 1;
            } completion:^(BOOL finished) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                self.imageView.layer.frame = self.model.pictureFrame;
                self.imageView.layer.transform = self.panBeginImgViewTransform;
                self.imageView.layer.position = self.panBeginImgViewPosition;
                self.imageView.backgroundColor = self.imageView.image ? [UIColor blackColor] : [UIColor lightGrayColor];
                [CATransaction commit];
                
                // cell已经结束拖动，让collectionView能滚动
                self.superVC.collectionView.scrollEnabled = YES;
                self.scrollView.panGestureRecognizer.enabled = YES;
                self.scrollView.pinchGestureRecognizer.enabled = YES;
            }];
            if (self.model.infoModel && self.endPanBlock) self.endPanBlock();
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

// 让图片居中（当图片不是在scrollView的顶部，缩放时会在上方留下一截）
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView {
    CGFloat boundsW = aScrollView.bounds.size.width;
    CGFloat boundsH = aScrollView.bounds.size.height;
    CGFloat contentW = aScrollView.contentSize.width;
    CGFloat contentH = aScrollView.contentSize.height;
    CGFloat offsetX = (boundsW > contentW) ? (boundsW - contentW) * 0.5 : 0.0;
    CGFloat offsetY = (boundsH > contentH) ? (boundsH - contentH) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(contentW * 0.5 + offsetX, contentH * 0.5 + offsetY);
}

@end


@interface JPBrowseImageProgressLayer ()
@property (nonatomic, weak) CALayer *bgLayer;
@property (nonatomic, weak) CAShapeLayer *progressLayer;
@end

@implementation JPBrowseImageProgressLayer

+ (instancetype)browseImageProgressLayer {
    
    JPBrowseImageProgressLayer *bipLayer = [JPBrowseImageProgressLayer layer];
    bipLayer.frame = [UIScreen mainScreen].bounds;
    bipLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    
    CGFloat w = 40;
    CGFloat h = 40;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - w) * 0.5;
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - h) * 0.5;
    
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
    progressLayer.fillColor = [UIColor clearColor].CGColor;
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


//    self.livePHView.frame = self.imageView.frame;

//    if (model.photoObject) {
//        if (!self.progressLayer.hidden) self.progressLayer.hidden = YES;
//        self.imageView.image = nil;
//
//        JPPhotoObject *photoObject = model.photoObject;
//        CGFloat scale = SCREEN_SCALE;
//        CGSize size = CGSizeMake(photoObject.bigPhotoSize.width * scale, photoObject.bigPhotoSize.height * scale);
//
//        __weak typeof(self) weakSelf = self;
//
////        if (photoObject.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
////            JPLog(@"是live照片");
////
////            self.livePHView.hidden = NO;
////
////            [[PHImageManager defaultManager] requestLivePhotoForAsset:photoObject.asset targetSize:size contentMode:0 options:0 resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
////
//////                self.livePHView.livePhoto = livePhoto;
//////                [self.livePHView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
////
////                livePhoto re
////
////
////            }];
////
//////            return;
////        }
//
////        self.livePHView.hidden = YES;
//
//        [[JPPhotoTool sharedInstance] requestOriginalPhotoForAsset:photoObject.asset targetSize:size isFastMode:YES isShouldFixOrientation:NO resultHandler:^(PHAsset *requestAsset, UIImage *result, NSDictionary *info) {
//            if (requestAsset == weakSelf.model.photoObject.asset) {
//                weakSelf.imageView.image = result;
//                weakSelf.isSetingImage = NO;
//                weakSelf.isSetImageSuccess = YES;
//            } else {
//                JPLog(@"不一样？");
//            }
//        }];
//
//        return;
//    }

//    self.livePHView.hidden = YES;
