//
//  JPPhotoTool.h
//  Infinitee2.0
//
//  Created by guanning on 2017/4/12.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#define JPPhotoToolSI [JPPhotoTool sharedInstance]

typedef void(^AssetCollectionFastEnumeration)(PHAssetCollection *collection, NSInteger index, NSInteger totalCount);
typedef void(^AssetFastEnumeration)(PHAsset *asset, NSInteger index, NSInteger totalCount);

typedef void(^GetAssetsCompletion)(NSArray *assets);
typedef void(^AssetsCachingHandle)(NSArray *indexPaths, GetAssetsCompletion getAssetsCompletion);

@interface JPPhotoTool : NSObject

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;

- (void)setupCollectionView:(UICollectionView *)collectionView thumbnailPhotoSize:(CGSize)thumbnailPhotoSize;
- (void)resetCachedAssets;
- (void)updateCachedAssetsWithStartCachingBlock:(AssetsCachingHandle)startCachingBlock stopCachingBlock:(AssetsCachingHandle)stopCachingBlock;

/*!
 @method
 @brief 获取手机相册工具单例
 @discussion 单例
 @result 获取手机相册工具单例
 */
+ (instancetype)sharedInstance;

/** 取消监听 */
- (void)unRegisterChange;

/** 相册发生改变时调用的block */
@property (nonatomic, copy) void(^photoLibraryDidChangeHandler)(PHAssetCollection *assetCollection, PHFetchResultChangeDetails *changeDetails, PHFetchResult *fetchResult);

/**
 @method
 @brief 验证是否有相册的访问权限以及相应处理
 @discussion 相册的访问权限
 */
- (void)albumAccessAuthorityWithAllowAccessAuthorityHandler:(void (^)(void))allowBlock
                               refuseAccessAuthorityHandler:(void (^)(void))refuseBlock
                        alreadyRefuseAccessAuthorityHandler:(void (^)(void))alreadyRefuseBlock
                               canNotAccessAuthorityHandler:(void (^)(void))canNotBlock
                                           isRegisterChange:(BOOL)isRegisterChange;

/**
 @method
 @brief 验证是否有相机的访问权限以及相应处理
 @discussion 相机的访问权限
 */
- (void)cameraAuthorityWithAllowAccessAuthorityHandler:(void (^)(void))allowBlock
                          refuseAccessAuthorityHandler:(void (^)(void))refuseBlock
                   alreadyRefuseAccessAuthorityHandler:(void (^)(void))alreadyRefuseBlock
                          canNotAccessAuthorityHandler:(void (^)(void))canNotBlock;

/**
 @method
 @brief 根据获取的PHAsset对象，解析照片并缓存
 @discussion PHAsset对象
 */
- (void)requestThumbnailPhotoForAsset:(PHAsset *)asset
                        resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result))resultHandler;
- (void)requestThumbnailPhotoForAsset:(PHAsset *)asset
                           targetSize:(CGSize)targetSize
                  isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                        resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result))resultHandler;

/**
 @method
 @brief 根据获取的PHAsset对象，解析指定尺寸照片
 @discussion PHAsset对象
 */
- (void)requestLargePhotoForAsset:(PHAsset *)asset
                       targetSize:(CGSize)targetSize
                       isFastMode:(BOOL)isFastMode
           isShouldFixOrientation:(BOOL)isFixOrientation
                    resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler;

- (void)requestOriginalPhotoForAsset:(PHAsset *)asset
                          targetSize:(CGSize)targetSize
                          isFastMode:(BOOL)isFastMode
              isShouldFixOrientation:(BOOL)isFixOrientation
                 isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                       resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler;


/**
 @method
 @brief 获取最新的一张照片
 @discussion 最新的一张照片
 */
- (PHAsset *)getNewestAsset;


//- (PHAssetCollection *)appAssetCollection;


/**
 @method
 @brief 获取【所有】相册内所有照片资源
 */
- (void)getAllAssetInPhotoAblumWithFastEnumeration:(AssetFastEnumeration)fastEnumeration
                                        completion:(void(^)(void))completion;

/**
 @method
 @brief 获取【指定】相册内所有照片资源，assetCollection为nil则获取全部照片
 */
- (void)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                   fastEnumeration:(AssetFastEnumeration)fastEnumeration
                        completion:(void(^)(void))completion;

/**
 @method
 @brief 获取所有相册
 */
- (void)getAllAssetCollectionWithFastEnumeration:(AssetCollectionFastEnumeration)fastEnumeration
                                      completion:(void(^)(void))completion;

/**
 @method
 @brief 获取所有【系统创建】的相册
 */
- (void)getAllSystemCreateAssetCollectionWithFastEnumeration:(AssetCollectionFastEnumeration)fastEnumeration
                                                  completion:(void(^)(void))completion;

/**
 @method
 @brief 获取所有【用户创建】的相册
 */
- (void)getAllUserCreateAssetCollectionWithFastEnumeration:(AssetCollectionFastEnumeration)fastEnumeration
                                                completion:(void(^)(void))completion;

/**
 @method
 @brief 保存图片到【相机胶卷】
 */
- (void)savePhotoWithImage:(UIImage *)image
             successHandle:(void (^)(NSString *assetID))successHandle
                failHandle:(void (^)(void))failHandle;

/**
 @method
 @brief 保存图片到【App相册】
 */
- (BOOL)savePhotoToAppAlbumSuccessWithImage:(UIImage *)image;
@end
