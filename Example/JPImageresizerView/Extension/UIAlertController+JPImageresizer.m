//
//  UIAlertController+JPImageresizer.m
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/1/23.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import "UIAlertController+JPImageresizer.h"
#import "JPImageresizerView_Example-Swift.h"

@implementation UIAlertController (JPImageresizer)

+ (void)showWithPreferredStyle:(UIAlertControllerStyle)preferredStyle
                         title:(NSString *)title
                       message:(NSString *)message
                       actions:(NSArray<UIAlertAction *> *)actions
            isNeedCancelAction:(BOOL)isNeedCancelAction {
    if (actions.count == 0) return;
    
    UIAlertController *alertCtr = [self alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    for (UIAlertAction *action in actions) {
        [alertCtr addAction:action];
    }
    
    if (isNeedCancelAction) {
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    }
    
    [JPKeyWindow.jp_topViewController presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark - Alert

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
               actions:(NSArray<UIAlertAction *> *)actions {
    [self alertWithTitle:title
                 message:message
                 actions:actions
      isNeedCancelAction:YES];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
               actions:(NSArray<UIAlertAction *> *)actions
    isNeedCancelAction:(BOOL)isNeedCancelAction {
    [self showWithPreferredStyle:UIAlertControllerStyleAlert
                           title:title
                         message:message
                         actions:actions
              isNeedCancelAction:isNeedCancelAction];
}

#pragma mark - Sheet

+ (void)sheetWithActions:(NSArray<UIAlertAction *> *)actions {
    [self sheetWithTitle:nil
                 message:nil
                 actions:actions
      isNeedCancelAction:YES];
}

+ (void)sheetWithTitle:(NSString *)title
               message:(NSString *)message
               actions:(NSArray<UIAlertAction *> *)actions {
    [self sheetWithTitle:title
                 message:message
                 actions:actions
      isNeedCancelAction:YES];
}

+ (void)sheetWithTitle:(NSString *)title
               message:(NSString *)message
               actions:(NSArray<UIAlertAction *> *)actions
    isNeedCancelAction:(BOOL)isNeedCancelAction {
    [self showWithPreferredStyle:UIAlertControllerStyleActionSheet
                           title:title
                         message:message
                         actions:actions
              isNeedCancelAction:isNeedCancelAction];
}

+ (void)changeResizeWHScale:(void(^)(CGFloat resizeWHScale))handler
              isArbitrarily:(BOOL)isArbitrarily
              isRoundResize:(BOOL)isRoundResize {
    if (!handler) return;
    [self sheetWithActions:@[
        [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"使用%@", isArbitrarily ? @"固定比例" : @"任意比例"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(-1);
        }],
        
        [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@圆切", isRoundResize ? @"取消" : @""] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(0);
        }],
        
        [UIAlertAction actionWithTitle:@"1 : 1" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(1);
        }],
        
        [UIAlertAction actionWithTitle:@"2 : 3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(2.0 / 3.0);
        }],
        
        [UIAlertAction actionWithTitle:@"3 : 5" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(3.0 / 5.0);
        }],
        
        [UIAlertAction actionWithTitle:@"9 : 16" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(9.0 / 16.0);
        }],
        
        [UIAlertAction actionWithTitle:@"7 : 3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(7.0 / 3.0);
        }],
        
        [UIAlertAction actionWithTitle:@"16 : 9" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(16.0 / 9.0);
        }],
    ]];
}

+ (void)changeBlurEffect:(void(^)(UIBlurEffect *blurEffect))handler {
    if (!handler) return;
    NSMutableArray<UIAlertAction *> *actions = [NSMutableArray array];
    
    [actions addObject:[UIAlertAction actionWithTitle:@"移除模糊效果" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        handler(nil);
    }]];
    
    [actions addObject:[UIAlertAction actionWithTitle:@"ExtraLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]);
    }]];
    
    [actions addObject:[UIAlertAction actionWithTitle:@"Light" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]);
    }]];
    
    [actions addObject:[UIAlertAction actionWithTitle:@"Dark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]);
    }]];
    
    if (@available(iOS 10, *)) {
        [actions addObject:[UIAlertAction actionWithTitle:@"Regular" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]);
        }]];
        
        [actions addObject:[UIAlertAction actionWithTitle:@"Prominent" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]);
        }]];
        
        if (@available(iOS 13, *)) {
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemThinMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemThickMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemChromeMaterial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemThinMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialLight]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialLight]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemThickMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialLight]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemChromeMaterialLight" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemUltraThinMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemThinMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemThickMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterialDark]);
            }]];
            
            [actions addObject:[UIAlertAction actionWithTitle:@"SystemChromeMaterialDark" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                handler([UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark]);
            }]];
        }
    }
    
    [self sheetWithActions:actions];
}

+ (void)replaceObj:(void(^)(UIImage *image, NSData *imageData, NSURL *videoURL))handler {
    if (!handler) return;
    [self sheetWithActions:@[
        [UIAlertAction actionWithTitle:@"Girl" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(UIImage.randomGirlImage, nil, nil);
        }],
        
        [UIAlertAction actionWithTitle:@"Kobe" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler([UIImage imageNamed:@"Kobe.jpg"], nil, nil);
        }],
        
        [UIAlertAction actionWithTitle:@"Flowers" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler([UIImage imageNamed:@"Flowers.jpg"], nil, nil);
        }],
        
        [UIAlertAction actionWithTitle:@"咬人猫舞蹈节选（视频）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(nil, nil, [NSURL fileURLWithPath:JPMainBundleResourcePath(@"yaorenmao.mov", nil)]);
        }],
        
        [UIAlertAction actionWithTitle:@"Gem（GIF）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(nil, [NSData dataWithContentsOfFile:JPMainBundleResourcePath(@"Gem.gif", nil)], nil);
        }],
        
        [UIAlertAction actionWithTitle:@"Dilraba（GIF）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler(nil, [NSData dataWithContentsOfFile:JPMainBundleResourcePath(@"Dilraba.gif", nil)], nil);
        }],
        
        [UIAlertAction actionWithTitle:@"系统相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [UIImagePickerController openAlbum:handler];
        }],
    ]];
}

+ (void)rotation:(void(^)(BOOL isClockwise))handler1
     toDirection:(void(^)(JPImageresizerRotationDirection direction))handler2{
    if (!handler1 || !handler2) return;
    [self sheetWithActions:@[
        [UIAlertAction actionWithTitle:@"顺时针旋转 🔃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler1(YES);
        }],
        
        [UIAlertAction actionWithTitle:@"逆时针旋转 🔄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler1(NO);
        }],
        
        [UIAlertAction actionWithTitle:@"垂直向上 ⬆️" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler2(JPImageresizerVerticalUpDirection);
        }],
        
        [UIAlertAction actionWithTitle:@"水平向右 ➡️" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler2(JPImageresizerHorizontalRightDirection);
        }],
        
        [UIAlertAction actionWithTitle:@"垂直向下 ⬇️" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler2(JPImageresizerVerticalDownDirection);
        }],
        
        [UIAlertAction actionWithTitle:@"水平向左 ⬅️" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler2(JPImageresizerHorizontalLeftDirection);
        }],
    ]];
}

+ (void)changeMaskImage:(void(^)(UIImage *maskImage))handler1
      gotoMaskImageList:(void(^)(void))handler2
          isReplaceFace:(BOOL)isReplaceFace
   isCanRemoveMaskImage:(BOOL)isCanRemoveMaskImage {
    if (!handler1 || !handler2) return;
    
    NSMutableArray<UIAlertAction *> *actions = [NSMutableArray array];
    
    [actions addObject:[UIAlertAction actionWithTitle:@"蒙版素材列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler2();
    }]];
    
    [actions addObject:[UIAlertAction actionWithTitle:@"love" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler1([UIImage imageNamed:@"love.png"]);
    }]];
    
    [actions addObject:[UIAlertAction actionWithTitle:@"Supreme" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler1([UIImage imageNamed:@"supreme.png"]);
    }]];
    
    if (isReplaceFace) {
        [actions addObject:[UIAlertAction actionWithTitle:@"Face Mask" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            handler1([UIImage imageNamed:@"DanielWuFace.png"]);
        }]];
    }
    
    if (isCanRemoveMaskImage) {
        [actions addObject:[UIAlertAction actionWithTitle:@"移除蒙版" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            handler1(nil);
        }]];
    }
    
    [self sheetWithActions:actions];
}
@end
