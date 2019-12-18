//
//  NSString+JPExtension.m
//  WoTV
//
//  Created by 周健平 on 2018/4/11.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "NSString+JPExtension.h"

@implementation NSString (JPExtension)

- (BOOL)jp_isNotEmpty {
    if (!self) {
        return NO;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [self stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (BOOL)jp_isNotNull {
    if (self.jp_isNotEmpty) {
        return ![self isEqualToString:@"(null)"];
    } else {
        return NO;
    }
}

- (BOOL)jp_isNumber {
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
}

- (BOOL)jp_isPhoneNumber {
    NSString *regex = @"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
}

- (NSString *)jp_examineTextWithTextHandle:(NSString *(^)(BOOL isNullStr, NSString *text))textHandle {
    BOOL isNull = !self.jp_isNotNull;
    if (textHandle) {
        if (isNull) {
            return textHandle(YES, @"暂无信息");
        } else {
            return textHandle(NO, self);
        }
    } else {
        if (isNull) {
            return @"暂无信息";
        } else {
            return self;
        }
    }
}

- (NSString *)jp_createDateStrWithSeparateStr:(NSString *)separateStr {
    NSMutableString *dateStr;
    if (!self.jp_isNotNull) {
        dateStr = [@"" mutableCopy];
    } else {
        if (self.length >= 4) {
            dateStr = [NSMutableString string];
            [dateStr appendString:[self substringWithRange:NSMakeRange(0, 4)]];
            if (self.length >= 6) {
                [dateStr appendString:separateStr];
                [dateStr appendString:[self substringWithRange:NSMakeRange(4, 2)]];
                if (self.length >= 8) {
                    [dateStr appendString:separateStr];
                    [dateStr appendString:[self substringWithRange:NSMakeRange(6, 2)]];
                }
            }
        } else {
            dateStr = [@"" mutableCopy];
        }
    }
    return dateStr;
}

+ (NSString *)jp_durationFormatWithFromTime:(NSString *)fromTime toTime:(NSString *)toTime separateStr:(NSString *)separateStr connectStr:(NSString *)connectStr {
    NSString *dateStr = [fromTime jp_createDateStrWithSeparateStr:separateStr];
    if (dateStr.length == 0) {
        dateStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"KSystemStartTime"];
        if (!dateStr.jp_isNotNull || dateStr.length < 10) {
            NSDate *date = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSInteger year = [calendar component:NSCalendarUnitYear fromDate:date];
            NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:date];
            NSInteger day = [calendar component:NSCalendarUnitDay fromDate:date];
            dateStr = [NSString stringWithFormat:@"%02zd%@%02zd%@%02zd", year, separateStr, month, separateStr, day];
        } else {
            dateStr = [dateStr substringToIndex:10];
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@"-" withString:separateStr];
        }
    }
    NSString *toDateStr = [toTime jp_createDateStrWithSeparateStr:separateStr];
    if (toDateStr.length) dateStr = [dateStr stringByAppendingFormat:@"%@%@", connectStr, toDateStr];
    return dateStr;
}

- (NSAttributedString *)jp_matchesKeywords:(NSString *)keywords font:(UIFont *)font keywordsColor:(UIColor *)keywordsColor otherColor:(UIColor *)otherColor {
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: otherColor}];
    if (keywords.length && self.length) {
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:keywords options:NSRegularExpressionCaseInsensitive error:nil];
        [regex enumerateMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            if (result.range.length) {
                [attStr addAttributes:@{NSForegroundColorAttributeName: keywordsColor} range:result.range];
            }
        }];
    }
    return attStr;
}

- (NSString *)jp_appVersionFormat {
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSMutableArray *appVersionArr = [self componentsSeparatedByCharactersInSet:nonDigitCharacterSet].mutableCopy;
    if (appVersionArr.count < 3) {
        NSInteger diffCount = 3 - appVersionArr.count;
        for (int i = 0; i < diffCount; i++) {
            [appVersionArr addObject:@"0"];
        }
    }
    return [appVersionArr componentsJoinedByString:@"."];
}

- (BOOL)jp_containsChinese {
    for (NSInteger i = 0; i < self.length; i++) {
        int a = [self characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)jp_isCardID {
    NSString* number = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", number];
    return [numberPre evaluateWithObject:self];
}

@end
