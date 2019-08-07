//
//  BrowseImagesTopView.m
//  Infinitee2.0
//
//  Created by guanning on 2017/8/4.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPBrowseImagesTopView.h"

@interface JPBrowseImagesTopView ()
@property (nonatomic, weak) UILabel *indexLabel;
@end

@implementation JPBrowseImagesTopView

+ (instancetype)browseImagesTopViewWithPictureTotal:(NSInteger)total
                                              index:(NSInteger)index
                                        dismissIcon:(NSString *)dismissIcon
                                          otherIcon:(NSString *)otherIcon
                                             target:(id)target
                                      dismissAction:(SEL)dismissAction
                                        otherAction:(SEL)otherAction {
    JPBrowseImagesTopView *topView = [[self alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64) total:total index:index dismissIcon:dismissIcon otherIcon:otherIcon target:target dismissAction:dismissAction otherAction:otherAction];
    return topView;
}

- (instancetype)initWithFrame:(CGRect)frame total:(NSInteger)total index:(NSInteger)index dismissIcon:(NSString *)dismissIcon otherIcon:(NSString *)otherIcon target:(id)target dismissAction:(SEL)dismissAction otherAction:(SEL)otherAction {
    CGFloat statusBarH = 20;
    BOOL isX = [UIScreen mainScreen].bounds.size.height > 736.0;
    if (isX) {
        statusBarH += 24;
        frame.size.height += 24;
    }
    if (self = [super initWithFrame:frame]) {
        _total = total;
        _index = index;
        
        UIButton *dismissBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.frame = CGRectMake(15, statusBarH, 44, 44);
            [btn setImage:[[UIImage imageNamed:dismissIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            [btn addTarget:target action:dismissAction forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self addSubview:dismissBtn];
        
        UILabel *indexLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:14];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) * 0.5, statusBarH, 200, 44);
            aLabel;
        });
        [self addSubview:indexLabel];
        self.indexLabel = indexLabel;
        
        UIButton *otherBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            btn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 44 - 15, statusBarH, 44, 44);
            [btn setImage:[[UIImage imageNamed:otherIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            [btn addTarget:target action:otherAction forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self addSubview:otherBtn];
        
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
