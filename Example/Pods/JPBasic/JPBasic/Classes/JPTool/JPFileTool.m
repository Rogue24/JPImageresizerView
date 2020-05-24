//
//  JPFileTool.m
//  Infinitee2.0
//
//  Created by guanning on 2017/6/9.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPFileTool.h"
#import <CoreText/CoreText.h>
#include <sys/param.h>
#include <sys/mount.h>

@implementation JPFileTool

+ (BOOL)createDirectoryAtPath:(NSString *)path {
    if (![self fileExists:path]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        return YES;
    }
}

+ (BOOL)fileExists:(NSString *)filePath {
    if (filePath.length == 0) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL)moveFile:(NSString *)fromPath toPath:(NSString *)toPath {
    if (![self fileExists:fromPath]) return NO;
    return [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (BOOL)removeFile:(NSString *)filePath {
    if (![self fileExists:filePath]) return YES;
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

// 手机剩余空间
+ (long long)freeDiskSpaceInBytes {
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
    
}

// 手机总空间
+ (long long)totalDiskSpaceInBytes {
    struct statfs buf;
    long long freespace = 0;
    if (statfs("/", &buf) >= 0) {
        freespace = (long long)buf.f_bsize * buf.f_blocks;
    }
    if (statfs("/private/var", &buf) >= 0) {
        freespace += (long long)buf.f_bsize * buf.f_blocks;
    }
    printf("%lld\n",freespace);
    return freespace;
}

// 文件大小
+ (unsigned long long)fileSize:(NSString *)filePath {
    if (![self fileExists:filePath]) return 0;
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [fileInfo fileSize];
}

+ (void)enumeratorAtPath:(NSString *)path enumeratorBlock:(BOOL(^)(NSString *, NSString *))enumeratorBlock {
    if (!enumeratorBlock) return;
    // 创建文件遍历器（遍历该文件夹里面的所有文件名）
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:path];
    for (NSString *fileName in fileEnumerator) {
        if (enumeratorBlock(fileName, [path stringByAppendingPathComponent:fileName])) {
            break;
        }
    }
}

+ (unsigned long long)calculateFolderSize:(NSString *)folderPath {
    __block unsigned long long size = 0;
    [self enumeratorAtPath:folderPath enumeratorBlock:^BOOL(NSString *fileName, NSString *filePath) {
        // 获取文件属性（文件大小、创建日期等，但不能获取整个文件夹所有属性(不准确)，只能获取单个）
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        // 根据NSDictionary的文件类型属性判断，判断文件是不是文件夹，是就跳过
        if (![attrs.fileType isEqualToString:NSFileTypeDirectory]) size += [attrs fileSize];
        return NO;
    }];
    return size;
}

+ (void)clearFolder:(NSString *)folderPath {
    [self clearFolder:folderPath isAboutSubFolder:YES];
}

+ (void)clearFolder:(NSString *)folderPath isAboutSubFolder:(BOOL)isAboutSubFolder {
    [self enumeratorAtPath:folderPath enumeratorBlock:^BOOL(NSString *fileName, NSString *filePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory;
        if ([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
            if (isAboutSubFolder) {
                [fileManager removeItemAtPath:filePath error:nil];
            } else {
                if (isDirectory) {
                    [self clearFolder:filePath isAboutSubFolder:isAboutSubFolder];
                } else {
                    [fileManager removeItemAtPath:filePath error:nil];
                }
            }
        }
        return NO;
    }];
}

#pragma mark - 归档、解档

+ (BOOL)archiveWithRootObject:(id)obj filePath:(NSString *)filePath {
    if (@available(iOS 11.0, *)) {
        NSError *error;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:YES error:&error];
        if (error) {
            NSLog(@"归档失败：%@", error);
            return NO;
        }
        return data ? [data writeToFile:filePath atomically:YES] : NO;
    } else {
        return [NSKeyedArchiver archiveRootObject:obj toFile:filePath];
    }
}

+ (id)unarchivedObjectOfClass:(Class)cls filePath:(NSString *)filePath {
    return [self unarchivedObjectWithClassType:cls filePath:filePath];
}

+ (id)unarchivedObjectOfClasses:(NSSet<Class> *)clses filePath:(NSString *)filePath {
    return [self unarchivedObjectWithClassType:clses filePath:filePath];
}

+ (id)unarchivedObjectWithClassType:(id)classType filePath:(NSString *)filePath {
    if (![self fileExists:filePath]) {
        return nil;
    }
    if (@available(iOS 11.0, *)) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (!data) {
            return nil;
        }
        id obj;
        NSError *error;
        if ([classType isKindOfClass:NSSet.class]) {
            obj = [NSKeyedUnarchiver unarchivedObjectOfClasses:classType fromData:data error:&error];
        } else {
            obj = [NSKeyedUnarchiver unarchivedObjectOfClass:classType fromData:data error:&error];
        }
        if (error) {
            NSLog(@"解档失败：%@", error);
            return nil;
        }
        return obj;
    } else {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
}

#pragma mark - 字体
+ (NSString *)registerFontWithFilePath:(NSString *)filePath {
    if (![self fileExists:filePath]) return nil;
    
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath]);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    CGDataProviderRelease(fontDataProvider);
    CFErrorRef error;
    
    if (CTFontManagerRegisterGraphicsFont(fontRef, &error)) {
//        JPLog(@"注册成功 %@ --- %@", [filePath componentsSeparatedByString:@"/"].lastObject, fontName);
    } else {
//            JPLog(@"注册错误 %@ --- %@", [filePath componentsSeparatedByString:@"/"].lastObject, error);
        CFRelease(error);
    }
    
    CGFontRelease(fontRef);
    
    return fontName;
}

+ (void)unRegisterFontWithFilePath:(NSString *)filePath {
    if (![self fileExists:filePath]) return;
    
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath]);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
//    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    CGDataProviderRelease(fontDataProvider);
    CFErrorRef error;
    
    if (CTFontManagerUnregisterGraphicsFont(fontRef, &error)) {
//        JPLog(@"解除成功 %@ --- %@", [filePath componentsSeparatedByString:@"/"].lastObject, fontName);
    } else {
//            JPLog(@"解除错误 %@ --- %@", [filePath componentsSeparatedByString:@"/"].lastObject, error);
        CFRelease(error);
    }
    
    CGFontRelease(fontRef);
}

@end
