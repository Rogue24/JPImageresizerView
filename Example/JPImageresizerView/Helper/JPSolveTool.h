//
//  JPSolveTool.h
//  Infinitee2.0
//
//  Created by guanning on 2017/5/5.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPSolveTool : NSObject

/**
 * 计算文本区域（一行）
 */
+ (CGRect)oneLineTextFrameWithText:(NSString *)text font:(UIFont *)font;

/**
 * 计算文本区域
 */
+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                       font:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace;

/**
 * 计算文本区域（返回是否超过一行）
 */
+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                       font:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                  isOneLine:(BOOL *)isOneLine;

/**
 * 带富文本属性计算文本区域
 */
+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                 attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;

/**
 * 带富文本属性计算文本区域（返回是否超过一行）
 */
+ (CGRect)textFrameWithText:(NSString *)text
                    maxSize:(CGSize)maxSize
                 attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes
                  isOneLine:(BOOL *)isOneLine;

/**
 * 计算富文本区域（一行）
 */
+ (CGRect)oneLineAttTextFrameWithText:(NSAttributedString *)attText;

/**
 * 计算富文本区域
 */
+ (CGRect)attTextFrameWithText:(NSAttributedString *)attText maxSize:(CGSize)maxSize;

/**
 * 计算富文本区域（返回是否超过一行）
 */
+ (CGRect)attTextFrameWithText:(NSAttributedString *)attText maxSize:(CGSize)maxSize isOneLine:(BOOL *)isOneLine;

/**
 * 计算半径
 */
+ (CGFloat)radiusFromCenter:(CGPoint)center point:(CGPoint)point;

/**
 * 计算一个点经旋转一定角度后的点
 */
+ (CGPoint)afterRotationPointWithStartPoint:(CGPoint)startPoint centerPoint:(CGPoint)centerPoint angle:(CGFloat)angle;

/**
 * 年份转中文
 */
+ (NSString *)yearNumber2Chinese:(NSInteger)yearNum;

/**
 * 月份转中文
 */
+ (NSString *)monthNumber2Chinese:(NSInteger)monthNum;

/**
 * 金额格式
 */
+ (NSString *)amountFormat:(double)amount;

/**
 * 银行卡号格式
 */
+ (NSString *)bankCardFormat:(NSString *)bankCardNum;

/**
 * 每隔一定间距插入一个字符
 */
+ (NSString *)insertForString:(NSString *)string insertStr:(NSString *)insertStr digit:(NSInteger)digit;

/**
 * 计算scrollView翻页进度
 * return BOOL
    - NO  -> 进度没有变化，别更新
    - YES -> 更新
 */
+ (BOOL)pageScrollProgressWithScrollView:(UIScrollView *)scrollView
                        isVerticalScroll:(BOOL)isVerticalScroll
                        startOffsetValue:(CGFloat *)startOffsetValue
                             currentPage:(NSInteger *)currentPage
                              sourcePage:(NSInteger *)sourcePage
                              targetPage:(NSInteger *)targetPage
                                progress:(CGFloat *)progress;

/**
 * 计算scrollView翻页进度（自定义各参数）
 * return BOOL
    - NO  -> 进度没有变化，别更新
    - YES -> 更新
 */
+ (BOOL)pageScrollProgressWithPageSizeValue:(CGFloat)pageSizeValue
                                  pageCount:(NSInteger)pageCount
                                offsetValue:(CGFloat)offsetValue
                             maxOffsetValue:(CGFloat)maxOffsetValue
                           startOffsetValue:(CGFloat *)startOffsetValue
                                currentPage:(NSInteger *)currentPage
                                 sourcePage:(NSInteger *)sourcePage
                                 targetPage:(NSInteger *)targetPage
                                   progress:(CGFloat *)progress;

+ (NSInteger)hourPart:(NSInteger)totalTime;
+ (NSInteger)minutePart:(NSInteger)totalTime;
+ (NSInteger)secondPart:(NSInteger)totalTime;

+ (NSString *)digit2ThousandStr:(NSInteger)number;

+ (UIEdgeInsets)screenInsets:(UIInterfaceOrientation)statusBarOrientation;
@end
