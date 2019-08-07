//
//  JPBrowseImagesTransition.h
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPBrowseImagesTransition : NSObject <UIViewControllerAnimatedTransitioning>
+ (instancetype)presentTransition;
+ (instancetype)dismissTransition;
@end
