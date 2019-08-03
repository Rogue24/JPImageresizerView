//
//  NoDataView.m
//  Infinitee2.0
//
//  Created by guanning on 2016/12/26.
//  Copyright © 2016年 Infinitee. All rights reserved.
//

#import "NoDataView.h"

@interface NoDataView ()
@property (nonatomic, assign) BOOL isWholeCenter;
@property (nonatomic, weak) CALayer *iconShadow;
@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation NoDataView

+ (NoDataView *)noDataViewWithTitle:(NSString *)title onView:(UIView *)superView center:(CGPoint)center {
    return [self noDataViewWithTitle:title onView:superView center:center isWholeCenter:NO];
}

+ (NoDataView *)noDataViewWithTitle:(NSString *)title onView:(UIView *)superView center:(CGPoint)center isWholeCenter:(BOOL)isWholeCenter {
    NoDataView *noDataView = [[self alloc] initWithTitle:title isWholeCenter:isWholeCenter];
    noDataView.userInteractionEnabled = NO;
    noDataView.layer.opacity = 0;
    
    [superView addSubview:noDataView];
    noDataView.center = center;
    
    return noDataView;
}

- (instancetype)initWithTitle:(NSString *)title isWholeCenter:(BOOL)isWholeCenter {
    if (self = [super init]) {
        self.isWholeCenter = isWholeCenter;
        
        CALayer *iconShadow = [CALayer layer];
        iconShadow.frame = CGRectMake(0, 0, 60, 60);
        iconShadow.backgroundColor = UIColor.whiteColor.CGColor;
        iconShadow.cornerRadius = 30;
        iconShadow.shadowColor = UIColor.blackColor.CGColor;
        iconShadow.shadowOpacity = 0.15;
        iconShadow.shadowRadius = 5.0;
        iconShadow.shadowOffset = CGSizeZero;
        iconShadow.shadowPath = [UIBezierPath bezierPathWithOvalInRect:iconShadow.bounds].CGPath;
        [self.layer addSublayer:iconShadow];
        self.iconShadow = iconShadow;
        
        UIImageView *iconView = ({
            UIImageView *aImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jp_icon"]];
            aImgView.frame = CGRectMake(0, 0, 60, 60);
            aImgView.layer.cornerRadius = 30;
            aImgView.layer.masksToBounds = YES;
            aImgView;
        });
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = UIColor.grayColor;
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        _title = title;
        
        CGRect iconViewFrame = iconView.frame;
        CGRect titleLabelFrame = titleLabel.frame;
        if (titleLabelFrame.size.width < iconViewFrame.size.width) titleLabelFrame.size.width = iconViewFrame.size.width;
        
        CGFloat width = titleLabelFrame.size.width;
        CGFloat height = isWholeCenter ? (iconViewFrame.size.height + (titleLabelFrame.size.height ? (15 + titleLabelFrame.size.height) : 0)) : iconViewFrame.size.height;
        
        iconViewFrame.origin.x = (width - iconViewFrame.size.width) * 0.5;
        iconViewFrame.origin.y = 0;
        
        titleLabelFrame.origin.x = (width - titleLabelFrame.size.width) * 0.5;
        titleLabelFrame.origin.y = iconViewFrame.size.height + 15;
        
        iconView.frame = iconViewFrame;
        titleLabel.frame = titleLabelFrame;
        self.frame = CGRectMake(0, 0, width, height);
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isWholeCenter) {
        return [super pointInside:point withEvent:event];
    }
    if (CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, CGRectGetMaxY(self.titleLabel.frame)), point)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupSubviewsLayout];
}

- (void)setupSubviewsLayout {
    CGAffineTransform transform = self.transform;
    CGPoint center = self.center;
    self.transform = CGAffineTransformIdentity;
    
    CGRect iconViewFrame = self.iconView.frame;
    CGRect titleLabelFrame = self.titleLabel.frame;
    if (titleLabelFrame.size.width < iconViewFrame.size.width) titleLabelFrame.size.width = iconViewFrame.size.width;
    
    CGFloat width = titleLabelFrame.size.width;
    CGFloat height = self.isWholeCenter ? (iconViewFrame.size.height + (titleLabelFrame.size.height ? (15 + titleLabelFrame.size.height) : 0)) : iconViewFrame.size.height;
    
    iconViewFrame.origin.x = (width - iconViewFrame.size.width) * 0.5;
    iconViewFrame.origin.y = 0;
    
    titleLabelFrame.origin.x = (width - titleLabelFrame.size.width) * 0.5;
    titleLabelFrame.origin.y = iconViewFrame.size.height + 15;
    
    self.iconShadow.frame = iconViewFrame;
    self.iconView.frame = iconViewFrame;
    self.titleLabel.frame = titleLabelFrame;
    self.frame = CGRectMake(0, 0, width, height);
    self.center = center;
    self.transform = transform;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setupSubviewsLayout];
}

- (void)show {
    if (self.layer.opacity < 1) {
        [UIView animateWithDuration:0.15 animations:^{
            self.layer.opacity = 1;
        }];
    }
}

- (void)hideWithCompletion:(void(^)(void))completion {
    if (self.layer.opacity == 0) {
        !completion ? : completion();
    } else {
        [UIView animateWithDuration:0.15 animations:^{
            self.layer.opacity = 0;
        } completion:^(BOOL finished) {
            !completion ? : completion();
        }];
    }
}

@end
