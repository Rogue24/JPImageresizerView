//
//  JPCropPictureResult.m
//  JPImageresizerView
//
//  Created by 周健平 on 2021/6/10.
//

#import "JPImageresizerResult.h"

@implementation JPImageresizerResult
- (instancetype)initWithImage:(UIImage *)image cacheURL:(NSURL *)cacheURL {
    if (self = [super init]) {
        _type = JPImageresizerResult_Image;
        _image = image;
        self.cacheURL = cacheURL;
    }
    return self;
}

- (instancetype)initWithGifImage:(UIImage *)gifImage cacheURL:(NSURL *)cacheURL {
    if (self = [super init]) {
        _type = JPImageresizerResult_GIF;
        self.cacheURL = cacheURL;
    }
    return self;
}

- (instancetype)initWithVideoCacheURL:(NSURL *)cacheURL {
    if (self = [super init]) {
        _type = JPImageresizerResult_Video;
        self.cacheURL = cacheURL;
    }
    return self;
}

- (void)setCacheURL:(NSURL *)cacheURL {
    _cacheURL = cacheURL;
    _isCacheSuccess = cacheURL ? [[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path] : NO;
}
@end
