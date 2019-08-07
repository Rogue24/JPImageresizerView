//
//  JPBrowseImagesTopView.h
//  Infinitee2.0
//
//  Created by guanning on 2017/8/4.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JPBrowseDismissBtnDidClick)(void);

@interface JPBrowseImagesTopView : UIView
+ (instancetype)browseImagesTopViewWithPictureTotal:(NSInteger)total
                                              index:(NSInteger)index
                                        dismissIcon:(NSString *)dismissIcon
                                          otherIcon:(NSString *)otherIcon
                                             target:(id)target
                                      dismissAction:(SEL)dismissAction
                                        otherAction:(SEL)otherAction;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger index;
@end
