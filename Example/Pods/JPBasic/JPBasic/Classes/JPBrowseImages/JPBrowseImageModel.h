//
//  JPBrowseImageModel.h
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPBrowseImageModel : NSObject
@property (nonatomic, assign) UIViewContentMode contentMode;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign, readonly) CGFloat imageWhScale;
@property (nonatomic, assign, readonly) CGSize contentSize;
@property (nonatomic, assign, readonly) UIEdgeInsets contentInset;
@property (nonatomic, assign, readonly) CGFloat maximumScale;

@property (nonatomic, assign) BOOL isCornerRadiusTransition;
@property (nonatomic, assign) BOOL isAlphaTransition;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *synopsis;
@end
