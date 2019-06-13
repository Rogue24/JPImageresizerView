//
//  JPCategoryTitleCell.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPCategoryTitleCell.h"
#import <pop/POP.h>

@interface JPCategoryTitleCell ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *countLabel;
@property (nonatomic, weak) CAShapeLayer *countLayer;
@property (nonatomic, assign) BOOL isSelected;
@end

@implementation JPCategoryTitleCell

+ (CGFloat)cellHeight {
    return 44.0;
}

+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:12];
}

+ (UIFont *)countFont {
    return [UIFont systemFontOfSize:10];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = JPCategoryTitleCell.titleFont;
            aLabel.textColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
            aLabel;
        });
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        CAShapeLayer *countLayer = [CAShapeLayer layer];
        countLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;
        countLayer.lineWidth = 0;
        [self.layer addSublayer:countLayer];
        self.countLayer = countLayer;
        
        UILabel *countLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = self.class.countFont;
            aLabel.textColor = [UIColor whiteColor];
            aLabel;
        });
        [self addSubview:countLabel];
        self.countLabel = countLabel;
    }
    return self;
}

- (void)setTitleVM:(JPCategoryTitleViewModel *)titleVM {
    _titleVM = titleVM;
    
    self.isSelected = titleVM.isSelected;
    self.titleLabel.textColor = titleVM.isSelected ? UIColor.blueColor : [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    
    self.titleLabel.text = titleVM.title;
    self.titleLabel.frame = titleVM.titleFrame;
    
    self.countLabel.text = titleVM.count;
    self.countLabel.frame = titleVM.countFrame;
    
    self.countLayer.path = [UIBezierPath bezierPathWithRoundedRect:titleVM.countFrame cornerRadius:titleVM.countFrame.size.height * 0.5].CGPath;
}

- (void)updateSelectedState:(BOOL)isSelected animate:(BOOL)animate {
    if (self.isSelected == isSelected) return;
    self.isSelected = isSelected;
    UIColor *textColor = isSelected ? UIColor.blueColor : [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    if (animate) {
        POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLabelTextColor];
        anim.toValue = textColor;
        anim.duration = 0.35;
        [self.titleLabel pop_addAnimation:anim forKey:@"textColor"];
    } else {
        self.titleLabel.textColor = textColor;
    }
}

- (void)setColorProgress:(CGFloat)colorProgress {
    _colorProgress = colorProgress;
    CGFloat a = 0.5 + colorProgress * 0.5;
    self.titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:a];
}

@end
