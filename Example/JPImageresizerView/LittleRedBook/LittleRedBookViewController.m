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
@property (nonatomic, assign) CGRect boardFrame;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) CGPoint baseCenter;
@property (nonatomic, assign) CGFloat baseHorInsets;
@property (nonatomic, assign) CGFloat baseVerInsets;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *contentView;

@property (nonatomic, strong) UIView *boardView;
@property (nonatomic, assign) CGFloat maxRadian;
@property (nonatomic, assign) CGFloat radian;
@end

@implementation LittleRedBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = JPRandomColor;
    self.view.clipsToBounds = YES;
    
    UIButton *cropBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cropBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [cropBtn setTitle:@"裁剪" forState:UIControlStateNormal];
    [cropBtn addTarget:self action:@selector(__crop) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cropBtn];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Girl1.jpg" ofType:nil]];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Flowers.jpg" ofType:nil]];
    
    CGFloat w = 200;
    CGFloat h = w;// * (3.0 / 4.0);
    CGFloat x = JPHalfOfDiff(JPPortraitScreenWidth, w);
    CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight - JPNavTopMargin - JPDiffTabBarH, h);
    self.boardFrame = CGRectMake(x, y, w, h);
    
    if (image.size.height > image.size.width) {
        h = w * (image.size.height / image.size.width);
    } else {
        w = h * (image.size.width / image.size.height);
    }
    
    x = JPHalfOfDiff(JPPortraitScreenWidth, w);;
    y = JPHalfOfDiff(JPPortraitScreenHeight - JPNavTopMargin - JPDiffTabBarH, h);;
    self.contentFrame = CGRectMake(x, y, w, h);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentFrame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = JPRandomColor;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.maximumZoomScale = 999;
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentFrame.size.width, self.contentFrame.size.height)];
    self.contentView.backgroundColor = JPRandomColor;
    self.contentView.alpha = 0.7;
    self.contentView.userInteractionEnabled = NO;
    self.contentView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentView.clipsToBounds = YES;
    self.contentView.image = image;
    [self.scrollView addSubview:self.contentView];
    
    self.boardView = [[UIView alloc] initWithFrame:self.boardFrame];
    self.boardView.backgroundColor = JPRandomColor;
    self.boardView.alpha = 0.7;
    self.boardView.userInteractionEnabled = NO;
    [self.view addSubview:self.boardView];
    
    
    
    
    CGRect baseFrame = CGRectMake(0, 0, self.boardFrame.size.width, self.boardFrame.size.height);
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
    
    self.maxRadian = M_PI_2 * 0.5;
    
    
    self.baseHorInsets = JPHalfOfDiff(self.contentFrame.size.width, self.boardFrame.size.width);
    self.baseVerInsets = JPHalfOfDiff(self.contentFrame.size.height, self.boardFrame.size.height);
    
    self.scrollView.contentSize = self.contentFrame.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.baseVerInsets, self.baseHorInsets, self.baseVerInsets, self.baseHorInsets);
}

- (IBAction)valueDidChanged:(UISlider *)sender {
    sender.layer.zPosition = 1;
    JPLog(@"%lf", sender.value);
    CGFloat value = sender.value;
    
    CGRect baseFrame = CGRectMake(0, 0, self.boardFrame.size.width, self.boardFrame.size.height);
    
    
    CGFloat radian = self.maxRadian * value;
    self.radian = radian;
    
    JPLog(@"多少度 %.1lf", JPRadian2Angle(radian));
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
    
    CGRect frame = CGRectApplyAffineTransform(baseFrame, transform);
    
    CGFloat scale = frame.size.width / baseFrame.size.width;
    transform = CGAffineTransformScale(transform, scale, scale);
    
    
    radian = fabs(radian);
    CGFloat s1 = cos(radian) * baseFrame.size.height;
    CGFloat s2 = sin(radian) * baseFrame.size.width;
    CGFloat verInset = (baseFrame.size.height * scale - (s1 + s2)) * 0.5 / scale + self.baseVerInsets;
    
    self.scrollView.transform = transform;
    self.scrollView.contentInset = UIEdgeInsetsMake(verInset, self.baseHorInsets, verInset, self.baseHorInsets);
}

- (void)__crop {
    UIImage *image = self.contentView.image;
    
    CGImageRef imageRef = image.CGImage;
    
    CGFloat compressScale = 1;
    
    CGAffineTransform t = self.scrollView.transform;
    CGFloat scale = sqrt(t.a * t.a + t.c * t.c);
    scale *= self.scrollView.zoomScale;
    
    // 是否带透明度
    BOOL hasAlpha = NO;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) hasAlpha = YES;
    
    // 获取裁剪尺寸和裁剪区域
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef) * compressScale, CGImageGetHeight(imageRef) * compressScale);
    
    CGSize rendSize;
    if (imageSize.width < imageSize.height) {
        rendSize = CGSizeMake(imageSize.width, imageSize.width * (self.boardFrame.size.height / self.boardFrame.size.width));
    } else {
        rendSize = CGSizeMake(imageSize.height * (self.boardFrame.size.width / self.boardFrame.size.height), imageSize.height);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, rendSize.width, rendSize.height, 8, 0, colorSpace, bitmapInfo);
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextSetFillColorWithColor(context, JPRandomColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, rendSize.width, rendSize.height));
    
    
    
    CGFloat iScale = imageSize.height / (self.contentFrame.size.height * scale);
    
    CGPoint translate = [self.boardView convertPoint:CGPointMake(0, self.boardView.jp_height) toView:self.contentView];
    translate.y = self.contentView.bounds.size.height - translate.y;
    translate.x *= scale;
    translate.y *= scale;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    transform = CGAffineTransformRotate(transform, -self.radian);
    transform = CGAffineTransformTranslate(transform, -translate.x * iScale, -translate.y * iScale);
    
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
