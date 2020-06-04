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

+ (instancetype)browseImagesBottomViewWithSynopsis:(NSString *)synopsis {
    
    JPBrowseImagesBottomView *bottomView = [[self alloc] initWithSynopsis:synopsis];
    
    return bottomView;
}

- (instancetype)initWithSynopsis:(NSString *)synopsis {
    if (self = [super init]) {
        
        self.maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, 9999);
        
        UILabel *synopsisLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.font = [UIFont systemFontOfSize:13];
            aLabel.textColor = UIColor.whiteColor;
            aLabel.numberOfLines = 0;
            aLabel.frame = CGRectMake(15, 15, self.maxSize.width, 1);
            aLabel;
        });
        [self addSubview:synopsisLabel];
        self.synopsisLabel = synopsisLabel;
        
        self.synopsis = synopsis;
    }
    return self;
}

- (void)setSynopsis:(NSString *)synopsis {
    if ([_synopsis isEqualToString:synopsis]) return;
    _synopsis = [synopsis copy];
    
    self.synopsisLabel.text = synopsis;
    [self.synopsisLabel sizeToFit];
    CGRect synopsisLabelF = self.synopsisLabel.frame;
    synopsisLabelF.size.width = self.maxSize.width;
    self.synopsisLabel.frame = synopsisLabelF;
    
    CGFloat x = 0;
    CGFloat w = JPPortraitScreenWidth;
    CGFloat h = self.synopsisLabel.frame.size.height + 30;
    CGFloat y = JPPortraitScreenHeight;
    if (self.frame.origin.y < y) y -= (h + JPDiffTabBarH);
    self.frame = CGRectMake(x, y, w, h);
}

@end
