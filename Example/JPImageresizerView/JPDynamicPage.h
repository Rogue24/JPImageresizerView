//
//  JPDynamicPage.h
//  JPDynamicPage
//
//  Created by guanning on 2017/9/9.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JPDynamicPageState) {
    JPDynamicPageIdle,
    JPDynamicPageAnimating,
    JPDynamicPagePause
};

@interface JPDynamicPage : UIView
+ (instancetype)dynamicPage;

- (void)startAnimation;
- (void)stopAnimation;
- (void)pauseAnimation;
- (void)resumeAnimation;

@property (nonatomic, assign) JPDynamicPageState state;
@property (nonatomic, assign) NSTimeInterval duration;

- (void)updateFrame:(CGRect)frame;
@end
