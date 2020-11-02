//
//  JPMainCell.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/11/2.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPMainCell.h"

@interface JPMainCell ()
@property (nonatomic, weak) CALayer *shadowLayer;
@property (nonatomic, weak) UIImageView *shadowView;
@end

@implementation JPMainCell

static NSString *cellID_;
static UIFont *titleFont_;
static UIColor *titleColor_;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellID_ = @"JPMainCell";
        titleFont_ = JPScaleBoldFont(18);
        titleColor_ = UIColor.whiteColor;
    });
}

+ (NSString *)cellID {
    return cellID_;
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
        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:JP8Margin].CGPath;
        shadowLayer.shadowOffset = CGSizeMake(0, 2);
        shadowLayer.shadowRadius = 5;
        shadowLayer.shadowColor = UIColor.blackColor.CGColor;
        shadowLayer.shadowOpacity = 0.2;
        [self.layer addSublayer:shadowLayer];
        self.shadowLayer = shadowLayer;
        
        JPBounceView *bouceView = [[JPBounceView alloc] initWithFrame:self.bounds];
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
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [bouceView addSubview:imageView];
        self.imageView = imageView;
        
        UIImage *shadow = [UIImage imageNamed:@"rect_shadow"];
        UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bouceView.jp_width, bouceView.jp_width * (shadow.size.height / shadow.size.width))];
        shadowView.image = shadow;
        [bouceView addSubview:shadowView];
        self.shadowView = shadowView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.font = titleFont_;
        titleLabel.textColor = titleColor_;
        [bouceView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.bouceView.bounds.size.width == self.bounds.size.width) return;
    
    self.bouceView.frame = self.bounds;
    self.shadowLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:JP8Margin].CGPath;
    self.shadowView.jp_size = CGSizeMake(self.bouceView.jp_width, self.bouceView.jp_width * (self.shadowView.image.size.height / self.shadowView.image.size.width));
}

@end
