//
//  JPMainCell.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/11/2.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPMainCell.h"

@interface JPMainCell ()
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
        titleFont_ = JPScaleBoldFont(14);
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
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
        
        JPBounceView *bounceView = [[JPBounceView alloc] initWithFrame:self.bounds];
        bounceView.scale = 0.97;
        bounceView.recoverSpeed = 15;
        bounceView.recoverBounciness = 15;
        bounceView.scaleDuration = 0.35;
        bounceView.layer.cornerRadius = JP8Margin;
        bounceView.layer.masksToBounds = YES;
        [self.contentView addSubview:bounceView];
        self.bounceView = bounceView;
        
        @jp_weakify(self);
        bounceView.touchingDidChanged = ^(JPBounceView *kBounceView, BOOL isTouching) {
            @jp_strongify(self);
            if (!self) return;
            if (isTouching) {
                POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                anim.toValue = @(CGPointMake(1.03, 1.03));
                anim.duration = kBounceView.scaleDuration;
                [self.imageView.layer pop_addAnimation:anim forKey:kPOPLayerScaleXY];
            } else {
                POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                anim.toValue = @(CGPointMake(1.0, 1.0));
                anim.springSpeed = kBounceView.recoverSpeed;
                anim.springBounciness = kBounceView.recoverBounciness;
                [self.imageView.layer pop_addAnimation:anim forKey:kPOPLayerScaleXY];
            }
        };
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [bounceView addSubview:imageView];
        self.imageView = imageView;
        
        UIImage *shadow = [UIImage imageNamed:@"rect_shadow"];
        CGFloat w = bounceView.jp_width;
        CGFloat h = bounceView.jp_width * (shadow.size.height / shadow.size.width);
        CGFloat y = bounceView.jp_height - h;
        UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, w, h)];
        shadowView.image = shadow;
        shadowView.transform = CGAffineTransformMakeRotation(M_PI);
        [bounceView addSubview:shadowView];
        self.shadowView = shadowView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.font = titleFont_;
        titleLabel.textColor = titleColor_;
        [bounceView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.bounceView.bounds.size.width == self.bounds.size.width) return;
    
    self.bounceView.bounds = self.bounds;
    self.bounceView.frame = self.bounds;
    
    CGFloat w = self.bounceView.bounds.size.width;
    CGFloat h = w * (self.shadowView.image.size.height / self.shadowView.image.size.width);
    CGFloat y = self.bounceView.bounds.size.height - h;
    self.shadowView.frame = CGRectMake(0, y, w, h);
}

@end
