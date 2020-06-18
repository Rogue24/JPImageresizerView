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

typedef void(^JPAssetCollectionFastEnumeration)(PHAssetCollection *collection, NSInteger index, NSInteger totalCount);
typedef void(^JPAssetFastEnumeration)(PHAsset *asset, NSUInteger index, NSUInteger totalCount);

typedef void(^JPGetAssetsCompletion)(NSArray *assets);
typedef void(^JPAssetsCachingHandle)(NSArray *indexPaths, JPGetAssetsCompletion getAssetsCompletion);

typedef void(^JPPhotoImageResultHandler)(PHAsset *requestAsset, UIImage *resultImage, BOOL isFinalImage);
typedef void(^JPLivePhotoResultHandler)(PHAsset *requestAsset, PHLivePhoto *livePhoto, BOOL isFinalLivePhoto);

@interface JPPhotoTool : NSObject

/*!
 @method
 @brief 获取手机相册工具单例
 @discussion 单例
 @result 获取手机相册工具单例
 */
JPSingtonInterface

#pragma mark - 访问权限

/**
 @method
 @brief 是否有相册的访问权限
 @discussion 相册的访问权限
 */
- (BOOL)isAllowAlbumAccessAuthority;

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

#pragma mark - 相册监听

/** 取消监听 */
- (void)unRegisterChange;

/** 相册发生改变时调用的block */
@property (nonatomic, copy) void(^photoLibraryDidChangeHandler)(PHAssetCollection *assetCollection, PHFetchResultChangeDetails *changeDetails, PHFetchResult *fetchResult);

#pragma mark - 获取相册

/**
 @method
 @brief 获取所有相册
 */
- (void)getAllAssetCollectionWithFastEnumeration:(JPAssetCollectionFastEnumeration)fastEnumeration
                                      completion:(void(^)(void))completion;

/**
 @method
 @brief 获取所有【系统创建】的相册
 */
- (void)getAllSystemCreateAssetCollectionWithFastEnumeration:(JPAssetCollectionFastEnumeration)fastEnumeration
                                                  completion:(void(^)(void))completion;

/**
 @method
 @brief 获取所有【用户创建】的相册
 */
- (void)getAllUserCreateAssetCollectionWithFastEnumeration:(JPAssetCollectionFastEnumeration)fastEnumeration
                                                completion:(void(^)(void))completion;

#pragma mark - 获取照片

/**
 @method
 @brief 获取【所有】相册内所有照片资源
 */
- (void)getAllAssetInPhotoAblumWithFastEnumeration:(JPAssetFastEnumeration)fastEnumeration
                                        completion:(void(^)(void))completion;

/**
 @method
 @brief 获取【指定】相册内所有照片资源，assetCollection为nil则获取全部照片
 */
- (void)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                   fastEnumeration:(JPAssetFastEnumeration)fastEnumeration
                        completion:(void(^)(void))completion;

/**
 @method
 @brief 获取最新的一张照片
 @discussion 最新的一张照片
 */
- (PHAsset *)getNewestAsset;

#pragma mark - 解析照片

/**
 @method
 @brief 根据获取的PHAsset对象，解析固定尺寸的照片并缓存
 @discussion PHAsset对象
 */
- (void)requestThumbnailPhotoImageForAsset:(PHAsset *)asset
                             resultHandler:(JPPhotoImageResultHandler)resultHandler;

/**
 @method
 @brief 根据获取的PHAsset对象，解析指定尺寸的照片并缓存
 @discussion PHAsset对象
 */
- (void)requestThumbnailPhotoImageForAsset:(PHAsset *)asset
                                targetSize:(CGSize)targetSize
                             resultHandler:(JPPhotoImageResultHandler)resultHandler;

/**
 @method
 @brief 根据获取的PHAsset对象，解析原图尺寸的照片
 @discussion PHAsset对象
 */
- (void)requestOriginalPhotoImageForAsset:(PHAsset *)asset
                               isFastMode:(BOOL)isFastMode
                         isFixOrientation:(BOOL)isFixOrientation
                      isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                            resultHandler:(JPPhotoImageResultHandler)resultHandler;

/**
 @method
 @brief 根据获取的PHAsset对象，解析指定尺寸的照片
 @discussion PHAsset对象
 */
- (void)requestPhotoImageForAsset:(PHAsset *)asset
                       targetSize:(CGSize)targetSize
                       isFastMode:(BOOL)isFastMode
                 isFixOrientation:(BOOL)isFixOrientation
              isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                    resultHandler:(JPPhotoImageResultHandler)resultHandler;

/**
 @method
 @brief 根据获取的PHAsset对象，解析指定尺寸的实况照片
 @discussion PHAsset对象
 */
- (void)requestLivePhotoForAsset:(PHAsset *)asset
                      targetSize:(CGSize)targetSize
                         options:(PHLivePhotoRequestOptions *)options
             isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                   resultHandler:(JPLivePhotoResultHandler)resultHandler;

#pragma mark - 保存照片/文件

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
- (void)savePhotoToAppAlbumWithImage:(UIImage *)image
                       successHandle:(void (^)(NSString *assetID))successHandle
                          failHandle:(void (^)(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail))failHandle;

/**
 @method
 @brief 保存视频到【相机胶卷】
 */
- (void)saveVideoWithFileURL:(NSURL *)fileURL
               successHandle:(void (^)(NSString *assetID))successHandle
                  failHandle:(void (^)(void))failHandle;

/**
 @method
 @brief 保存视频到【App相册】
 */
- (void)saveVideoToAppAlbumWithFileURL:(NSURL *)fileURL
                         successHandle:(void (^)(NSString *assetID))successHandle
                            failHandle:(void (^)(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail))failHandle;

/**
 @method
 @brief 保存文件到【相机胶卷】
 */
- (void)saveFileWithFileURL:(NSURL *)fileURL
              successHandle:(void (^)(NSString *assetID))successHandle
                 failHandle:(void (^)(void))failHandle;

/**
 @method
 @brief 保存文件到【App相册】
 */
- (void)saveFileToAppAlbumWithFileURL:(NSURL *)fileURL
                        successHandle:(void (^)(NSString *assetID))successHandle
                           failHandle:(void (^)(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail))failHandle;

@end
