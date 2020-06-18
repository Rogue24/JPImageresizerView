//
//  ShapeMergeCell.m
//  Infinitee2.0
//
//  Created by guanning on 2017/6/19.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "ShapeMergeCell.h"

@implementation ShapeMergeCell

+ (NSInteger)shapeMergeCount {
    return 3;
}

+ (CGFloat)cellMargin {
    return JP10Margin;
}

+ (CGFloat)cellSpace {
    return JP5Margin;
}

+ (CGFloat)cellWH {
    return (JPPortraitScreenWidth - 2 * self.cellMargin - 2 * self.cellSpace) / (CGFloat)self.shapeMergeCount;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat cellMargin = self.class.cellMargin;
        CGFloat cellSpace = self.class.cellSpace;
        CGFloat cellWH = self.class.cellWH;
        NSInteger shapeMergeCount = self.class.shapeMergeCount;
        
        NSMutableArray *shapeLabels = [NSMutableArray array];
        for (NSInteger i = 0; i < shapeMergeCount; i++) {
            CGFloat x = cellMargin + (cellWH + cellSpace) * i;
            UILabel *shapeLabel = ({
                UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, cellWH, cellWH)];
                aLabel.textAlignment = NSTextAlignmentCenter;
                aLabel.backgroundColor = JPRGBColor(250, 250, 250);
                aLabel.textColor = JPRGBAColor(88, 144, 255, 1);
                aLabel.layer.cornerRadius = JPScaleValue(2);
                aLabel.layer.borderWidth = 1;
                aLabel.layer.borderColor = JPRGBAColor(202, 202, 202, 0.3).CGColor;
                aLabel.layer.masksToBounds = YES;
                aLabel.userInteractionEnabled = YES;
                [aLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShapeLabel:)]];
                aLabel;
            });
            [self.contentView addSubview:shapeLabel];
            [shapeLabels addObject:shapeLabel];
        }
        self.shapeLabels = shapeLabels.copy;
    }
    return self;
}

- (void)tapShapeLabel:(UITapGestureRecognizer *)tap {
    if (!self.tapShapeBlock) return;
    UILabel *shapeLabel = (UILabel *)tap.view;
    self.tapShapeBlock(shapeLabel.text);
}

@end
