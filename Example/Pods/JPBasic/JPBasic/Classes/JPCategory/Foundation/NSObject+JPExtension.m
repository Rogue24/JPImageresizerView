//
//  NSObject+JPExtension.m
//  WoTV
//
//  Created by 周健平 on 2018/7/23.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import "NSObject+JPExtension.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "JPConstant.h"

@implementation NSObject (JPExtension)

+ (NSString *)jp_className {
    return NSStringFromClass(self);
}
- (NSString *)jp_className {
    return NSStringFromClass(self.class);
}

+ (BOOL)jp_isMetaClass {
    return class_isMetaClass(self);
}
+ (Class)jp_metaClass {
    return object_getClass(self);
}
- (Class)jp_metaClass {
    return [self.class jp_metaClass];
}

/*
 #define _C_ID          '@'    id
 #define _C_CLASS       '#'    class
 #define _C_SEL         ':'    SEL
 #define _C_CHR         'c'    char
 #define _C_UCHR        'C'    unsigned char
 #define _C_SHT         's'    shot
 #define _C_USHT        'S'    unsigned shot
 #define _C_INT         'i'    int
 #define _C_UINT        'I'    unsigned int
 #define _C_LNG         'l'    long
 #define _C_ULNG        'L'    unsigned long
 #define _C_LNG_LNG     'q'    long long
 #define _C_ULNG_LNG    'Q'    unsigned long long
 #define _C_FLT         'f'    float
 #define _C_DBL         'd'    double
 #define _C_BFLD        'b'
 #define _C_BOOL        'B'    BOOL
 #define _C_VOID        'v'    void
 #define _C_UNDEF       '?'
 #define _C_PTR         '^'
 #define _C_CHARPTR     '*'    char *
 #define _C_ATOM        '%'
 #define _C_ARY_B       '['    array begin
 #define _C_ARY_E       ']'    array end
 #define _C_UNION_B     '('    union begin
 #define _C_UNION_E     ')'    union end
 #define _C_STRUCT_B    '{'    struct begin
 #define _C_STRUCT_E    '}'    struct end
 #define _C_VECTOR      '!'
 #define _C_CONST       'r'
*/

+ (void)jp_lookIvarList {
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(self, &count);
    JPLog(@"=================== %@%@ IvarList start ===================", self.jp_className, self.jp_isMetaClass ? @"(MetaClass)" : @"");
    for (NSInteger i = 0; i < count; i++) {
        Ivar ivar = ivarList[i]; // ivars[i] 等价于 *(ivars+i)，指针挪位
        JPLog(@"%s --- %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    JPLog(@"=================== %@%@ IvarList end ===================", self.jp_className, self.jp_isMetaClass ? @"(MetaClass)" : @"");
    free(ivarList);
}
- (void)jp_lookIvarList {
    [self.class jp_lookIvarList];
}

+ (void)jp_lookPropertyList {
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(self, &count);
    JPLog(@"=================== %@%@ PropertyList start ===================", self.jp_className, self.jp_isMetaClass ? @"(MetaClass)" : @"");
    for (NSInteger i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        JPLog(@"%s --- %s", property_getName(property), property_getAttributes(property));
    }
    JPLog(@"=================== %@%@ PropertyList end ===================", self.jp_className, self.jp_isMetaClass ? @"(MetaClass)" : @"");
    free(propertyList);
}
- (void)jp_lookPropertyList {
    [self.class jp_lookPropertyList];
}

+ (void)jp_lookMethodList {
    unsigned int count;
    Method *methodList = class_copyMethodList(self, &count);
    JPLog(@"=================== %@%@ MethodList start ===================", self.jp_className, self.jp_isMetaClass ? @"(MetaClass)" : @"");
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        char retType[512] = {};
        method_getReturnType(method, retType, 512);
        JPLog(@"%s -> %s", sel_getName(method_getName(method)), retType);
    }
    JPLog(@"=================== %@%@ MethodList end ===================", self.jp_className, self.jp_isMetaClass ? @"(MetaClass)" : @"");
    free(methodList);
}
- (void)jp_lookMethodList {
    [self.class jp_lookMethodList];
}

+ (NSInteger)jp_instanceSize {
    return class_getInstanceSize(self);
}
- (NSInteger)jp_instanceSize {
    return [self.class jp_instanceSize];
}

- (NSInteger)jp_mallocSize {
    return malloc_size((__bridge const void *)self);
}

+ (void)jp_swizzleInstanceMethodsWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}
+ (void)jp_swizzleClassMethodsWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Class metaCls = object_getClass(self);
    Method originalMethod = class_getClassMethod(metaCls, originalSelector);
    Method swizzledMethod = class_getClassMethod(metaCls, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
