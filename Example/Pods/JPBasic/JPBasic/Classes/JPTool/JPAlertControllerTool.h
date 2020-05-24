//
//  JPAlertControllerTool.h
//  Infinitee2.0-Design
//
//  Created by Jill on 16/8/16.
//  Copyright © 2016年 陈珏洁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPAlertControllerTool : NSObject

/**
 * 没有configurationHandler
 */
+ (UIAlertController *)alertControllerWithStyle:(UIAlertControllerStyle)style title:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions targetController:(UIViewController *)targetController;

/**
 * 有configurationHandler
 */
+ (UIAlertController *)alertControllerWithStyle:(UIAlertControllerStyle)style title:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions configurationHandler:(void (^)(UITextField *textField))configurationHandler targetController:(UIViewController *)targetController;

@end
