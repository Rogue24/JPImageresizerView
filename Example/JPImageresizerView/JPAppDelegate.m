//
//  JPAppDelegate.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPAppDelegate.h"

@implementation JPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [JPProgressHUD setMaxSupportedWindowLevel:UIWindowLevelAlert];
    [JPProgressHUD setMinimumDismissTimeInterval:1.2];
    [JPProgressHUD setCustomStyle];
    [JPProgressHUD setBackgroundColor:JPRGBColor(240, 240, 240)];
    [JPProgressHUD setForegroundColor:JPRGBColor(16, 16, 16)];
    return YES;
}

@end
