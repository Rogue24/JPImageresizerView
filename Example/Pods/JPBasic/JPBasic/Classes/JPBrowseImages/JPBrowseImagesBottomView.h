//
//  JPBrowseImagesBottomView.h
//  Infinitee2.0
//
//  Created by guanning on 2017/8/4.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPBrowseImagesBottomView : UIView

+ (instancetype)browseImagesBottomViewWithSynopsis:(NSString *)synopsis;
@property (nonatomic, copy) NSString *synopsis;

@end
