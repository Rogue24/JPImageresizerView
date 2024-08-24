//
//  JPImageresizerResult.h
//  JPImageresizerView
//
//  Created by 周健平 on 2021/6/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 裁剪结果类型
 */
typedef NS_ENUM(NSUInteger, JPImageresizerResultType) {
    JPImageresizerResult_Image, // 图片
    JPImageresizerResult_GIF, // GIF
    JPImageresizerResult_Video // 视频
};

@interface JPImageresizerResult : NSObject
/** 裁剪结果类型（图片/GIF/视频） */
@property (nonatomic, assign, readonly) JPImageresizerResultType type;
/** 裁剪后的图片/GIF（已解码好的，若为视频类型则该属性为nil） */
@property (nonatomic, strong, readonly) UIImage *_Nullable image;
/** 目标存放路径 */
@property (nonatomic, strong, readonly) NSURL *_Nullable cacheURL;
/** 是否缓存成功（缓存不成功则cacheURL为nil） */
@property (nonatomic, assign, readonly) BOOL isCacheSuccess;

- (instancetype)initWithImage:(UIImage *)image cacheURL:(NSURL *_Nullable)cacheURL;
- (instancetype)initWithGifImage:(UIImage *)gifImage cacheURL:(NSURL *_Nullable)cacheURL;
- (instancetype)initWithVideoCacheURL:(NSURL *)cacheURL;
@end

NS_ASSUME_NONNULL_END
