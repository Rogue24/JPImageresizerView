//
//  NSDate+JPExtension.h
//  WoLive
//
//  Created by 周健平 on 2019/5/15.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JPExtension)
+ (NSString *)jp_hhmmssStringWithTimeInt:(NSTimeInterval)timeInt;
+ (NSString *)jp_hhmmssSSStringForCurrentDate;
- (NSString *)jp_hhmmssString;
- (NSString *)jp_hhmmssSSString;
- (NSDateComponents *)jp_ddHHmmssDeltaFromNow;

- (NSDateComponents *)jp_deltaFromDate:(NSDate *)fromDate;
- (NSDateComponents *)jp_deltaToDate:(NSDate *)toDate;
+ (NSDateComponents *)jp_deltaFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
@end
