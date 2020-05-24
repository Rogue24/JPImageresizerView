//
//  NSDate+JPExtension.m
//  WoLive
//
//  Created by 周健平 on 2019/5/15.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import "NSDate+JPExtension.h"
#import "JPConstant.h"

@implementation NSDate (JPExtension)

+ (NSString *)jp_hhmmssStringWithTimeInt:(NSTimeInterval)timeInt {
    return [[self dateWithTimeIntervalSince1970:timeInt] jp_hhmmssString];
}

+ (NSString *)jp_hhmmssSSStringForCurrentDate {
    return [[self date] jp_hhmmssSSString];
}

- (NSString *)jp_hhmmssString {
    return [[JPConstant hhmmssFormatter] stringFromDate:self];
}

- (NSString *)jp_hhmmssSSString {
    return [[JPConstant hhmmssSSFormatter] stringFromDate:self];
}

- (NSDateComponents *)jp_ddHHmmssDeltaFromNow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unit fromDate:[NSDate date] toDate:self options:0];
    return components;
}


/**
 * 比较指定时间与自身时间的差值
 */
- (NSDateComponents *)jp_deltaFromDate:(NSDate *)fromDate {
    return [self.class jp_deltaFromDate:fromDate toDate:self];
}

- (NSDateComponents *)jp_deltaToDate:(NSDate *)toDate {
    return [self.class jp_deltaFromDate:self toDate:toDate];
}

+ (NSDateComponents *)jp_deltaFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    //日历对象
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    //NSDateComponents：能获取时间所有元素（年、月、日、时、分、秒....）的类
    NSDateComponents *components = [calendar components:unit fromDate:fromDate toDate:toDate options:0];
    
    return components;
}

@end
