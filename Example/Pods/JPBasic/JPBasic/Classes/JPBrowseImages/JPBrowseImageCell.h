//
//  JPBrowseImageCell.h
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPBrowseImagesViewController;
@class JPBrowseImageProgressLayer;
#import "JPBrowseImageModel.h"

@interface JPBrowseImageCell : UICollectionViewCell
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) JPBrowseImageProgressLayer *progressLayer;

@property (nonatomic, strong, readonly) JPBrowseImageModel *model;
@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, assign, readonly) BOOL isSetingImage;
@property (nonatomic, assign, readonly) BOOL isSetImageSuccess;

@property (nonatomic, weak) JPBrowseImagesViewController *superVC;
@property (nonatomic, weak) id<UIGestureRecognizerDelegate> panGRDelegate;
@property (nonatomic, copy) void (^beginPanBlock)(void);
@property (nonatomic, copy) void (^endPanBlock)(void);
@property (nonatomic, copy) void (^singleClickBlock)(void);

- (void)setModel:(JPBrowseImageModel *)model index:(NSInteger)index;
- (void)hideImageView;
- (void)showImageView;
@property (nonatomic, assign) BOOL isDisplaying;
@property (nonatomic, assign) BOOL isDismiss;
@end

@interface JPBrowseImageProgressLayer : CALayer
+ (instancetype)browseImageProgressLayer;
@property (nonatomic, assign) CGFloat progress;
@end
