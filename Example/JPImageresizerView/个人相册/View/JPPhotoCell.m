//
//  JPPhotoCell.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPPhotoCell.h"
#import <Masonry/Masonry.h>
#import <pop/POP.h>

@implementation JPPhotoCell
{
    CGFloat _noSelBorderWidth;
    CGFloat _seledBorderWidth;
    
    UIColor *_noSelBorderColor;
    UIColor *_seledBorderColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _noSelBorderWidth = 0.35;
        _seledBorderWidth = 1.5;
        
        _noSelBorderColor = JPRGBAColor(202, 202, 202, 0.3);
        _seledBorderColor = JPRGBColor(88, 144, 255);
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.imageView = imageView;
        
        UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        stateView.layer.anchorPoint = CGPointMake(1, 1);
        [self addSubview:stateView];
        self.stateView = stateView;
        
        CAShapeLayer *stateLayer = [CAShapeLayer layer];
        stateLayer.frame = stateView.bounds;
        stateLayer.fillColor = _seledBorderColor.CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:stateView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(3, 3)];
        stateLayer.path = path.CGPath;
        [stateView.layer addSublayer:stateLayer];
        
        UILabel *stateLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:10];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.text = @"";
            aLabel.frame = stateView.bounds;
            aLabel;
        });
        [stateView addSubview:stateLabel];
        
        UILongPressGestureRecognizer *longPGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        longPGR.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPGR];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGR];
    }
    return self;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPGR {
    if (longPGR.state == UIGestureRecognizerStateBegan) {
        !self.longPressBlock ? : self.longPressBlock(self);
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tapGR {
    if (self.tapBlock) {
        [self updateSelectedState:self.tapBlock(self) animate:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.stateView.layer.position = CGPointMake(self.frame.size.width, self.frame.size.height);
    [CATransaction commit];
}

- (void)setPhotoVM:(JPPhotoViewModel *)photoVM {
    _photoVM = photoVM;
    
    UIColor *borderColor;
    CGFloat borderWidth;
    CGFloat scale;
    CGFloat opacity;
    if (photoVM.isSelected) {
        borderColor = _seledBorderColor;
        borderWidth = _seledBorderWidth;
        scale = 1;
        opacity = 1;
    } else {
        borderColor = _noSelBorderColor;
        borderWidth = _noSelBorderWidth;
        scale = 0.1;
        opacity = 0;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
    self.stateView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    self.stateView.layer.opacity = opacity;
    [CATransaction commit];
    
    @jp_weakify(self);
    [JPPhotoToolSI requestThumbnailPhotoImageForAsset:photoVM.asset targetSize:photoVM.abbPhotoSize resultHandler:^(PHAsset *requestAsset, UIImage *resultImage, BOOL isFinalImage) {
        @jp_strongify(self);
        if (!self) return;
        if (requestAsset == self.photoVM.asset) {
            self.imageView.image = resultImage;
        } else {
//            JPLog(@"不一样？");
        }
    }];
}

- (void)updateSelectedState:(BOOL)isSelected animate:(BOOL)animate {
    _photoVM.isSelected = isSelected;
    
    UIColor *toBorderColor;
    CGFloat toBorderWidth;
    CGFloat toScale;
    CGFloat toOpacity;
    
    if (isSelected) {
        toBorderColor = _seledBorderColor;
        toBorderWidth = _seledBorderWidth;
        toScale = 1;
        toOpacity = 1;
    } else {
        toBorderColor = _noSelBorderColor;
        toBorderWidth = _noSelBorderWidth;
        toScale = 0.1;
        toOpacity = 0;
    }
    
    [self.layer pop_removeAllAnimations];
    [self.stateView.layer pop_removeAllAnimations];
    
    if (!animate) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.layer.borderColor = toBorderColor.CGColor;
        self.layer.borderWidth = toBorderWidth;
        self.stateView.layer.transform = CATransform3DMakeScale(toScale, toScale, 1);
        self.stateView.layer.opacity = toOpacity;
        [CATransaction commit];
        return;
    }
    
    POPSpringAnimation *anim1 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBorderColor];
    anim1.springSpeed = 10;
    anim1.springBounciness = 10;
    anim1.toValue = toBorderColor;
    [self.layer pop_addAnimation:anim1 forKey:@"borderColor"];

    POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBorderWidth];
    anim2.springSpeed = 10;
    anim2.springBounciness = 10;
    anim2.toValue = @(toBorderWidth);
    [self.layer pop_addAnimation:anim2 forKey:@"borderWidth"];
    
    if (!isSelected) {
        POPSpringAnimation *anim4 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        anim4.springSpeed = 20;
        anim4.springBounciness = 10;
        anim4.toValue = @(toOpacity);
        [self.stateView.layer pop_addAnimation:anim4 forKey:@"opacity"];
    } else {
        self.stateView.layer.opacity = toOpacity;
    }
    
    POPSpringAnimation *anim3 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim3.springSpeed = 20;
    anim3.springBounciness = 10;
    anim3.toValue = @(CGPointMake(toScale, toScale));
    [self.stateView.layer pop_addAnimation:anim3 forKey:@"scaleXY"];
}

@end
