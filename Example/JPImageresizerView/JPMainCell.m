//
//  JPMainCell.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/11/2.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPMainCell.h"


@implementation JPMainCell

static NSString *cellID_;
static CGFloat cellMargin_;
static CGSize cellMaxSize_;
static CGFloat titleMargin_;
static CGFloat titleMaxWidth_;
static UIFont *titleFont_;
static UIColor *titleColor_;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellID_ = @"JPMainCell";
        
        cellMargin_ = JPScaleValue(16);
        
        CGFloat w = JPPortraitScreenWidth - 2 * cellMargin_;
        cellMaxSize_ = CGSizeMake(w, w * JPWideVideoHWScale);
        
        titleMargin_ = JP10Margin;
        titleMaxWidth_ = cellMaxSize_.width - 2 * titleMargin_;
        
        titleFont_ = JPScaleBoldFont(18);
        titleColor_ = UIColor.whiteColor;
    });
}

+ (NSString *)cellID {
    return cellID_;
}

+ (CGFloat)cellMargin {
    return cellMargin_;
}

+ (CGSize)cellMaxSize {
    return cellMaxSize_;
}

+ (CGFloat)titleMargin {
    return titleMargin_;
}

+ (CGFloat)titleMaxWidth {
    return titleMaxWidth_;
}

+ (UIFont *)titleFont {
    return titleFont_;
}

+ (UIColor *)titleColor {
    return titleColor_;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CALayer *shadowLayer = [CALayer layer];
        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, self.class.cellMaxSize} cornerRadius:JP8Margin].CGPath;
        shadowLayer.shadowOffset = CGSizeMake(0, 2);
        shadowLayer.shadowRadius = 5;
        shadowLayer.shadowColor = UIColor.blackColor.CGColor;
        shadowLayer.shadowOpacity = 0.2;
        [self.layer addSublayer:shadowLayer];
        
        JPBounceView *bouceView = [[JPBounceView alloc] initWithFrame:(CGRect){CGPointZero, self.class.cellMaxSize}];
        bouceView.scale = 0.98;
        bouceView.recoverSpeed = 15;
        bouceView.recoverBounciness = 15;
        bouceView.scaleDuration = 0.35;
        bouceView.layer.cornerRadius = JP8Margin;
        bouceView.layer.masksToBounds = YES;
        [self.contentView addSubview:bouceView];
        self.bouceView = bouceView;
        
        @jp_weakify(self);
        bouceView.touchingDidChanged = ^(BOOL isTouching) {
            @jp_strongify(self);
            if (!self) return;
            POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            if (isTouching) {
                anim.toValue = @(CGPointMake(1.1, 1.1));
            } else {
                anim.toValue = @(CGPointMake(1.0, 1.0));
            }
            anim.duration = 0.5;
            [self.imageView.layer pop_addAnimation:anim forKey:kPOPLayerScaleXY];
        };
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:bouceView.bounds];
        [bouceView addSubview:imageView];
        self.imageView = imageView;
        
        UIImage *shadow = [UIImage imageNamed:@"rect_shadow"];
        UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bouceView.jp_width, bouceView.jp_width * (shadow.size.height / shadow.size.width))];
        shadowView.image = shadow;
        [bouceView addSubview:shadowView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleMargin_, titleMargin_, titleMaxWidth_, 0)];
        titleLabel.numberOfLines = 0;
        titleLabel.font = titleFont_;
        titleLabel.textColor = titleColor_;
        [bouceView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

@end
