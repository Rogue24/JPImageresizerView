//
//  LittleRedBookViewController.m
//  JPImageresizerView_Example
//
//  Created by aa on 2020/12/14.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "LittleRedBookViewController.h"
#import "JPPreviewViewController.h"

@interface LittleRedBookViewController () <UIScrollViewDelegate>
@property (nonatomic, assign) CGRect baseFrame;
@property (nonatomic, assign) CGPoint baseCenter;
@property (nonatomic, assign) UIEdgeInsets baseInsets;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *contentView;

@property (nonatomic, strong) UIView *boardView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, assign) CGFloat maxVerInset;
@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat maxRadian;
@property (nonatomic, assign) CGRect maxFrame;

@property (nonatomic, assign) CGFloat radian;
@end

@implementation LittleRedBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = JPRandomColor;
    
    UIButton *cropBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cropBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [cropBtn setTitle:@"裁剪" forState:UIControlStateNormal];
    [cropBtn addTarget:self action:@selector(__crop) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cropBtn];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Girl1.jpg" ofType:nil]];
    
    CGFloat w = 200;
    CGFloat h = w * (image.size.height / image.size.width);
    CGFloat x = JPHalfOfDiff(JPPortraitScreenWidth, w);
    CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight - JPNavTopMargin - JPDiffTabBarH, h);
    self.baseFrame = CGRectMake(x, y, w, h);
    self.baseCenter = CGPointMake(CGRectGetMidX(self.baseFrame), CGRectGetMidY(self.baseFrame));
    self.baseInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.baseFrame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = JPRandomColor;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.maximumZoomScale = 999;
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.contentView.backgroundColor = JPRandomColor;
    self.contentView.alpha = 0.7;
    self.contentView.userInteractionEnabled = NO;
    self.contentView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentView.clipsToBounds = YES;
    self.contentView.image = image;
    [self.scrollView addSubview:self.contentView];
    
    self.boardView = [[UIView alloc] initWithFrame:self.baseFrame];
    self.boardView.backgroundColor = JPRandomColor;
    self.boardView.alpha = 0.7;
    self.boardView.userInteractionEnabled = NO;
    [self.view addSubview:self.boardView];
    
    self.scrollView.contentSize = self.baseFrame.size;
    
    
    CGRect baseFrame = CGRectMake(0, 0, self.baseFrame.size.width, self.baseFrame.size.height);
    CGFloat maxRadian = atan(baseFrame.size.width / baseFrame.size.height);
    CGFloat maxSide = cos(maxRadian) * baseFrame.size.width * 2;
    
    JPLog(@"多少度 %.1lf", JPRadian2Angle(maxRadian));
    
    CALayer *line1 = [CALayer layer];
    line1.frame = CGRectMake(0, 0, maxSide * 0.5, 1);
    line1.backgroundColor = JPRandomColor.CGColor;
    line1.anchorPoint = CGPointMake(0, 0);
    line1.position = CGPointMake(0, self.boardView.jp_height);
    
    CALayer *line2 = [CALayer layer];
    line2.frame = CGRectMake(0, 0, maxSide * 0.5, 1);
    line2.backgroundColor = JPRandomColor.CGColor;
    line2.anchorPoint = CGPointMake(1, 1);
    line2.position = CGPointMake(self.boardView.jp_width, 0);
    
    CALayer *line3 = [CALayer layer];
    line3.frame = CGRectMake(0, 0, 1, sqrt(baseFrame.size.width * baseFrame.size.width + baseFrame.size.height * baseFrame.size.height));
    line3.backgroundColor = JPRandomColor.CGColor;
    line3.position = CGPointMake(self.boardView.jp_width * 0.5, self.boardView.jp_height * 0.5);
    
    
    [self.boardView.layer addSublayer:line1];
    [self.boardView.layer addSublayer:line2];
    [self.boardView.layer addSublayer:line3];
    
    line1.transform = CATransform3DMakeRotation(-maxRadian, 0, 0, 1);
    line2.transform = CATransform3DMakeRotation(-maxRadian, 0, 0, 1);
    line3.transform = CATransform3DMakeRotation(-maxRadian, 0, 0, 1);
    
    self.maxRadian = M_PI_2 * 0.5;// atan(baseFrame.size.height / baseFrame.size.width);
    
//    CGAffineTransform transform = CGAffineTransformMakeRotation(self.maxRadian);
//
//    self.maxFrame = CGRectApplyAffineTransform(baseFrame, transform);
//    self.maxScale = self.maxFrame.size.width / baseFrame.size.width;
//
//
//    CGFloat maxSide1 = baseFrame.size.width * sqrt(2);
//    CGFloat maxSide2 = (baseFrame.size.height - baseFrame.size.width) / sqrt(2);
//
//
//    CGFloat maxHeight = baseFrame.size.height * self.maxScale;
//
//    self.maxVerInset = (maxHeight - (maxSide1 + maxSide2)) * 0.5 / self.maxScale;
    
    
}

- (IBAction)valueDidChanged:(UISlider *)sender {
    sender.layer.zPosition = 1;
    JPLog(@"%lf", sender.value);
    CGFloat value = sender.value;
    
    CGRect baseFrame = CGRectMake(0, 0, self.baseFrame.size.width, self.baseFrame.size.height);
    
    
    CGFloat radian = self.maxRadian * value;
    self.radian = radian;
    
    JPLog(@"多少度 %.1lf", JPRadian2Angle(radian));
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
    
    CGRect frame = CGRectApplyAffineTransform(baseFrame, transform);
    
    CGFloat scale = frame.size.width / baseFrame.size.width;
    transform = CGAffineTransformScale(transform, scale, scale);
    
    
    CGFloat aaa = fabs(radian);
    CGFloat s1 = cos(aaa) * baseFrame.size.height;
    CGFloat s2 = sin(aaa) * baseFrame.size.width;
    CGFloat verInset = (baseFrame.size.height * scale - (s1 + s2)) * 0.5 / scale;
    
    self.scrollView.transform = transform;
    self.scrollView.contentInset = UIEdgeInsetsMake(verInset, 0, verInset, 0);
}

- (void)__crop {
    UIImage *image = self.contentView.image;
    
    CGImageRef imageRef = image.CGImage;
    
    CGFloat compressScale = 1;
    
    // 是否带透明度
    BOOL hasAlpha = NO;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) hasAlpha = YES;
    
    // 获取裁剪尺寸和裁剪区域
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef) * compressScale, CGImageGetHeight(imageRef) * compressScale);
    
//    CGAffineTransform transform = JPConfirmTransform(imageSize, direction, isVerMirror, isHorMirror, YES);
//    CGPoint translate = JPConfirmTranslate(cropFrame, imageSize, direction, isVerMirror, isHorMirror, YES);
//    transform = CGAffineTransformTranslate(transform, translate.x, translate.y);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, colorSpace, bitmapInfo);
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    
    CGAffineTransform t = self.scrollView.transform;
    CGFloat scale = sqrt(t.a * t.a + t.c * t.c);
    scale *= self.scrollView.zoomScale;
    
    CGPoint point1 = CGPointMake(self.boardView.jp_x, self.boardView.jp_maxY);
    point1 = [self.contentView convertPoint:point1 fromView:self.boardView];
    if (point1.x < 0) {
        point1.x = 0;
    }
    point1.y = self.contentView.jp_height - point1.y;
    JPLog(@"point1 %@", NSStringFromCGPoint(point1));
    
    CGPoint point2 = CGPointMake(0, self.boardView.jp_height);
    point2 = [self.contentView convertPoint:point2 fromView:self.boardView];
    if (point2.x < 0) {
        point2.x = 0;
    }
    point2.y = self.contentView.bounds.size.height - point2.y;
    JPLog(@"point2 %@", NSStringFromCGPoint(point2));
    
    CGFloat iScale = 1;// imageSize.height / self.contentView.frame.size.height;
    CGPoint translate = CGPointMake(-point2.x * iScale, -point2.y * iScale);
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    transform = CGAffineTransformTranslate(transform, translate.x, translate.y);
    transform = CGAffineTransformRotate(transform, -self.radian);
    
//    transform = CGAffineTransformScale(transform, scale, scale);
    
//    transform = CGAffineTransformTranslate(transform, -point.x, -point.y);
//    transform = CGAffineTransformTranslate(transform, 100, 100);
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, (CGRect){CGPointZero, imageSize}, imageRef);
    CGImageRef newImageRef =  CGBitmapContextCreateImage(context);
    
    UIImage *finalImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    JPPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JPPreviewViewController"];
    vc.image = finalImage;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showInfo {
    JPLog(@"contentSize %@", NSStringFromCGSize(self.scrollView.contentSize));
    JPLog(@"contentInset %@", NSStringFromUIEdgeInsets(self.scrollView.contentInset));
    JPLog(@"contentOffset %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    JPLog(@"zoomScale %lf", self.scrollView.zoomScale);
    JPLog(@"-----------");
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showInfo];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self.frameView endedImageresizer];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
//    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    [self.frameView endedImageresizer];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self showInfo];
}

@end
