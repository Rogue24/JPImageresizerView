//
//  BrowseImagesTopView.m
//  Infinitee2.0
//
//  Created by guanning on 2017/8/4.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImagesTopView.h"
#import "JPInline.h"

@interface JPBrowseImagesTopView ()
@property (nonatomic, weak) UILabel *indexLabel;
@end

@implementation JPBrowseImagesTopView

+ (instancetype)browseImagesTopViewWithPictureTotal:(NSInteger)total
                                              index:(NSInteger)index
                                         dismissBtn:(UIButton *)dismissBtn
                                           otherBtn:(UIButton *)otherBtn
                                             target:(id)target
                                      dismissAction:(SEL)dismissAction
                                        otherAction:(SEL)otherAction {
    JPBrowseImagesTopView *topView = [[self alloc] initWithFrame:CGRectMake(0, 0, JPPortraitScreenWidth, JPNavTopMargin)
                                                           total:total
                                                           index:index
                                                      dismissBtn:dismissBtn
                                                        otherBtn:otherBtn
                                                          target:target
                                                   dismissAction:dismissAction
                                                     otherAction:otherAction];
    return topView;
}

- (instancetype)initWithFrame:(CGRect)frame
                        total:(NSInteger)total
                        index:(NSInteger)index
                   dismissBtn:(UIButton *)dismissBtn
                     otherBtn:(UIButton *)otherBtn
                       target:(id)target
                dismissAction:(SEL)dismissAction
                  otherAction:(SEL)otherAction {
    if (self = [super initWithFrame:frame]) {
        _total = total;
        _index = index;
        
        UILabel *indexLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:14];
            aLabel.textColor = UIColor.whiteColor;
            aLabel.frame = CGRectMake(JPHalfOfDiff(JPPortraitScreenWidth, 200), JPStatusBarH, 200, JPNavBarH);
            aLabel;
        });
        [self addSubview:indexLabel];
        self.indexLabel = indexLabel;
        
        if (dismissBtn) {
            dismissBtn.frame = CGRectMake(15, JPStatusBarH, JPNavBarH, JPNavBarH);
            [dismissBtn addTarget:target action:dismissAction forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:dismissBtn];
        } else {
            NSInteger scale = (NSInteger)[UIScreen mainScreen].scale;
            if (scale < 2) scale = 2;
            if (scale > 3) scale = 3;
            NSBundle *bundle = [NSBundle bundleForClass:self.class];
            NSString *bundleName = @"JPBrowseImages.bundle";
            NSString *type = @"png";
            NSString *dismissIconPath = [bundle pathForResource:[NSString stringWithFormat:@"jp_back_icon@%zdx", scale] ofType:type inDirectory:bundleName];
            UIImage *dismissIcon = [[UIImage imageWithContentsOfFile:dismissIconPath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            dismissBtn = ({
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btn.frame = CGRectMake(15, JPStatusBarH, JPNavBarH, JPNavBarH);
                [btn setImage:dismissIcon forState:UIControlStateNormal];
                [btn addTarget:target action:dismissAction forControlEvents:UIControlEventTouchUpInside];
                btn;
            });
            [self addSubview:dismissBtn];
        }
        
        if (otherBtn) {
            otherBtn.frame = CGRectMake(JPPortraitScreenWidth - JPNavBarH - 15, JPStatusBarH, JPNavBarH, JPNavBarH);
            [otherBtn addTarget:target action:otherAction forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:otherBtn];
        }
        
        [self updateIndex];
    }
    return self;
}

- (void)setTotal:(NSInteger)total {
    _total = total;
    [self updateIndex];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    [self updateIndex];
}

- (void)updateIndex {
    self.indexLabel.text = [NSString stringWithFormat:@"%zd / %zd", _index + 1, _total];
}

@end
