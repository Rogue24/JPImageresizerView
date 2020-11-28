//
//  JPMainHeader.m
//  JPImageresizerView_Example
//
//  Created by aa on 2020/11/28.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "JPMainHeader.h"

@implementation JPMainHeader
static NSString *headerID_;
static UIFont *titleFont_;
static UIColor *titleColor_;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        headerID_ = @"JPMainHeader";
        titleFont_ = JPScaleBoldFont(30);
        titleColor_ = UIColor.whiteColor;
    });
}

+ (NSString *)headerID {
    return headerID_;
}

+ (UIFont *)titleFont {
    return titleFont_;
}

+ (UIColor *)titleColor {
    return titleColor_;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

@end
