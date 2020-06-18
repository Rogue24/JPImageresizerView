//
//  ShapeListViewController.h
//  Infinitee2.0
//
//  Created by guanning on 2017/6/15.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeListViewController : UICollectionViewController
+ (instancetype)shapeListViewController:(void(^)(UIImage *shapeImage))getShapeImageBlock;
@end
