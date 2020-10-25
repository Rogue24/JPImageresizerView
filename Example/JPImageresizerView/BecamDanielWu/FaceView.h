//
//  FaceView.h
//  JPImageresizerView_Example
//
//  Created by 周健平 on 2020/6/15.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceView : UIView
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (UIImage *)faceImage;
- (CGRect)faceBounds;
- (CGPoint)faceOrigin;
- (CGFloat)faceScale;
- (CGFloat)faceRadian;
@end
