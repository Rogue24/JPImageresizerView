//
//  JPImageresizerSlider.m
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/8.
//

#import "JPImageresizerSlider.h"
#import "CALayer+JPImageresizer.h"

@interface JPImageresizerSlider ()
@property (nonatomic, weak) UISlider *slider;
@property (nonatomic, weak) UILabel *currentTimeLabel;
@property (nonatomic, weak) UILabel *leftTimeLabel;

@property (nonatomic, weak) UIView *thumb;
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) CAShapeLayer *thumbLayer;

@property (nonatomic, assign) BOOL sliding;
@property (nonatomic, assign) BOOL leftUp;
@property (nonatomic, assign) BOOL rightUp;
@end

@implementation JPImageresizerSlider
{
    CGFloat _baseWH;
    CGFloat _bigWH;
    CGFloat _halfBaseWH;
    CGFloat _halfBigWH;
    CGFloat _leftLabelW;
    CGFloat _rightLabelW;
    CGFloat _labelH;
    BOOL _isMoreThanOneHour;
    CGFloat _margin;
}

#pragma mark - 初始化

+ (CGFloat)viewHeight {
    return 34.0 + 20.0;
}

+ (instancetype)imageresizerSlider:(float)seconds second:(float)second {
    return [[self alloc] initWithSeconds:seconds second:second];
}

- (instancetype)initWithSeconds:(float)seconds second:(float)second {
    if (self = [super init]) {
        _baseWH = 8;
        _bigWH = 20;
        _halfBaseWH = _baseWH * 0.5;
        _halfBigWH = _bigWH * 0.5;
        _labelH = 12;
        _margin = 20;
        
        UISlider *slider = [[UISlider alloc] init];
        slider.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        slider.minimumTrackTintColor = UIColor.whiteColor;
        [slider addTarget:self action:@selector(sliderBegin) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(sliderDraging) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderEnd) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderEnd) forControlEvents:UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(sliderEnd) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:slider];
        self.slider = slider;
        
        UILabel *currentTimeLabel = [[UILabel alloc] init];
        currentTimeLabel.font = [UIFont systemFontOfSize:10];
        currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        currentTimeLabel.textColor = UIColor.whiteColor;
        currentTimeLabel.text = @"00:00";
        [self addSubview:currentTimeLabel];
        self.currentTimeLabel = currentTimeLabel;
        
        UILabel *leftTimeLabel = [[UILabel alloc] init];
        leftTimeLabel.font = [UIFont systemFontOfSize:10];
        leftTimeLabel.textAlignment = NSTextAlignmentCenter;
        leftTimeLabel.textColor = UIColor.whiteColor;
        leftTimeLabel.text = @"00:00";
        [self addSubview:leftTimeLabel];
        self.leftTimeLabel = leftTimeLabel;
        
        CGRect thumbBounds = CGRectMake(0, 0, _baseWH, _baseWH);
        
        UIGraphicsBeginImageContextWithOptions(thumbBounds.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColor.clearColor.CGColor);
        CGContextFillRect(context, thumbBounds);
        UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [slider setThumbImage:thumbImage forState:UIControlStateNormal];
        
        self.thumbView = [[UIView alloc] initWithFrame:thumbBounds];
        self.thumbView.userInteractionEnabled = NO;
        
        self.thumbLayer = [CAShapeLayer layer];
        self.thumbLayer.fillColor = UIColor.whiteColor.CGColor;
        self.thumbLayer.lineWidth = 0;
        self.thumbLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.thumbView.bounds].CGPath;
        [self.thumbView.layer addSublayer:self.thumbLayer];
        
        [self.slider layoutSubviews];
        [self.slider layoutIfNeeded];
        [self resetSeconds:seconds second:second];
    }
    return self;
}

#pragma mark - getter

- (UIView *)thumb {
    if (!_thumb && self.slider.subviews.count) {
        BOOL (^setupThumb)(UIView *view) = ^(UIView *view){
            if ([view isKindOfClass:UIImageView.class]) {
                self->_thumb = view;
                self.thumbView.center = view.center;
                [self.slider addSubview:self.thumbView];
                return YES;
            }
            return NO;
        };
        for (UIView *subview in self.slider.subviews) {
            if (@available(iOS 14.0, *)) {
                for (UIView *subSubview in subview.subviews) {
                    if (setupThumb(subSubview)) break;
                }
            } else {
                if (setupThumb(subview)) break;
            }
        }
    }
    return _thumb;
}

#pragma mark - 事件触发方法

- (void)sliderBegin {
    !self.sliderBeginBlock ? : self.sliderBeginBlock(self.slider.value, self.slider.maximumValue);
    self.sliding = YES;
}

- (void)sliderDraging {
    !self.sliderDragingBlock ? : self.sliderDragingBlock(self.slider.value, self.slider.maximumValue);
    self.sliding = YES;
}

- (void)sliderEnd {
    !self.sliderEndBlock ? : self.sliderEndBlock(self.slider.value, self.slider.maximumValue);
    self.sliding = NO;
}

#pragma mark - 监听私有属性

- (void)setSliding:(BOOL)sliding {
    [self __updateTimeLabel];
    
    CGPoint center = self.thumb.center;
    if (sliding) {
        if (self.thumb.center.x < _halfBigWH) {
            center.x = _halfBigWH;
        } else if (self.thumb.center.x > (self.frame.size.width - _halfBigWH)) {
            center.x = (self.frame.size.width - _halfBigWH);
        }
        self.thumbView.center = center;

        self.leftUp = (center.x - _halfBigWH) < self.currentTimeLabel.frame.size.width;
        self.rightUp = (center.x + _halfBigWH) > self.leftTimeLabel.frame.origin.x;
    } else {
        self.leftUp = NO;
        self.rightUp = NO;
    }
    
    if (_sliding == sliding) return;
    _sliding = sliding;
    
    CGFloat wh = sliding ? _bigWH : _baseWH;
    CGFloat xy = (_baseWH - wh) * 0.5;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(xy, xy, wh, wh)];
    [self.thumbLayer jpir_addBackwardsAnimationWithKeyPath:@"path" fromValue:(id)self.thumbLayer.path toValue:path timingFunctionName:kCAMediaTimingFunctionEaseIn duration:0.15];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.thumbLayer.path = path.CGPath;
    [CATransaction commit];
    
    if (!sliding) {
        [UIView animateWithDuration:0.15 animations:^{
            self.thumbView.center = center;
        }];
    }
}

- (void)setLeftUp:(BOOL)leftUp {
    if (_leftUp == leftUp) return;
    _leftUp = leftUp;
    [self __updateLabel:self.currentTimeLabel diffY:(leftUp ? 5 : 0)];
}

- (void)setRightUp:(BOOL)rightUp {
    if (_rightUp == rightUp) return;
    _rightUp = rightUp;
    [self __updateLabel:self.leftTimeLabel diffY:(rightUp ? 5 : 0)];
}

#pragma mark - 私有方法

- (void)__updateLabel:(UILabel *)label diffY:(CGFloat)diffY {
    CGRect frame = label.frame;
    frame.origin.y = self.slider.frame.origin.y - 5 - diffY;
    [UIView animateWithDuration:0.15 animations:^{
        label.frame = frame;
    }];
}

- (void)__updateTimeLabel {
    float currentTime = self.slider.value;
    NSInteger intCurrentTime = currentTime + 0.5;
    NSInteger currentMinute = (intCurrentTime / 60) % 60;
    NSInteger currentSecond = intCurrentTime % 60;
    
    float leftTime = self.slider.maximumValue - self.slider.value;
    NSInteger intLeftTime = leftTime + 0.5;
    NSInteger leftMinute = (intLeftTime / 60) % 60;
    NSInteger leftSecond = intLeftTime % 60;
    
    if (_isMoreThanOneHour) {
        NSInteger currentHour = intLeftTime / 3600;
        NSInteger leftHour = intLeftTime / 3600;
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", currentHour, currentMinute, currentSecond];
        self.leftTimeLabel.text = [NSString stringWithFormat:@"-%02zd:%02zd:%02zd", leftHour, leftMinute, leftSecond];
    } else {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", currentMinute, currentSecond];
        self.leftTimeLabel.text = [NSString stringWithFormat:@"-%02zd:%02zd", leftMinute, leftSecond];
    }
}

#pragma mark - 公开方法

- (void)resetSeconds:(float)seconds second:(float)second {
    _isMoreThanOneHour = ((NSInteger)(seconds + 0.5) / 3600) > 0;
    _leftLabelW = _isMoreThanOneHour ? 45 : 35;
    _rightLabelW = _leftLabelW + 5;
    
    self.slider.maximumValue = seconds;
    self.slider.minimumValue = 0;
    self.second = second;
}
- (float)seconds {
    return self.slider.maximumValue;
}

- (void)setSecond:(float)second {
    if (_sliding) return;
    
    [self.slider setValue:second animated:NO];
    [self __updateTimeLabel];
    
    if (!self.thumb) return;
    UIView *thumb = self.thumb;
    // _thumb.center跟UI显示上并不是同步刷新（.center会慢一些，应该是异步刷新的），把执行时机延后至该方法之后再执行（换一下线程处理）
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thumbView.center = thumb.center;
    });
}
- (float)second {
    return self.slider.value;
}

- (void)setImageresizerFrame:(CGRect)imageresizerFrame isRoundResize:(BOOL)isRoundResize {
    CGFloat margin = isRoundResize ? (imageresizerFrame.size.width / 5.0) : _margin;
    CGFloat x = imageresizerFrame.origin.x + margin;
    CGFloat w = imageresizerFrame.size.width - 2 * margin;
    CGFloat h = self.class.viewHeight;
    CGFloat y = imageresizerFrame.origin.y + imageresizerFrame.size.height - h - margin;
    self.frame = CGRectMake(x, y, w, h);
    
    h = self.slider.frame.size.height;
    x = 0;
    y = self.frame.size.height - h;
    self.slider.frame = CGRectMake(x, y, w, h);
    
    y = self.slider.frame.origin.y - 5;
    w = _leftLabelW;
    h = _labelH;
    self.currentTimeLabel.frame = CGRectMake(x, y, w, h);
    
    w = _rightLabelW;
    x = self.frame.size.width - w;
    self.leftTimeLabel.frame = CGRectMake(x, y, w, h);
    
    self.thumbView.center = self.thumb.center;
}

@end
