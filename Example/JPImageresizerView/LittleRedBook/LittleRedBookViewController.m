//
//  LittleRedBookViewController.m
//  JPImageresizerView_Example
//
//  Created by aa on 2020/12/14.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "LittleRedBookViewController.h"

@interface LittleRedBookViewController () <UIScrollViewDelegate>
@property (nonatomic, assign) CGRect baseFrame;
@property (nonatomic, assign) CGPoint baseCenter;
@property (nonatomic, assign) UIEdgeInsets baseInsets;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *boardView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, assign) CGFloat maxVerInset;
@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat maxRadian;
@property (nonatomic, assign) CGRect maxFrame;
@end

@implementation LittleRedBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = JPRandomColor;
    
    CGFloat w = 200;
    CGFloat h = w * ((JPPortraitScreenHeight - JPNavTopMargin - JPDiffTabBarH) / JPPortraitScreenWidth);
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
    
    self.contentView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.contentView.backgroundColor = JPRandomColor;
    self.contentView.alpha = 0.7;
    self.contentView.userInteractionEnabled = NO;
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
    
    self.maxRadian = atan(baseFrame.size.height / baseFrame.size.width);
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(self.maxRadian);
    
    self.maxFrame = CGRectApplyAffineTransform(baseFrame, transform);
    self.maxScale = self.maxFrame.size.width / baseFrame.size.width;
    
    
    CGFloat maxHeight = baseFrame.size.height * self.maxScale;
    
    self.maxVerInset = (maxHeight - maxSide) * 0.5 / self.maxScale;
    
    
}

- (IBAction)valueDidChanged:(UISlider *)sender {
    JPLog(@"%lf", sender.value);
    CGFloat value = sender.value;
    
    CGRect baseFrame = CGRectMake(0, 0, self.baseFrame.size.width, self.baseFrame.size.height);
    
    
    CGFloat radian = M_PI * 2 * value;
    
    JPLog(@"多少度 %.1lf", JPRadian2Angle(radian));
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
    
    CGRect frame = CGRectApplyAffineTransform(baseFrame, transform);
    
    CGFloat scale = frame.size.width / baseFrame.size.width;
    transform = CGAffineTransformScale(transform, scale, scale);
    
    CGFloat sss = (scale - 1) / (self.maxScale - 1);
    CGFloat verInset = self.maxVerInset * sss;
    
    JPLog(@"比例 %lf", sss);
    
    self.scrollView.transform = transform;
    self.scrollView.contentInset = UIEdgeInsetsMake(verInset, 0, verInset, 0);
    
    
    return;
    
    
    
    
    
    frame = CGRectMake(0, 0, frame.size.width * self.scrollView.zoomScale, frame.size.height * self.scrollView.zoomScale);
    
    
    
    self.contentView.frame = frame;
    
    
    
//    self.scrollView.zoomScale = scale;
//    self.scrollView.contentSize = frame.size;
//    self.scrollView.contentInset = UIEdgeInsetsMake(verInset, horInset, verInset, horInset);
//
//    self.rotateView.transform = transform;
//    self.rotateView.center = CGPointMake(self.contentView.frame.size.width / self.scrollView.zoomScale * 0.5, self.contentView.frame.size.height / self.scrollView.zoomScale * 0.5);
    
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
