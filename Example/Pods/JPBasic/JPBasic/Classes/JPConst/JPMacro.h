//
//  JPMacro.h
//  WoTV
//
//  Created by 周健平 on 2018/4/12.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#ifndef JPMacro_h
#define JPMacro_h

/** mainScreen */
#define JPScreenBounds [UIScreen mainScreen].bounds
#define JPScreenSize [UIScreen mainScreen].bounds.size
#define JPScreenWidth [UIScreen mainScreen].bounds.size.width
#define JPScreenHeight [UIScreen mainScreen].bounds.size.height

/** 导航栏控件偏移量（iOS 11以前） */
// 6p：20 -> 15
// 6p以下：16 -> 10
#define JPNaviFixedSpace (MIN(JPScreenWidth, JPScreenHeight) > 375.0 ? -5 : -1)

/** 主窗口 */
#define JPKeyWindow [UIApplication sharedApplication].delegate.window
#define JPMakeKeyWindow [[UIApplication sharedApplication].delegate.window makeKeyWindow]

/** keypath */
#define JPKeyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))

/** 发送通知 */
#define JPPostNotification(name, obj, info) [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo:info]

/** 监听通知 */
#define JPObserveNotification(observer, aSelector, aName, obj) [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:obj]

/** 移除通知 */
#define JPRemoveNotification(observer) [[NSNotificationCenter defaultCenter] removeObserver:observer]
#define JPRemoveOneNotification(observer, aName, obj) [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:obj]

/** MainBundle */
#define JPMainBundle [NSBundle mainBundle]
#define JPMainBundleResourcePath(name, type) [[NSBundle mainBundle] pathForResource:name ofType:type]

/** 单例（声明） */
#define JPSingtonInterface + (instancetype)sharedInstance;
/** 单例（实现） */
#define JPSingtonImplement(class) \
\
static class *sharedInstance_; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        sharedInstance_ = [super allocWithZone:zone]; \
    }); \
    return sharedInstance_; \
} \
\
+ (instancetype)sharedInstance { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        sharedInstance_ = [[class alloc] init]; \
    }); \
    return sharedInstance_; \
} \
\
- (id)copyWithZone:(NSZone *)zone { \
    return sharedInstance_; \
}

/** weakSelf */
#ifndef jp_weakify
#if DEBUG
#if __has_feature(objc_arc)
#define jp_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define jp_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define jp_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define jp_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

/** strongSelf */
#ifndef jp_strongify
#if DEBUG
#if __has_feature(objc_arc)
#define jp_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define jp_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define jp_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define jp_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* JPMacro_h */
