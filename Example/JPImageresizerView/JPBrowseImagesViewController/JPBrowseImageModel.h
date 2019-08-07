//
//  JPBrowseImageModel.h
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPPictureInfoModel;

@interface JPBrowseImageModel : NSObject
@property (nonatomic, assign) UIViewContentMode contentMode;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, assign) CGRect pictureFrame;
@property (nonatomic, assign) CGFloat maximumScale;
@property (nonatomic, assign) BOOL isCornerRadiusTransition;
@property (nonatomic, assign) BOOL isAlphaTransition;

@property (nonatomic, strong) JPPictureInfoModel *infoModel;
@end

@interface JPPictureInfoModel : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *synopsis;
@end
