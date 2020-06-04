//
//  JPInline.h
//  Pods
//
//  Created by 周健平 on 2020/6/4.
//
// 【内联函数】

#import "JPConstant.h"

/**
 * 获取当前页码
 */
CG_INLINE NSInteger JPGetCurrentPageNumber(CGFloat offsetValue, CGFloat pageSizeValue) {
    return (NSInteger)((offsetValue + pageSizeValue * 0.5) / pageSizeValue);
}

/**
 * 弧度 --> 角度（ π --> 180° ）
 */
CG_INLINE CGFloat JPRadian2Angle(CGFloat radian) {
    return (radian * 180.0) / M_PI;
}

/**
 * 角度 --> 弧度（ 180° -->  π  ）
 */
CG_INLINE CGFloat JPAngle2Radian(CGFloat angle) {
    return (angle / 180.0) * M_PI;
}

/**
 * rect.origin.x
 */
CG_INLINE CGFloat JPRectX(CGRect rect) {
    return rect.origin.x;
}

/**
 * rect.origin.y
 */
CG_INLINE CGFloat JPRectY(CGRect rect) {
    return rect.origin.y;
}

/**
 * rect.size.width
 */
CG_INLINE CGFloat JPRectW(CGRect rect) {
    return rect.size.width;
}

/**
 * rect.size.height
 */
CG_INLINE CGFloat JPRectH(CGRect rect) {
    return rect.size.height;
}

/**
 * 随机整数（from <= number <= to）
 */
CG_INLINE NSInteger JPRandomNumber(NSInteger from, NSInteger to) {
    return (NSInteger)(from + (arc4random() % (to - from + 1)));
}

/**
 * 随机布尔值（YES or NO）
 */
CG_INLINE BOOL JPRandomBool() {
    return JPRandomNumber(0, 1);
}

/**
 * 随机比例值（0.0 ~ 1.0）
 */
CG_INLINE CGFloat JPRandomUnsignedScale() {
    return JPRandomNumber(0, 100) * 1.0 / 100.0;
}

/**
 * 随机比例值（-1.0 ~ 1.0）
 */
CG_INLINE CGFloat JPRandomScale() {
    return (JPRandomBool() ? 1.0 : -1.0) * JPRandomUnsignedScale();
}

/**
 * 随机小写字母（a ~ z）
 */
CG_INLINE NSString * JPRandomLowercaseLetters() {
    char data[1];
    data[0] = (char)('a' + JPRandomNumber(0, 25));
    return [[NSString alloc] initWithBytes:data length:1 encoding:NSUTF8StringEncoding];
}

/**
 * 随机大写字母（A ~ Z）
 */
CG_INLINE NSString * JPRandomCapitalLetter() {
    char data[1];
    data[0] = (char)('A' + JPRandomNumber(0, 25));
    return [[NSString alloc] initWithBytes:data length:1 encoding:NSUTF8StringEncoding];
}

CG_INLINE CGFloat JPFromSourceToTargetValueByDifferValue(CGFloat sourceValue, CGFloat differValue, CGFloat progress) {
    return sourceValue + progress * differValue;
}

CG_INLINE CGFloat JPFromSourceToTargetValue(CGFloat sourceValue, CGFloat targetValue, CGFloat progress) {
    return JPFromSourceToTargetValueByDifferValue(sourceValue, (targetValue - sourceValue), progress);
}

CG_INLINE CGFloat JPHalfOfDiff(CGFloat value1, CGFloat value2) {
    return (value1 - value2) * 0.5;
}

CG_INLINE CGFloat JPScaleValue(CGFloat value) {
    return value * JPScale;
}

CG_INLINE CGFloat JPHScaleValue(CGFloat value) {
    return value * JPHScale;
}

CG_INLINE UIFont * JPScaleFont(CGFloat fontSize)  {
    return [UIFont systemFontOfSize:JPScaleValue(fontSize)];
}

CG_INLINE UIFont * JPScaleBoldFont(CGFloat fontSize) {
    return [UIFont boldSystemFontOfSize:JPScaleValue(fontSize)];
}

CG_INLINE UIFont * JPScaleOswaldMediumFont(CGFloat fontSize) {
    return [UIFont fontWithName:@"Oswald-Medium" size:JPScaleValue(fontSize)];
}
