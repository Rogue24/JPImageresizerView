//
//  JPBrowseImagesBottomView.m
//  Infinitee2.0
//
//  Created by guanning on 2017/8/4.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImagesBottomView.h"
#import "JPConstant.h"

@interface JPBrowseImagesBottomView ()
@property (nonatomic, weak) UILabel *synopsisLabel;
@property (nonatomic, assign) CGSize maxSize;
@end

@implementation JPBrowseImagesBottomView

+ (instancetype)browseImagesBottomView {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, JPPortraitScreenHeight, JPPortraitScreenWidth, 30)]) {
        self.maxSize = CGSizeMake(JPPortraitScreenWidth - 30, 999);
        UILabel *synopsisLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.font = [UIFont systemFontOfSize:13];
            aLabel.textColor = UIColor.whiteColor;
            aLabel.numberOfLines = 0;
            aLabel.frame = CGRectMake(15, 15, self.maxSize.width, 0);
            aLabel;
        });
        [self addSubview:synopsisLabel];
        self.synopsisLabel = synopsisLabel;
    }
    return self;
}

- (void)setSynopsis:(NSString *)synopsis {
    if ([_synopsis isEqualToString:synopsis]) return;
    _synopsis = [synopsis copy];
    
    self.synopsisLabel.text = synopsis;
    self.synopsisLabel.frame = (CGRect){CGPointMake(15, 15), [self.synopsisLabel sizeThatFits:self.maxSize]};
    
    CGRect frame = self.frame;
    frame.size.height = self.synopsisLabel.frame.size.height + 30;
    if (frame.origin.y < JPPortraitScreenHeight) {
        frame.origin.y = JPPortraitScreenHeight - (frame.size.height + JPDiffTabBarH);
    }
    self.frame = frame;
}

@end
