//
//  JPTextLayoutTool.h
//  Infinitee2.0
//
//  Created by zhoujianping on 2017/8/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYText/YYText.h>
@class JPTextLayoutParameter;
@class JPTextLinePositionModifier;

@interface JPTextLayoutTool : NSObject

+ (YYTextLayout *)createOneLineTextLayoutWithText:(NSString *)text
                                        textColor:(UIColor *)textColor
                                             font:(UIFont *)font
                                        alignment:(NSTextAlignment)alignment
                                    lineBreakMode:(NSLineBreakMode)lineBreakMode
                                         maxWidth:(CGFloat)maxWidth
                                       lineHeight:(CGFloat)lineHeight;

+ (YYTextLayout *)createTextLayoutWithText:(NSString *)text
                                 textColor:(UIColor *)textColor
                                      font:(UIFont *)font
                                 alignment:(NSTextAlignment)alignment
                             lineBreakMode:(NSLineBreakMode)lineBreakMode
                                verPadding:(CGFloat)verPadding
                                  maxWidth:(CGFloat)maxWidth
                                       row:(NSInteger)row;

+ (CGFloat)getTextHeightAndCreateTextLayoutWithText:(NSString *)text
                                          textColor:(UIColor *)textColor
                                               font:(UIFont *)font
                                          alignment:(NSTextAlignment)alignment
                                      lineBreakMode:(NSLineBreakMode)lineBreakMode
                                         verPadding:(CGFloat)verPadding
                                           maxWidth:(CGFloat)maxWidth
                                                row:(NSInteger)row
                                         textLayout:(YYTextLayout **)textLayout;

+ (CGFloat)getTextHeightAndCreateTextLayoutWithAttText:(NSAttributedString *)attText
                                            verPadding:(CGFloat)verPadding
                                              maxWidth:(CGFloat)maxWidth
                                                   row:(NSInteger)row
                                            textLayout:(YYTextLayout **)textLayout;

+ (YYTextLayout *)createOneLineTextLayoutWithAttText:(NSAttributedString *)attText
                                            maxWidth:(CGFloat)maxWidth
                                          lineHeight:(CGFloat)lineHeight;

+ (YYTextLayout *)createTextLayoutWithText:(NSString *)text
                                 parameter:(JPTextLayoutParameter *)parameter;

+ (CGFloat)getTextHeightAndCreateTextLayoutWithText:(NSString *)text
                                          parameter:(JPTextLayoutParameter *)parameter
                                         textLayout:(YYTextLayout **)textLayout;

@end

@interface JPTextLayoutParameter : NSObject
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSTextAlignment alignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) CGFloat verPadding;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) NSInteger row;
@end

/**
 * YYTextLinePositionModifier
    - 对每行排版进行赋值，统一行高
    - 文本 Line 位置修改
    - 将每行文本的高度和位置固定下来，不受中英文/Emoji字体的 ascent/descent 影响
 */
@interface JPTextLinePositionModifier : NSObject <YYTextLinePositionModifier>
@property (nonatomic, strong) UIFont *font; // 基准字体 (例如 Heiti SC/PingFang SC)
@property (nonatomic, assign) CGFloat paddingTop; //文本顶部留白
@property (nonatomic, assign) CGFloat paddingBottom; //文本底部留白
@property (nonatomic, assign) CGFloat lineHeightMultiple; //行距倍数
- (CGFloat)heightForLineCount:(NSUInteger)lineCount;
@end
