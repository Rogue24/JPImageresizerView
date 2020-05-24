//
//  JPAlertControllerTool.m
//  Infinitee2.0-Design
//
//  Created by Jill on 16/8/16.
//  Copyright © 2016年 陈珏洁. All rights reserved.
//

#import "JPAlertControllerTool.h"

@implementation JPAlertControllerTool

+ (UIAlertController *)alertControllerWithStyle:(UIAlertControllerStyle)style title:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions targetController:(UIViewController *)targetController {
    return [self alertControllerWithStyle:style title:title message:message actions:actions configurationHandler:nil targetController:targetController];
}

+ (UIAlertController *)alertControllerWithStyle:(UIAlertControllerStyle)style title:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions configurationHandler:(void (^)(UITextField *))configurationHandler targetController:(UIViewController *)targetController {
    
    if (!targetController || actions.count == 0) return nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    if (configurationHandler) [alertController addTextFieldWithConfigurationHandler:configurationHandler];
    [targetController presentViewController:alertController animated:YES completion:nil];
    
    return alertController;
}

@end
