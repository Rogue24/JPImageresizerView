//
//  JPCategoryTitleViewModel.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPCategoryTitleViewModel.h"
#import "JPCategoryTitleCell.h"

@implementation JPCategoryTitleViewModel

+ (instancetype)categoryTitleViewModelWithTitle:(NSString *)title count:(NSString *)count {
    JPCategoryTitleViewModel *titleVM = [self new];
    titleVM.title = title;
    titleVM.count = count;
    return titleVM;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    
    UIFont *font = JPCategoryTitleCell.titleFont;
    CGRect titleFrame = [title boundingRectWithSize:CGSizeMake(999, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    titleFrame.size.height = JPCategoryTitleCell.cellHeight;
    _titleFrame = titleFrame;
    
    _cellSize = CGSizeMake(CGRectGetMaxX(_countFrame), _titleFrame.size.height);
}

- (void)setCount:(NSString *)count {
    _count = [count copy];
    
    UIFont *font = JPCategoryTitleCell.countFont;
    CGRect countFrame = [count boundingRectWithSize:CGSizeMake(999, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    countFrame.size.width += (5 * 2);
    countFrame.size.height = font.pointSize + (2 * 2);
    countFrame.origin.x = CGRectGetMaxX(_titleFrame) + 5;
    countFrame.origin.y = (_titleFrame.size.height - countFrame.size.height) * 0.5;
    _countFrame = countFrame;
    
    _cellSize = CGSizeMake(CGRectGetMaxX(_countFrame), _titleFrame.size.height);
}

@end
