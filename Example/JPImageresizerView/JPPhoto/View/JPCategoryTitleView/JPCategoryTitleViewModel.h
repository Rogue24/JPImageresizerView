//
//  JPCategoryTitleViewModel.h
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPCategoryTitleViewModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *count;

@property (nonatomic, assign, readonly) CGRect titleFrame;
@property (nonatomic, assign, readonly) CGRect countFrame;
@property (nonatomic, assign, readonly) CGSize cellSize;
@property (nonatomic, assign) CGRect cellFrame;

@property (nonatomic, assign) BOOL isSelected;

+ (instancetype)categoryTitleViewModelWithTitle:(NSString *)title count:(NSString *)count;

@end
