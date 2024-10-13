//
//  JPAppDelegate.m
//  JPImageresizerView
//
//  Created by ZhouJianPing on 12/21/2017.
//  Copyright (c) 2017 ZhouJianPing. All rights reserved.
//

#import "JPAppDelegate.h"
#import <ScreenRotator/JPScreenRotator.h>

@implementation JPAppDelegate

- (UIWindow *)window {
    if (@available(iOS 13.0, *)) {
        UIScene *scene = [UIApplication sharedApplication].connectedScenes.anyObject;
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            id<UIWindowSceneDelegate> windowSceneDelegate = (id<UIWindowSceneDelegate>)scene.delegate;
            if ([windowSceneDelegate respondsToSelector:@selector(window)]) {
                return windowSceneDelegate.window;
            }
        }
        return nil;
    }
    return [UIApplication sharedApplication].delegate.window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [JPScreenRotator sharedInstance].isLockLandscapeWhenDeviceOrientationDidChange = NO;
    [JPScreenRotator sharedInstance].isLockOrientationWhenDeviceOrientationDidChange = NO;
    
    [JPProgressHUD setMaxSupportedWindowLevel:UIWindowLevelAlert];
    [JPProgressHUD setMinimumDismissTimeInterval:1.2];
    [JPProgressHUD setCustomStyle];
    [JPProgressHUD setBackgroundColor:JPRGBColor(240, 240, 240)];
    [JPProgressHUD setForegroundColor:JPRGBColor(16, 16, 16)];
    
    if (@available(iOS 15.0, *)) {
        UINavigationBar *navigationBar = [UINavigationBar appearance];
        
        UINavigationBarAppearance *scrollEdgeAppearance = [[UINavigationBarAppearance alloc] init];
        navigationBar.scrollEdgeAppearance = scrollEdgeAppearance;
        
        UINavigationBarAppearance *standardAppearance = [[UINavigationBarAppearance alloc] init];
        navigationBar.standardAppearance = standardAppearance;
    }
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [JPScreenRotator sharedInstance].orientationMask;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
