//
//  JPSolveTool.m
//  Infinitee2.0
//
//  Created by guanning on 2017/5/5.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPSolveTool.h"
#import "NSString+JPExtension.h"

@implementation JPSolveTool

+ (CGRect)oneLineTextFrameWithText:(NSString *)text font:(UIFont *)font {
    return [self textFrameWithText:text maxSize:CGSizeMake(999, 999) font:font lineSpace:0 isOneLine:nil];
}

+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                       font:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace {
    return [self textFrameWithText:text maxSize:maxSize font:font lineSpace:lineSpace isOneLine:nil];
}

+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                       font:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                  isOneLine:(BOOL *)isOneLine {
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    if (lineSpace > 0) {
        NSMutableParagraphStyle *parag = [[NSMutableParagraphStyle alloc] init];
        parag.lineSpacing = lineSpace;
        attributes[NSParagraphStyleAttributeName] = parag;
    }
    
    CGRect rect = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];

    // 文本的高度 - 字体高度 > 行间距 -----> 判断为当前超过1行
    BOOL isMoreThanOneLine = (rect.size.height - font.lineHeight) > lineSpace;
    if (!isMoreThanOneLine) {
        if ([text jp_containsChinese]) {  //如果包含中文
            rect.size.height -= lineSpace;
        }
    }
    
    if (rect.size.height > 0 && rect.size.height < font.pointSize) {
        rect.size.height = font.pointSize;
    }
    
    if (isOneLine) *isOneLine = !isMoreThanOneLine;

    return rect;
}

+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                 attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    return [self textFrameWithText:text maxSize:maxSize attributes:attributes isOneLine:nil];
}

+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                 attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                  isOneLine:(BOOL *)isOneLine {
    
    // 要使用默认的不带省略号的NSLineBreakByWordWrappings来进行计算，才能算出真正高度
    // 如果用带有省略号的例如"abcd..."这种模式，计算出来的只是一行的高度
    NSMutableParagraphStyle *parag = attributes[NSParagraphStyleAttributeName];
    NSLineBreakMode lineBreakMode = parag.lineBreakMode; // 先记住原本的lineBreakMode
    parag.lineBreakMode = NSLineBreakByWordWrapping;

    CGRect rect = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];

    // 还原lineBreakMode，鬼知道是不是还引用着它
    parag.lineBreakMode = lineBreakMode;
    
    CGFloat lineSpace = parag.lineSpacing;
    UIFont *font = attributes[NSFontAttributeName];
    // 文本的高度 - 字体高度 > 行间距 -----> 判断为当前超过1行
    BOOL isMoreThanOneLine = (rect.size.height - font.lineHeight) > lineSpace;
    if (!isMoreThanOneLine) {
        if ([text jp_containsChinese]) {  //如果包含中文
            rect.size.height -= lineSpace;
        }
    }
    
    if (rect.size.height > 0 && rect.size.height < font.pointSize) {
        rect.size.height = font.pointSize;
    }
    
    if (isOneLine) *isOneLine = !isMoreThanOneLine;
    
    return rect;
}

+ (CGRect)oneLineAttTextFrameWithText:(NSAttributedString *)attText {
    return [self attTextFrameWithText:attText maxSize:CGSizeMake(999, 999)];
}

+ (CGRect)attTextFrameWithText:(NSAttributedString *)attText maxSize:(CGSize)maxSize {
    return [self attTextFrameWithText:attText maxSize:maxSize isOneLine:nil];
}

+ (CGRect)attTextFrameWithText:(NSAttributedString *)attText maxSize:(CGSize)maxSize isOneLine:(BOOL *)isOneLine {
    CGRect rect;
    CGFloat lineSpace = 0;
    NSMutableParagraphStyle *parag = [attText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
    if (parag) {
        lineSpace = parag.lineSpacing;
        
        // 要使用默认的不带省略号的NSLineBreakByWordWrappings来进行计算，才能算出真正高度
        // 如果用带有省略号的例如"abcd..."这种模式，计算出来的只是一行的高度
        NSLineBreakMode lineBreakMode = parag.lineBreakMode; // 先记住原本的lineBreakMode
        parag.lineBreakMode = NSLineBreakByWordWrapping;
        
        rect = [attText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        // 还原lineBreakMode，鬼知道是不是还引用着它
        parag.lineBreakMode = lineBreakMode;
    } else {
        rect = [attText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    }
    
    UIFont *font = [attText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    // 文本的高度 - 字体高度 > 行间距 -----> 判断为当前超过1行
    BOOL isMoreThanOneLine = (rect.size.height - font.lineHeight) > lineSpace;
    if (!isMoreThanOneLine) {
        if ([attText.string jp_containsChinese]) {  //如果包含中文
            rect.size.height -= lineSpace;
        }
    }
    
    if (rect.size.height > 0 && rect.size.height < font.pointSize) {
        rect.size.height = font.pointSize;
    }
    
    if (isOneLine) *isOneLine = !isMoreThanOneLine;
    
    return rect;
}

+ (CGFloat)radiusFromCenter:(CGPoint)center point:(CGPoint)point {
     return sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2));
}

+ (CGPoint)afterRotationPointWithStartPoint:(CGPoint)startPoint centerPoint:(CGPoint)centerPoint angle:(CGFloat)angle {
    
    CGFloat startX = startPoint.x;
    CGFloat startY = startPoint.y;
    
    CGFloat centerX = centerPoint.x;
    CGFloat centerY = centerPoint.y;
    
    CGFloat radian = angle / 180.0 * M_PI;
    
    CGFloat x = (startX - centerX) * cos(radian) - (startY - centerY) * sin(radian) + centerX;
    CGFloat y = (startX - centerX) * sin(radian) + (startY - centerY) * cos(radian) + centerY;
    
    return CGPointMake(x, y);
    
}

+ (NSString *)yearNumber2Chinese:(NSInteger)yearNum {
    
    NSInteger count = 0;
    NSInteger yearNum2 = yearNum;
    do {
        yearNum2 = yearNum2 / 10;
        count += 1;
    } while (yearNum2 > 0);
    
    NSMutableString *yearStr = [NSMutableString string];
    for (NSInteger i = count - 1; i >= 0; i--) {
        NSInteger oneNum = (NSInteger)(yearNum / pow(10, i)) % 10;
        [yearStr appendString:[self number2Chinese:oneNum]];
    }
    
    return yearStr;
}

+ (NSString *)monthNumber2Chinese:(NSInteger)monthNum {
    return [self number2Chinese:monthNum];
}

+ (NSString *)number2Chinese:(NSInteger)number {
    switch (number) {
        case 0:
            return @"零";
        case 1:
            return @"一";
        case 2:
            return @"二";
        case 3:
            return @"三";
        case 4:
            return @"四";
        case 5:
            return @"五";
        case 6:
            return @"六";
        case 7:
            return @"七";
        case 8:
            return @"八";
        case 9:
            return @"九";
        case 10:
            return @"十";
        case 11:
            return @"十一";
        case 12:
            return @"十二";
        default:
            return @"";
    }
}

+ (NSString *)amountFormat:(double)amount {
    
    if (amount <= 0) return @"0.00";
    
    NSString *amountStr = [NSString stringWithFormat:@"%.2lf", amount];
    
    NSString *leftPartStr = [amountStr componentsSeparatedByString:@"."].firstObject;
    NSString *rightPartStr = [amountStr componentsSeparatedByString:@"."].lastObject;
    
    return [NSString stringWithFormat:@"%@.%@", [self insertForString:leftPartStr insertStr:@"," digit:3], rightPartStr];
}

+ (NSString *)bankCardFormat:(NSString *)bankCardNum {
    return [self insertForString:bankCardNum insertStr:@" " digit:4];
}

+ (NSString *)insertForString:(NSString *)string insertStr:(NSString *)insertStr digit:(NSInteger)digit {
    NSInteger digitsCount = string.length / digit;
    if (digitsCount) {
        NSInteger insertCount = string.length % digit == 0 ? (digitsCount - 1) : digitsCount;
        if (insertCount) {
            NSInteger insertStrL = insertStr.length;
            NSMutableString *mutableStr = [NSMutableString stringWithString:string];
            for (NSInteger i = 1; i <= insertCount; i++) {
                NSInteger index = (mutableStr.length - 1) - (digit - 1) - (i - 1) * (digit + insertStrL);
                [mutableStr insertString:insertStr atIndex:index];
            }
            return mutableStr;
        } else {
            return string;
        }
    } else {
        return string;
    }
}

+ (BOOL)pageScrollProgressWithScrollView:(UIScrollView *)scrollView
                        isVerticalScroll:(BOOL)isVerticalScroll
                        startOffsetValue:(CGFloat *)startOffsetValue
                             currentPage:(NSInteger *)currentPage
                              sourcePage:(NSInteger *)sourcePage
                              targetPage:(NSInteger *)targetPage
                                progress:(CGFloat *)progress {
    CGFloat pageSize;
    NSInteger pageCount;
    CGFloat offsetValue;
    if (isVerticalScroll) {
        pageSize = scrollView.bounds.size.height;
        pageCount = scrollView.contentSize.height / pageSize;
        offsetValue = scrollView.contentOffset.y;
    } else {
        pageSize = scrollView.bounds.size.width;
        pageCount = scrollView.contentSize.width / pageSize;
        offsetValue = scrollView.contentOffset.x;
    }
    CGFloat maxOffsetValue = pageSize * (pageCount - 1);
    return [self pageScrollProgressWithPageSizeValue:pageSize
                                           pageCount:pageCount
                                         offsetValue:offsetValue
                                      maxOffsetValue:maxOffsetValue
                                    startOffsetValue:startOffsetValue
                                         currentPage:currentPage
                                          sourcePage:sourcePage
                                          targetPage:targetPage
                                            progress:progress];
}

+ (BOOL)pageScrollProgressWithPageSizeValue:(CGFloat)pageSizeValue
                                  pageCount:(NSInteger)pageCount
                                offsetValue:(CGFloat)offsetValue
                             maxOffsetValue:(CGFloat)maxOffsetValue
                           startOffsetValue:(CGFloat *)startOffsetValue
                                currentPage:(NSInteger *)currentPage
                                 sourcePage:(NSInteger *)sourcePage
                                 targetPage:(NSInteger *)targetPage
                                   progress:(CGFloat *)progress {
    
    if (offsetValue < 0) {
        offsetValue = 0;
    } else if (offsetValue > maxOffsetValue) {
        offsetValue = maxOffsetValue;
    }
    
    CGFloat kStartOffsetValue = *startOffsetValue;
    if (offsetValue == kStartOffsetValue) {
        return NO;
    }
    
    NSInteger kSourcePage = 0;
    NSInteger kTargetPage = 0;
    CGFloat kProgress = 0;
    
    // 滑动位置与初始位置的距离
    CGFloat offsetDistance = fabs(offsetValue - kStartOffsetValue);
    
    if (offsetValue > kStartOffsetValue) {
        // 左/上滑动
        kSourcePage = (NSInteger)(offsetValue / pageSizeValue);
        kTargetPage = kSourcePage + 1;
        kProgress = offsetDistance / pageSizeValue;
        if (kProgress >= 1) {
            if (kTargetPage == pageCount) {
                kProgress = 1;
                kTargetPage -= 1;
                kSourcePage -= 1;
            } else {
                kProgress = 0;
            }
        }
    } else {
        // 右/下滑动
        kTargetPage = (NSInteger)(offsetValue / pageSizeValue);
        kSourcePage = kTargetPage + 1;
        kProgress = offsetDistance / pageSizeValue;
        if (kProgress > 1) {
            if (kSourcePage == pageCount) {
                kProgress = 1;
                kTargetPage -= 1;
                kSourcePage -= 1;
            } else {
                kProgress = 0;
            }
        }
    }
    
    if (offsetDistance >= pageSizeValue) {
        NSInteger kCurrentPage = (NSInteger)((offsetValue + pageSizeValue * 0.5) / pageSizeValue);
        kStartOffsetValue = pageSizeValue * (CGFloat)kCurrentPage;
        *currentPage = kCurrentPage;
        *startOffsetValue = kStartOffsetValue;
    }
    
    *sourcePage = kSourcePage;
    *targetPage = kTargetPage;
    *progress = kProgress;
    
    return YES;
}

+ (NSInteger)hourPart:(NSInteger)totalTime {
    return totalTime / 3600;
}

+ (NSInteger)minutePart:(NSInteger)totalTime {
    return (totalTime / 60) % 60;
}

+ (NSInteger)secondPart:(NSInteger)totalTime {
    return totalTime % 60;
}

+ (NSString *)digit2ThousandStr:(NSInteger)number {
    CGFloat floatNumber = (CGFloat)number;
    floatNumber /= 10000.0;
    if (floatNumber >= 1) {
        return [NSString stringWithFormat:@"%.2lfw", floatNumber];
    } else {
        return [NSString stringWithFormat:@"%zd", number];
    }
}

@end
