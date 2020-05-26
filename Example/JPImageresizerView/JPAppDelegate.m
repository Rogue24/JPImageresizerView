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
    [JPProgressHUD setMinimumDismissTimeInterval:1.3];
    return YES;
}

@end
