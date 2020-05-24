//
//  JPTextLayoutTool.m
//  Infinitee2.0
//
//  Created by zhoujianping on 2017/8/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPTextLayoutTool.h"

@implementation JPTextLayoutTool

+ (YYTextLayout *)createOneLineTextLayoutWithText:(NSString *)text
                                        textColor:(UIColor *)textColor
                                             font:(UIFont *)font
                                        alignment:(NSTextAlignment)alignment
                                    lineBreakMode:(NSLineBreakMode)lineBreakMode
                                         maxWidth:(CGFloat)maxWidth
                                       lineHeight:(CGFloat)lineHeight {
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    attStr.yy_color = textColor;
    attStr.yy_font = font;
    attStr.yy_alignment = alignment;
    attStr.yy_lineBreakMode = lineBreakMode;
    
    JPTextLinePositionModifier *modifier = [JPTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:font.pointSize];
    modifier.paddingTop = (lineHeight - modifier.font.pointSize) * 0.5;
    modifier.paddingBottom = modifier.paddingTop;
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxWidth, 999)];
    container.maximumNumberOfRows = 1;
    container.linePositionModifier = modifier;
    
    return [YYTextLayout layoutWithContainer:container text:attStr];
}

+ (YYTextLayout *)createTextLayoutWithText:(NSString *)text
                                 textColor:(UIColor *)textColor
                                      font:(UIFont *)font
                                 alignment:(NSTextAlignment)alignment
                             lineBreakMode:(NSLineBreakMode)lineBreakMode
                                verPadding:(CGFloat)verPadding
                                  maxWidth:(CGFloat)maxWidth
                                       row:(NSInteger)row {
    YYTextLayout *textLayout;
    [self getTextHeightAndCreateTextLayoutWithText:text
                                         textColor:textColor
                                              font:font
                                         alignment:alignment
                                     lineBreakMode:lineBreakMode
                                        verPadding:verPadding
                                          maxWidth:maxWidth
                                               row:row
                                        textLayout:&textLayout];
    return textLayout;
}

+ (CGFloat)getTextHeightAndCreateTextLayoutWithText:(NSString *)text
                                          textColor:(UIColor *)textColor
                                               font:(UIFont *)font
                                          alignment:(NSTextAlignment)alignment
                                      lineBreakMode:(NSLineBreakMode)lineBreakMode
                                         verPadding:(CGFloat)verPadding
                                           maxWidth:(CGFloat)maxWidth
                                                row:(NSInteger)row
                                         textLayout:(YYTextLayout **)textLayout {
    NSMutableAttributedString *aText = [[NSMutableAttributedString alloc] initWithString:text];
    aText.yy_font = font;
    aText.yy_color = textColor;
    aText.yy_alignment = alignment;
    aText.yy_lineBreakMode = row == 0 ? NSLineBreakByCharWrapping : lineBreakMode;
    return [self getTextHeightAndCreateTextLayoutWithAttText:aText verPadding:verPadding maxWidth:maxWidth row:row textLayout:textLayout];
}

+ (CGFloat)getTextHeightAndCreateTextLayoutWithAttText:(NSAttributedString *)attText
                                            verPadding:(CGFloat)verPadding
                                              maxWidth:(CGFloat)maxWidth
                                                   row:(NSInteger)row
                                            textLayout:(YYTextLayout **)textLayout {
    JPTextLinePositionModifier *modifier = [JPTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:attText.yy_font.pointSize];
    modifier.paddingTop = verPadding;
    modifier.paddingBottom = verPadding;
    
    // 创建文本容器
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxWidth, 999)];
    container.maximumNumberOfRows = row;
    container.linePositionModifier = modifier;
    
    // 生成排版结果
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attText];
    CGFloat height = 0;
    if (layout) {
        height = [modifier heightForLineCount:layout.rowCount];
        *textLayout = layout;
    }
    return height;
}

+ (YYTextLayout *)createOneLineTextLayoutWithAttText:(NSAttributedString *)attText
                                            maxWidth:(CGFloat)maxWidth
                                          lineHeight:(CGFloat)lineHeight {
    JPTextLinePositionModifier *modifier = [JPTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:attText.yy_font.pointSize];
    modifier.paddingTop = (lineHeight - modifier.font.pointSize) * 0.5;
    modifier.paddingBottom = modifier.paddingTop;
    
    // 创建文本容器
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(maxWidth, 999)];
    container.maximumNumberOfRows = 1;
    container.linePositionModifier = modifier;
    
    // 生成排版结果
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attText];
    return layout;
}

+ (YYTextLayout *)createTextLayoutWithText:(NSString *)text parameter:(JPTextLayoutParameter *)parameter {
    YYTextLayout *textLayout;
    [self getTextHeightAndCreateTextLayoutWithText:text
                                         parameter:parameter
                                        textLayout:&textLayout];
    return textLayout;
}

+ (CGFloat)getTextHeightAndCreateTextLayoutWithText:(NSString *)text
                                          parameter:(JPTextLayoutParameter *)parameter
                                         textLayout:(YYTextLayout **)textLayout {
    return [self getTextHeightAndCreateTextLayoutWithText:text
                                                     textColor:parameter.textColor
                                                     font:parameter.font
                                                alignment:parameter.alignment
                                            lineBreakMode:parameter.lineBreakMode
                                               verPadding:parameter.verPadding
                                                 maxWidth:parameter.maxWidth
                                                      row:parameter.row
                                               textLayout:textLayout];
}

@end

@implementation JPTextLayoutParameter

@end

/*
 将每行的 baseline 位置固定下来，不受不同字体的 ascent/descent 影响。
 
 注意，Heiti SC 中，    ascent + descent = font size，
 但是在 PingFang SC 中，ascent + descent > font size。
 所以这里统一用 Heiti SC (0.86 ascent, 0.14 descent) 作为顶部和底部标准，保证不同系统下的显示一致性。
 间距仍然用字体默认
 */
@implementation JPTextLinePositionModifier

- (instancetype)init {
    if (self = [super init]) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            _lineHeightMultiple = 1.34;   // for PingFang SC
        } else {
            _lineHeightMultiple = 1.3125; // for Heiti SC
        }
    }
    return self;
}

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(YYTextContainer *)container {
    //CGFloat ascent = _font.ascender;
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (YYTextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    JPTextLinePositionModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount {
    if (lineCount == 0) return 0;
    //    CGFloat ascent = _font.ascender;
    //    CGFloat descent = -_font.descender;
    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat descent = _font.pointSize * 0.14;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    return _paddingTop + _paddingBottom + ascent + descent + (lineCount - 1) * lineHeight;
}

@end
