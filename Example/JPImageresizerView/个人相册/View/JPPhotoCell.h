//
//  JPPhotoCell.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPPictureChooseCellProtocol.h"
#import "JPPhotoViewModel.h"

@interface JPPhotoCell : UICollectionViewCell <JPPictureChooseCellProtocol>
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIView *stateView;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) JPPhotoViewModel *photoVM;
@property (nonatomic, copy) void (^longPressBlock)(JPPhotoCell *pCell);
@property (nonatomic, copy) BOOL (^tapBlock)(JPPhotoCell *pCell);

@property (nonatomic, assign) CGFloat startScale;
@property (nonatomic, assign) CGFloat endScale;
@property (nonatomic, assign) CGFloat totalScale;

- (void)updateSelectedState:(BOOL)isSelected animate:(BOOL)animate;
@end
