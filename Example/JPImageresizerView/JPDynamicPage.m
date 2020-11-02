//
//  JPDynamicPage.m
//  JPDynamicPage
//
//  Created by guanning on 2017/9/9.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPDynamicPage.h"

#define JPDPAnimationKey @"JPPositionAnimate"

@interface JPDynamicPage ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) CALayer *contentLayer;
@end

@implementation JPDynamicPage
{
    NSInteger _rowTotal;
    NSInteger _bigColTotal;
    NSInteger _smallColTotal;
    NSInteger _targetResetIndex;
    
    CGFloat _screenW;
    CGFloat _screenH;
    
    CGFloat _bigIconW; // 164.0
    CGFloat _bigIconH; // 110.0
    
    CGFloat _smallIconW; // 66.0
    CGFloat _smallIconH; // 44.0
    
    CGFloat _smallIconMargin; // 20.0
    CGFloat _bigIconMargin; // (SmallIconMargin * 3 + SmallIconW * 2)
    
    CGFloat _diffX;
    CGFloat _diffY;
}

+ (instancetype)dynamicPage {
    JPDynamicPage *dp = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    return dp;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:@"radial-gradien-bg"];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        [self setupBase];
        
        CGFloat w = _bigIconW * 2 + _smallIconW * 4 + 5 * _smallIconMargin;
        CGFloat h = _bigIconH * _rowTotal;
        CGSize size = CGSizeMake(w, h);
        CGRect frame = CGRectMake(0, _screenH - size.height, size.width, size.height);
        
        CALayer *contentLayer = [self setupContentLayerWithFrame:frame];
        [self.layer addSublayer:contentLayer];
        self.contentLayer = contentLayer;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)updateFrame:(CGRect)frame {
    self.frame = frame;
    
    self.imageView.frame = frame;
    [self setupBase];
    
    CGFloat w = _bigIconW * 2 + _smallIconW * 4 + 5 * _smallIconMargin;
    CGFloat h = _bigIconH * _rowTotal;
    CGSize size = CGSizeMake(w, h);
    self.contentLayer.frame = CGRectMake(0, _screenH - size.height, size.width, size.height);
}

- (void)enterForeground {
    [self startAnimation];
}

- (void)dealloc {
    [self.contentLayer removeAllAnimations];
}

- (void)setupBase {
    _duration = 30.0; // 30.0
    _state = JPDynamicPageIdle;
    
    _rowTotal = JPis_iphoneX ? 15 : 13; // 13，适配X->15
    _bigColTotal = 6; // 3
    _smallColTotal = 10; // 5
    _targetResetIndex = ((_rowTotal - 1) - 5) * _bigColTotal + 1;
    
    _screenW = [UIScreen mainScreen].bounds.size.width;
    _screenH = [UIScreen mainScreen].bounds.size.height;
    
    _bigIconW = 164.0; // 164.0
    _bigIconH = 110.0; // 110.0
    
    _smallIconW = 66.0; // 66.0
    _smallIconH = 44.0; // 44.0
    
    _smallIconMargin = 20.0; // 20.0
    _bigIconMargin = _smallIconMargin * 3 + _smallIconW * 2;
}

- (CALayer *)setupContentLayerWithFrame:(CGRect)frame {
    
    CALayer *contentLayer = [CALayer layer];
    contentLayer.frame = frame;
    
    [self setupBigLogoLayersOnContentLayer:contentLayer];
    [self setupSmallLogoLayersOnContentLayer:contentLayer];
    
    return contentLayer;
}

- (void)setupBigLogoLayersOnContentLayer:(CALayer *)contentLayer {
    
    NSInteger col = _bigColTotal;
    NSInteger row = _rowTotal;
    NSInteger count = col * row;
    
    CGFloat px = 0;
    CGFloat py = 0;
    
    NSString *text = @"";
    UIColor *textColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    UIFont *font = [UIFont fontWithName:@"shape" size:164];
    
    BOOL isOdd = NO;
    for (NSInteger i = 0; i < count; i++) {
        NSInteger currCol = i % col;
        NSInteger currRow = i / col;
        
        py = currRow * _bigIconH + _bigIconH * 0.5;
        
        isOdd = currRow % 2 == 0;
        
        px = currCol * (_bigIconMargin + _bigIconW) + _bigIconW * 0.5;
        if (isOdd) {
            px += _bigIconMargin - _smallIconMargin;
        }
        
        CATextLayer *textLayer = [self textLayerWithText:text textColor:textColor font:font];
        textLayer.bounds = CGRectMake(0, 30, _bigIconW, _bigIconH); // y 30
        textLayer.position = CGPointMake(px, py);
        [contentLayer addSublayer:textLayer];
        
        // 标识的那个
        if (i == _targetResetIndex) {
            if (_rowTotal % 2 == 0) {
                CGRect screenFrame = CGRectMake(0, contentLayer.frame.size.height - _screenH, _screenW, _screenH);
                CGRect intersectionF =  CGRectIntersection(screenFrame,  textLayer.frame);
                _diffX = intersectionF.size.width;
                _diffY = intersectionF.size.height;
            } else {
                _diffX = _screenW - textLayer.frame.origin.x;
                _diffY = fabs((contentLayer.frame.size.height - textLayer.frame.origin.y) - _screenH);
            }
            
            CGRect frame = [textLayer convertRect:textLayer.bounds toLayer:self.layer];
            if (frame.origin.y < 0) {
                _diffY = -_diffY;
            }
        }
        
        textLayer.transform = CATransform3DMakeRotation(-M_PI_2 * 0.5, 0, 0, 1);
    }
}

- (void)setupSmallLogoLayersOnContentLayer:(CALayer *)contentLayer {
    NSInteger col = _smallColTotal;
    NSInteger row = _rowTotal;
    NSInteger count = col * row;
    
    CGFloat px = 0;
    CGFloat py = 0;
    
    NSString *text = @"";
    UIColor *textColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    UIFont *font = [UIFont fontWithName:@"shape" size:66];
    
    for (NSInteger i = 0; i < count; i++) {
        NSInteger currCol = i % col;
        NSInteger currRow = i / col;
        
        NSInteger col2 = currCol / 2;
        
        px = _smallIconW * 0.5 + (_smallIconW + _smallIconMargin) * currCol + col2 * (_bigIconW + _smallIconMargin);
        
        if (currRow % 2 > 0) {
            px += _bigIconW + _smallIconMargin;
        }
        
        py = currRow * _bigIconH + _bigIconH * 0.5;
        
        if (currCol % 2 > 0) {
            py -= _smallIconH * 0.25;
            px += _smallIconW * 0.15;
        } else {
            py += _smallIconH * 0.25;
            px -= _smallIconW * 0.15;
        }
        
        CATextLayer *textLayer = [self textLayerWithText:text textColor:textColor font:font];
        textLayer.bounds = CGRectMake(0, 12.5, _smallIconW, _smallIconH); // y 12.5
        textLayer.position = CGPointMake(px, py);
        textLayer.transform = CATransform3DMakeRotation(-M_PI_2 * 0.5, 0, 0, 1);
        [contentLayer addSublayer:textLayer];
    }
}

- (CATextLayer *)textLayerWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font {
    //create a text layer
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.foregroundColor = textColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    //set layer font
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    textLayer.string = text;
    return textLayer;
}

- (void)startAnimation {
    [self stopAnimation];
    
    CGPoint position = self.contentLayer.position;
    position.x = position.x - _screenW + _diffX;
    position.y = position.y + _screenH - _diffY;
    
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"position";
    anim.toValue = [NSValue valueWithCGPoint:position];
    anim.duration = self.duration;
//    anim.beginTime = CACurrentMediaTime();
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.repeatCount = NSIntegerMax;
    [self.contentLayer addAnimation:anim forKey:JPDPAnimationKey];
    
    self.state = JPDynamicPageAnimating;
    
    JPLog(@"动画开启");
}

- (void)stopAnimation {
    [self.contentLayer removeAllAnimations];
    if (self.state == JPDynamicPagePause) {
        self.contentLayer.speed = 1;
        self.contentLayer.timeOffset = 0;
        self.contentLayer.beginTime = 0.0;
    }
    self.state = JPDynamicPageIdle;
}

- (void)pauseAnimation {
    if (self.state == JPDynamicPageAnimating) {
        self.state = JPDynamicPagePause;
        CFTimeInterval pausedTime = [self.contentLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.contentLayer.speed = 0.0;
        self.contentLayer.timeOffset = pausedTime;
    }
}

- (void)resumeAnimation {
    if (self.state == JPDynamicPagePause) {
        self.state = JPDynamicPageAnimating;
        CFTimeInterval pausedTime = [self.contentLayer timeOffset];
        self.contentLayer.speed = 1.0;
        self.contentLayer.timeOffset = 0.0;
        self.contentLayer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self.contentLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.contentLayer.beginTime = timeSincePause;
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    if (_duration == duration) return;
    _duration = duration;
    
    if (self.state == JPDynamicPageAnimating ||
        self.state == JPDynamicPagePause) {
        [self pauseAnimation];
        
        CGPoint currPosition = self.contentLayer.presentationLayer.position;
        
        [self.contentLayer removeAnimationForKey:JPDPAnimationKey];
        [self.contentLayer setTimeOffset:0];
        self.contentLayer.speed = 1;
        
        CGPoint position = self.contentLayer.position;
        position.x = position.x - _screenW + _diffX;
        position.y = position.y + _screenH - _diffY;
        
        CABasicAnimation *anim = [CABasicAnimation animation];
        anim.keyPath = @"position";
        anim.fromValue = [NSValue valueWithCGPoint:currPosition];
        anim.toValue = [NSValue valueWithCGPoint:position];
        anim.duration = duration;
        anim.beginTime = CACurrentMediaTime();
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        anim.repeatCount = MAXFLOAT;
        [self.contentLayer addAnimation:anim forKey:JPDPAnimationKey];
        self.state = JPDynamicPageAnimating;
    }
}

@end
