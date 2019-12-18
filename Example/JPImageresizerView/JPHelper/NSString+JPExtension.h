//
//  NSString+JPExtension.h
//  WoTV
//
//  Created by 周健平 on 2018/4/11.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>

CG_INLINE bool
JPStringEqualToString(NSString *str1, NSString *str2) {
    if (!str1 && !str2) return true;
    if ((str1 && str2) && [str1 isEqualToString:str2]) return true;
    return false;
}

@interface NSString (JPExtension)

/** 判断是否全是空格 */
- (BOOL)jp_isNotEmpty;
- (BOOL)jp_isNotNull;

/** 判断是否纯数字 */
- (BOOL)jp_isNumber;

- (BOOL)jp_isPhoneNumber;

- (NSString *)jp_examineTextWithTextHandle:(NSString *(^)(BOOL isNullStr, NSString *text))textHandle;

- (NSString *)jp_createDateStrWithSeparateStr:(NSString *)separateStr;

+ (NSString *)jp_durationFormatWithFromTime:(NSString *)fromTime toTime:(NSString *)toTime separateStr:(NSString *)separateStr connectStr:(NSString *)connectStr;

- (NSAttributedString *)jp_matchesKeywords:(NSString *)keywords font:(UIFont *)font keywordsColor:(UIColor *)keywordsColor otherColor:(UIColor *)otherColor;

- (NSString *)jp_appVersionFormat;

/** 判断如果包含中文 */
- (BOOL)jp_containsChinese;

/** 判断是否身份证号码 */
- (BOOL)jp_isCardID;

@end
