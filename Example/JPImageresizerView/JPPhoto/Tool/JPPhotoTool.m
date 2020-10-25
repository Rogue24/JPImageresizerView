//
//  JPPhotoTool.m
//  Infinitee2.0
//
//  Created by guanning on 2017/4/12.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPPhotoTool.h"

@interface JPPhotoTool () <PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) PHFetchOptions *baseFetchOptions;
@property (nonatomic, strong) PHCachingImageManager *cacheImgManager;
@property (nonatomic, strong) PHImageRequestOptions *fastOptions;
@property (nonatomic, strong) PHImageRequestOptions *highQualityOptions;

@property (nonatomic, assign) BOOL isRegisterChange;
@property (nonatomic, strong) PHFetchResult *changeResult;
@property (nonatomic, weak) PHAssetCollection *currCollection;
@end

/**
 
 1.PHAsset：一个PHAsset对象代表相册中的一张图片或一个视频
    查：[PHAsset fetchAssets...]
    增删改：PHAssetChangeRequest
 
 2.PHAssetCollection：一个PHAssetCollection代表一个相册
    查：[PHAssetCollection fetchAssetCollections...]
    增删改：PHAssetCollectionChangeRequest
 
 任何*增删改*的操作只能写在 -[PHPhotoLibrary performChanges:] 或 -[PHPhotoLibrary performChangesAndWait:] 里面的block中执行
 
 1.异步执行修改操作
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 修改操作
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        // 修改完毕
    }];
 
 2.同步执行修改操作（执行这段代码时程序会停住，执行完才能继续后面的代码，不过很快就会执行完了）
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 修改操作
    } error:&error];
 
    if (error) {
        // 失败
    } else {
        // 成功
    }
 
 */

/**
 * 照片获取条件：
 * PHImageRequestOptionsResizeModeNone,
 * PHImageRequestOptionsResizeModeFast,     // 根据传入的size，迅速加载大小相匹配(略大于或略小于)的图像
 * PHImageRequestOptionsResizeModeExact    // 精确的加载与传入size相匹配的图像
 */

@implementation JPPhotoTool
{
    CGRect _previousPreheatRect;
}

#pragma mark - const

static CGSize thumbnailPhotoSize_;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thumbnailPhotoSize_ = CGSizeMake(300 * JPScreenScale, 300 * JPScreenScale);
    });
}

#pragma mark - singleton

JPSingtonImplement(JPPhotoTool)

#pragma mark - getter

// 基本相册查询配置
- (PHFetchOptions *)baseFetchOptions {
    if (!_baseFetchOptions) {
        _baseFetchOptions = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        _baseFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    }
    return _baseFetchOptions;
}

- (PHCachingImageManager *)cacheImgManager {
    if (!_cacheImgManager) {
        _cacheImgManager = [[PHCachingImageManager alloc] init];
    }
    return _cacheImgManager;
}

- (PHImageRequestOptions *)fastOptions {
    if (!_fastOptions) {
        _fastOptions = [[PHImageRequestOptions alloc] init];
        _fastOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
//        _fastOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        _fastOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    return _fastOptions;
}

- (PHImageRequestOptions *)highQualityOptions {
    if (!_highQualityOptions) {
        _highQualityOptions = [[PHImageRequestOptions alloc] init];
        _highQualityOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        _highQualityOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    return _highQualityOptions;
}

#pragma mark - 访问权限

- (BOOL)isAllowAlbumAccessAuthority {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    return status == PHAuthorizationStatusAuthorized;
}

#pragma mark 相册权限
- (void)albumAccessAuthorityWithAllowAccessAuthorityHandler:(void (^)(void))allowBlock
                               refuseAccessAuthorityHandler:(void (^)(void))refuseBlock
                        alreadyRefuseAccessAuthorityHandler:(void (^)(void))alreadyRefuseBlock
                               canNotAccessAuthorityHandler:(void (^)(void))canNotBlock
                                           isRegisterChange:(BOOL)isRegisterChange {
    
    self.isRegisterChange = isRegisterChange;
    
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    
    // 请求\检测访问权限
    // 如果用户还没有做出选择，会自动弹框，用户对弹框做出选择之后，才会调用block
    // 如果用户已经做过选择，会直接调用block
    @jp_weakify(self);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @jp_strongify(self);
            if (!self) return;
            switch (status) {
                case PHAuthorizationStatusDenied:       // 还不确定
                {
                    if (oldStatus != PHAuthorizationStatusNotDetermined) {
                        // 已经点了拒绝
                        [self __jurisdictionAlertWithTitle:@"没有访问照片的权限" message:@"请前往设置开启照片访问权限" isAlbum:YES cancelHandle:^{
                            !alreadyRefuseBlock ? : alreadyRefuseBlock();
                        }];
                    } else if (oldStatus == PHAuthorizationStatusNotDetermined) {
                        // 点击拒绝
                        if (refuseBlock) {
                            refuseBlock();
                        } else {
                            [self __jurisdictionAlertWithTitle:@"您已拒绝访问照片的权限" message:@"需要开启照片访问权限才可以打开相册" isAlbum:YES cancelHandle:^{
                                !alreadyRefuseBlock ? : alreadyRefuseBlock();
                            }];
                        }
                    }
                    break;
                }
                    
                case PHAuthorizationStatusAuthorized:   // 允许
                {
                    if (isRegisterChange) {
                        // 监听相册变化
                        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
                    }
                    !allowBlock ? : allowBlock();
                    break;
                }
                    
                default:                                // 无法访问
                {
                    if (canNotBlock) {
                        canNotBlock();
                    } else {
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"不能访问照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:action];
                        [[UIWindow jp_topViewControllerFromKeyWindow] presentViewController:alertController animated:YES completion:nil];
                    }
                    break;
                }
            }
        });
    }];
}

#pragma mark 相机权限
- (void)cameraAuthorityWithAllowAccessAuthorityHandler:(void (^)(void))allowBlock
                          refuseAccessAuthorityHandler:(void (^)(void))refuseBlock
                   alreadyRefuseAccessAuthorityHandler:(void (^)(void))alreadyRefuseBlock
                          canNotAccessAuthorityHandler:(void (^)(void))canNotBlock {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (canNotBlock) {
            canNotBlock();
        } else {
            // 若不可用则退出方法
            [JPProgressHUD showErrorWithStatus:@"您的相机不能使用" userInteractionEnabled:YES];
        }
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    // AVAuthorizationStatusAuthorized 允许
    // AVAuthorizationStatusNotDetermined 用户还没决定
    // AVAuthorizationStatusDenied 用户已经拒绝
    
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        @jp_weakify(self);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @jp_strongify(self);
                if (!self) return;
                if (granted) {
                    !allowBlock ? : allowBlock();
                } else {
                    if (refuseBlock) {
                        refuseBlock();
                    } else {
                        [self __jurisdictionAlertWithTitle:@"您已拒绝访问相机的权限" message:@"需要开启相机访问权限才可以使用相机" isAlbum:NO cancelHandle:^{
                            !alreadyRefuseBlock ? : alreadyRefuseBlock();
                        }];
                    }
                }
            });
        }];
    } else {
        if (authStatus == AVAuthorizationStatusAuthorized) {
            !allowBlock ? : allowBlock();
        } else {
            [self __jurisdictionAlertWithTitle:@"没有访问相机的权限" message:@"需要开启相机访问权限才可以使用相机" isAlbum:NO cancelHandle:^{
                !alreadyRefuseBlock ? : alreadyRefuseBlock();
            }];
        }
    }
}

#pragma mark 跳转设置权限
- (void)__jurisdictionAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                             isAlbum:(BOOL)isAlbum
                        cancelHandle:(void(^)(void))cancelHandle {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"前往开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        } else {
            [JPProgressHUD showErrorWithStatus:@"无法前往设置页面" userInteractionEnabled:YES];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !cancelHandle ? : cancelHandle();
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:action];
    [alertController addAction:cancel];
    [[UIWindow jp_topViewControllerFromKeyWindow] presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 相册监听

#pragma mark 移除相册监听
- (void)unRegisterChange {
    if (self.isRegisterChange) {
        self.isRegisterChange = NO;
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
    self.changeResult = nil;
    self.currCollection = nil;
    self.photoLibraryDidChangeHandler = nil;
}

#pragma mark 相册监听回调 PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    if (!self.isRegisterChange || !self.changeResult) return;
    
    PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:self.changeResult];
    
    // 当这个对象存在证明相册发生了变化
    if (changeDetails) {
        PHFetchResult *changeResult = [changeDetails fetchResultAfterChanges];
        
        !self.photoLibraryDidChangeHandler ? : self.photoLibraryDidChangeHandler(self.currCollection, changeDetails, changeResult);
        
        //【注意】：监听完一次要更新一下监听对象，不然会累加之前的变化值
        if (self.currCollection) {
            self.changeResult = [PHAsset fetchAssetsInAssetCollection:self.currCollection options:self.baseFetchOptions];
        } else {
            self.changeResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.baseFetchOptions];
        }
    }
}

#pragma mark - 获取相册

#pragma mark 获取所有相册
- (void)getAllAssetCollectionWithFastEnumeration:(JPAssetCollectionFastEnumeration)fastEnumeration
                                      completion:(void(^)(void))completion {
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getAllAssetCollectionWithFastEnumeration:fastEnumeration completion:completion];
        });
        return;
    }
    
    void (^getAllUserCreateAssetCollection)(NSUInteger startIndex) = ^(NSUInteger startIndex) {
        PHFetchResult *userAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        NSInteger userAlbumsCount = userAlbumsFR.count;
        if (userAlbumsCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !completion ? : completion();
            });
        } else {
            NSUInteger maxIdx = userAlbumsCount - 1;
            [userAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
                PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                !fastEnumeration ? : fastEnumeration(collection, (startIndex + idx), [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                if (idx == maxIdx) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        !completion ? : completion();
                    });
                }
            }];
        }
    };
    
    PHFetchResult *allPhotoAlbumsFR = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.baseFetchOptions];
    !fastEnumeration ? : fastEnumeration(nil, 0, allPhotoAlbumsFR.count);
    
    __block NSUInteger currentIndex = 1;
    
    PHFetchResult *systemAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    NSInteger systemAlbumsCount = systemAlbumsFR.count;
    
    if (systemAlbumsCount == 0) {
        getAllUserCreateAssetCollection(currentIndex);
        return;
    }
    
    NSUInteger maxIdx = systemAlbumsCount - 1;
    [systemAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollectionSubtype subtype = collection.assetCollectionSubtype;
        if (subtype == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
            subtype == PHAssetCollectionSubtypeSmartAlbumFavorites ||
            subtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ||
            subtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
            !fastEnumeration ? : fastEnumeration(collection, currentIndex, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
            currentIndex += 1;
        } else if (@available(iOS 9.0, *)) {
            if (subtype == PHAssetCollectionSubtypeSmartAlbumSelfPortraits ||
                subtype == PHAssetCollectionSubtypeSmartAlbumScreenshots) {
                PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                !fastEnumeration ? : fastEnumeration(collection, currentIndex, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                currentIndex += 1;
            }
//                if (@available(iOS 10.2, *)) {
//                    if (subtype == PHAssetCollectionSubtypeSmartAlbumDepthEffect ||
//                        subtype == PHAssetCollectionSubtypeSmartAlbumLivePhotos) {
//                        PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
//                        currentIndex += 1;
//                        !fastEnumeration ? : fastEnumeration(collection, currentIndex, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
//                    }
//                    if (@available(iOS 11, *)) {
//                        if (subtype == PHAssetCollectionSubtypeSmartAlbumAnimated ||
//                            subtype == PHAssetCollectionSubtypeSmartAlbumLongExposures) {
//                            PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
//                            currentIndex += 1;
//                            !fastEnumeration ? : fastEnumeration(collection, currentIndex, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
//                        }
//                        if (@available(iOS 13, *)) {
//                            if (subtype == PHAssetCollectionSubtypeSmartAlbumUnableToUpload) {
//                                PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
//                                currentIndex += 1;
//                                !fastEnumeration ? : fastEnumeration(collection, currentIndex, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
//                            }
//                        }
//                    }
//                }
        }
        if (idx == maxIdx) {
            getAllUserCreateAssetCollection(currentIndex);
        }
    }];
}

#pragma mark 获取所有系统的相册
- (void)getAllSystemCreateAssetCollectionWithFastEnumeration:(JPAssetCollectionFastEnumeration)fastEnumeration
                                                  completion:(void(^)(void))completion {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getAllSystemCreateAssetCollectionWithFastEnumeration:fastEnumeration completion:completion];
        });
        return;
    }
    
    PHFetchResult *systemAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    NSInteger systemAlbumsCount = systemAlbumsFR.count;
    
    if (systemAlbumsCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ? : completion();
        });
        return;
    }
    
    __block NSUInteger currentIndex = 0;
    NSUInteger maxIdx = systemAlbumsCount - 1;
    [systemAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollectionSubtype subtype = collection.assetCollectionSubtype;
        if (subtype == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
            subtype == PHAssetCollectionSubtypeSmartAlbumFavorites ||
            subtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ||
            subtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
            !fastEnumeration ? : fastEnumeration(collection, currentIndex, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
            currentIndex += 1;
        } else if (@available(iOS 9.0, *)) {
            if (subtype == PHAssetCollectionSubtypeSmartAlbumSelfPortraits) {
                PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                !fastEnumeration ? : fastEnumeration(collection, currentIndex, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                currentIndex += 1;
            }
        }
        if (idx == maxIdx) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !completion ? : completion();
            });
        }
    }];
}

#pragma mark 获取所有用户创建的相册
- (void)getAllUserCreateAssetCollectionWithFastEnumeration:(JPAssetCollectionFastEnumeration)fastEnumeration
                                                completion:(void(^)(void))completion {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getAllUserCreateAssetCollectionWithFastEnumeration:fastEnumeration completion:completion];
        });
        return;
    }
    
    //获取所有用户创建的相册
    PHFetchResult *userAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    NSInteger userAlbumsCount = userAlbumsFR.count;
    
    if (userAlbumsCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ? : completion();
        });
        return;
    }
    
    NSInteger maxIdx = userAlbumsCount - 1;
    [userAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
        !fastEnumeration ? : fastEnumeration(collection, idx, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
        if (idx == maxIdx) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !completion ? : completion();
            });
        }
    }];
}

#pragma mark - 获取照片

#pragma mark 获取所有照片
- (void)getAllAssetInPhotoAblumWithFastEnumeration:(JPAssetFastEnumeration)fastEnumeration
                                        completion:(void (^)(void))completion {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getAllAssetInPhotoAblumWithFastEnumeration:fastEnumeration completion:completion];
        });
        return;
    }
    
    // 照片查找集合
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.baseFetchOptions];
    
    if (self.isRegisterChange) {
        self.currCollection = nil;
        self.changeResult = fetchResult;
    }
    
    NSInteger count = fetchResult.count;
    if (count == 0) {
        !completion ? : completion();
        return;
    }
    
    NSInteger maxIdx = count - 1;
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        !fastEnumeration ? : fastEnumeration(asset, idx, count);
        if (idx == maxIdx) {
            !completion ? : completion();
        }
    }];
}

#pragma mark 获取指定相册内的所有照片
- (void)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                   fastEnumeration:(JPAssetFastEnumeration)fastEnumeration
                        completion:(void (^)(void))completion {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getAssetsInAssetCollection:assetCollection fastEnumeration:fastEnumeration completion:completion];
        });
        return;
    }
    
    PHFetchResult *fetchResult;
    NSUInteger count = 0;
    // 以后加上指定类型的处理：这里是查所有类型。
    if (assetCollection) {
        // 查找指定相册的
        fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.baseFetchOptions]; // 目前只能拿到所有类型的，暂时不知道怎么查找相册里的指定类型
        count = fetchResult.count;
    } else {
        // 查找所有
//        fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.baseFetchOptions]; // 指定只查找照片类型
        fetchResult = [PHAsset fetchAssetsWithOptions:self.baseFetchOptions];
        count = fetchResult.count;
    }
    
    if (self.isRegisterChange) {
        self.currCollection = assetCollection;
        self.changeResult = fetchResult;
    }
    
    if (count == 0) {
        !completion ? : completion();
        return;
    }
    
    NSInteger maxIdx = count - 1;
    NSInteger photoCount = [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    __block NSInteger photoIndex = 0;
    
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        // 以后加上指定类型的处理：可以在这里进行筛选，这里暂时只处理照片的情况。
        if (asset.mediaType == PHAssetMediaTypeImage) {
            !fastEnumeration ? : fastEnumeration(asset, photoIndex, photoCount);
            photoIndex += 1;
        }
        if (idx == maxIdx) {
            !completion ? : completion();
        }
    }];
}

#pragma mark 获取最新一张照片
- (PHAsset *)getNewestAsset {
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:self.baseFetchOptions];
    return assetsFetchResults.firstObject;
}

#pragma mark - 解析照片

#pragma mark 解析固定尺寸的预览照片（可配合缓存处理）
- (void)requestThumbnailPhotoImageForAsset:(PHAsset *)asset
                             resultHandler:(JPPhotoImageResultHandler)resultHandler {
    [self __requestPhotoImageForAsset:asset
                           targetSize:thumbnailPhotoSize_
                           isFastMode:YES
                     isFixOrientation:NO
                  isJustGetFinalPhoto:NO
                       isRequestCache:YES
                        resultHandler:resultHandler];
}

#pragma mark 解析指定尺寸的预览照片
- (void)requestThumbnailPhotoImageForAsset:(PHAsset *)asset
                                targetSize:(CGSize)targetSize
                             resultHandler:(JPPhotoImageResultHandler)resultHandler {
    [self __requestPhotoImageForAsset:asset
                           targetSize:targetSize
                           isFastMode:YES
                     isFixOrientation:NO
                  isJustGetFinalPhoto:NO
                       isRequestCache:YES
                        resultHandler:resultHandler];
}

#pragma mark 解析原图尺寸的照片
- (void)requestOriginalPhotoImageForAsset:(PHAsset *)asset
                               isFastMode:(BOOL)isFastMode
                         isFixOrientation:(BOOL)isFixOrientation
                      isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                            resultHandler:(JPPhotoImageResultHandler)resultHandler {
    [self __requestPhotoImageForAsset:asset
                           targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                           isFastMode:isFastMode
                     isFixOrientation:isFixOrientation
                  isJustGetFinalPhoto:isJustGetFinalPhoto
                       isRequestCache:NO
                        resultHandler:resultHandler];
}

#pragma mark 解析指定尺寸的照片
- (void)requestPhotoImageForAsset:(PHAsset *)asset
                       targetSize:(CGSize)targetSize
                       isFastMode:(BOOL)isFastMode
                 isFixOrientation:(BOOL)isFixOrientation
              isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                    resultHandler:(JPPhotoImageResultHandler)resultHandler {
    [self __requestPhotoImageForAsset:asset
                           targetSize:targetSize
                           isFastMode:isFastMode
                     isFixOrientation:isFixOrientation
                  isJustGetFinalPhoto:isJustGetFinalPhoto
                       isRequestCache:NO
                        resultHandler:resultHandler];
}

#pragma mark 解析指定尺寸的实况照片
- (void)requestLivePhotoForAsset:(PHAsset *)asset
                      targetSize:(CGSize)targetSize
                         options:(PHLivePhotoRequestOptions *)options
             isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                   resultHandler:(JPLivePhotoResultHandler)resultHandler {
    if (!resultHandler) return;
    [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:(options ? options : 0) resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        if (info[PHImageErrorKey] || [info[PHImageCancelledKey] boolValue]) {
            resultHandler(asset, nil, NO);
            return;
        }
        
        BOOL isFinalLivePhoto = ![info[PHImageResultIsDegradedKey] boolValue];
        if (isJustGetFinalPhoto && !isFinalLivePhoto) return;
        
        resultHandler(asset, livePhoto, isFinalLivePhoto);
    }];
}

#pragma mark 解析照片操作
- (void)__requestPhotoImageForAsset:(PHAsset *)asset
                         targetSize:(CGSize)targetSize
                         isFastMode:(BOOL)isFastMode
                   isFixOrientation:(BOOL)isFixOrientation
                isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                     isRequestCache:(BOOL)isRequestCache
                      resultHandler:(JPPhotoImageResultHandler)resultHandler {
    if (!resultHandler) return;
    
    // targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    // iOS13的PHImageManagerMaximumSize已经不适用，使用asset的像素获取原图尺寸
    
    PHImageManager *imageManager = isRequestCache ? self.cacheImgManager : [PHImageManager defaultManager];
    PHImageRequestOptions *options = isFastMode ? self.fastOptions : self.highQualityOptions;
    
    [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        /**
         * resultHandler中的info 字典提供了关于当前请求状态的信息，比如：
         * PHImageResultIsInCloudKey：图像是否必须从 iCloud 请求 (如果你初始化时将 networkAccessAllowed 设置成 false，那么就必须重新请求图像) 。
         * PHImageResultIsDegradedKey：当前递送的 UIImage 是否是最终结果的低质量格式。当高质量图像正在下载时，这个可以让你给用户先展示一个预览图像。
         * PHImageResultRequestIDKey 和 PHImageCancelledKey：请求 ID (可以便捷的取消请求)，以及请求是否已经被取消。
         * PHImageErrorKey：如果没有图像提供给 result handler，字典内还会有一个错误信息。
         */
        
        if (info[PHImageErrorKey] || [info[PHImageCancelledKey] boolValue]) {
            resultHandler(asset, nil, NO);
            return;
        }
        
        BOOL isFinalImage = ![info[PHImageResultIsDegradedKey] boolValue];
        if (isJustGetFinalPhoto && !isFinalImage) return;
        
        if (isFixOrientation) image = [self __imageFixOrientation:image];
        resultHandler(asset, image, isFinalImage);
    }];
}

#pragma mark - 保存照片/文件（GIF、Video）

#pragma mark 保存照片到相机胶卷
- (void)savePhotoWithImage:(UIImage *)image
             successHandle:(void (^)(NSString *assetID))successHandle
                failHandle:(void (^)(void))failHandle {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self savePhotoWithImage:image successHandle:successHandle failHandle:failHandle];
        });
        return;
    }
    
    NSError *error = nil;
    
    // 创建占位照片对象
    __block PHObjectPlaceholder *placeholder = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        placeholder = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
    } error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            // 保存失败
            !failHandle ? : failHandle();
        } else {
            // 保存成功
            !successHandle ? : successHandle(placeholder.localIdentifier);
        }
    });
}

#pragma mark 保存照片到App相册
- (void)savePhotoToAppAlbumWithImage:(UIImage *)image
                       successHandle:(void (^)(NSString *assetID))successHandle
                          failHandle:(void (^)(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail))failHandle {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self savePhotoToAppAlbumWithImage:image successHandle:successHandle failHandle:failHandle];
        });
        return;
    }
    
    NSError *error = nil;
    __block NSString *assetID = nil;
    
    // 保存图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !failHandle ? : failHandle(assetID, NO, YES);
        });
        return;
    }
    
    [self __appAssetCollectionInsertAsset:assetID successHandle:successHandle failHandle:failHandle];
}

#pragma mark 保存视频到相机胶卷
- (void)saveVideoWithFileURL:(NSURL *)fileURL
               successHandle:(void (^)(NSString *assetID))successHandle
                  failHandle:(void (^)(void))failHandle {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveVideoWithFileURL:fileURL successHandle:successHandle failHandle:failHandle];
        });
        return;
    }
    
    __block PHObjectPlaceholder *placeholder = nil;
    NSError *error;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        placeholder = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL].placeholderForCreatedAsset;
    } error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            // 保存失败
            !failHandle ? : failHandle();
        } else {
            // 保存成功
            !successHandle ? : successHandle(placeholder.localIdentifier);
        }
    });
}

#pragma mark 保存视频到App相册
- (void)saveVideoToAppAlbumWithFileURL:(NSURL *)fileURL
                         successHandle:(void (^)(NSString *assetID))successHandle
                            failHandle:(void (^)(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail))failHandle {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveVideoToAppAlbumWithFileURL:fileURL successHandle:successHandle failHandle:failHandle];
        });
        return;
    }
    
    NSError *error = nil;
    __block NSString *assetID = nil;
    
    // 保存图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !failHandle ? : failHandle(assetID, NO, YES);
        });
        return;
    }
    
    [self __appAssetCollectionInsertAsset:assetID successHandle:successHandle failHandle:failHandle];
}

#pragma mark 保存文件到相机胶卷
- (void)saveFileWithFileURL:(NSURL *)fileURL
              successHandle:(void (^)(NSString *assetID))successHandle
                 failHandle:(void (^)(void))failHandle {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveFileWithFileURL:fileURL successHandle:successHandle failHandle:failHandle];
        });
        return;
    }
    
    __block PHObjectPlaceholder *placeholder = nil;
    NSError *error;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        placeholder = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileURL].placeholderForCreatedAsset;
    } error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            // 保存失败
            !failHandle ? : failHandle();
        } else {
            // 保存成功
            !successHandle ? : successHandle(placeholder.localIdentifier);
        }
    });
}

#pragma mark 保存文件到App相册
- (void)saveFileToAppAlbumWithFileURL:(NSURL *)fileURL
                        successHandle:(void (^)(NSString *assetID))successHandle
                           failHandle:(void (^)(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail))failHandle {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveFileToAppAlbumWithFileURL:fileURL successHandle:successHandle failHandle:failHandle];
        });
        return;
    }
    
    NSError *error = nil;
    __block NSString *assetID = nil;
    
    // 保存图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileURL].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !failHandle ? : failHandle(assetID, NO, YES);
        });
        return;
    }
    
    [self __appAssetCollectionInsertAsset:assetID successHandle:successHandle failHandle:failHandle];
}

#pragma mark 将照片/视频/文件转移到App相册
- (void)__appAssetCollectionInsertAsset:(NSString *)assetID
                          successHandle:(void (^)(NSString *assetID))successHandle
                             failHandle:(void (^)(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail))failHandle {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self __appAssetCollectionInsertAsset:assetID successHandle:successHandle failHandle:failHandle];
        });
        return;
    }
    
    // 获得相册
    PHAssetCollection *appAssetCollection = self.appAssetCollection;
    if (appAssetCollection == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !failHandle ? : failHandle(assetID, YES, NO);
        });
        return;
    }
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
    
    // 添加刚才保存的图片到【自定义相册】
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:appAssetCollection];
        [request insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 最后的判断
        if (error) {
            !failHandle ? : failHandle(assetID, NO, YES);
        } else {
            !successHandle ? : successHandle(assetID);
        }
    });
}

#pragma mark - 获取本app相册（没有则创建）

- (PHAssetCollection *)appAssetCollection {
    
    // 步骤：获取相册名字 --> 从自定义相册中获取相册“数组” --> 从相册“数组”中查找有没有跟名字一样的相册
    // --> 有 --> 直接返回
    // --> 没有 --> 创建新的相册再返回
    
    // 1.获取相册名字
    // 获取Info.plist
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    // 获取app的名称
    //        title = infoDic[@"CFBundleName"];
    NSString *title = infoDic[(__bridge NSString *)kCFBundleNameKey];
    // iOS9之后不需要加“__bridge”
    
    // 2.查找相册
    // PHAssetCollectionTypeAlbum 自定义相册
    // PHAssetCollectionSubtypeAlbumRegular 标准相册
    
    // PHAssetCollectionTypeSmartAlbum 智能相册（系统相册）
    // PHAssetCollectionSubtypeSmartAlbumUserLibrary 相机胶卷相册
    
    // 获取查询结果（相册“数组”）
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // PHFetchResult类遵守了NSFastEnumeration（快速遍历）协议，可使用for in
    for (PHAssetCollection *collection in fetchResult) {
        if ([title isEqualToString:collection.localizedTitle]) {
            // 有的话就直接返回
            return collection;
        }
    }
    
    // 没有则新建相册（为了创建之后就能马上获取到相册）
    
    // 创建自定义相册 [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title]
    // 该方法只能写在 -[PHPhotoLibrary performChanges:] 或 -[PHPhotoLibrary performChangesAndWait:] 里面的block中执行（任何增删改操作都是）
    
    NSError *error = nil;
    // 相册唯一标识
    __block NSString *localIdentifier = nil;
    
    // 使用同步方法
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 获取相册唯一标识
        localIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
        
        /**
         * 【注意】：为什么不在这里直接获取PHAssetCollection对象？
         那是因为这里执行creationRequestForAssetCollectionWithTitle之后并没有马上创建好相册，但会返回一个占位用的相册（并不是真实存在的相册，但会包含将来创建好的相册的信息，例如唯一标识），从占位相册可获取相册的唯一标识，在同步方法结束后，再通过这个唯一标识查询该相册
         */
        
    } error:&error];
    
    if (error) {
        return nil;
    }
    
    // 由于用的是同步方法，但来到这里时，相册就已经创建好了，而在方法的block里时还没有创建好
    // 通过唯一标识查询相册（参数为数组，只传了一个标识，所以获得的相册也就只有一个）
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[localIdentifier] options:nil];
    
    return result.firstObject;
}

#pragma mark - 图片处理

- (UIImage *)__imageFixOrientation:(UIImage *)image {
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
