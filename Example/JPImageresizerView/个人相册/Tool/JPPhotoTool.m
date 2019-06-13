//
//  JPPhotoTool.m
//  Infinitee2.0
//
//  Created by guanning on 2017/4/12.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPPhotoTool.h"
#import "UICollectionView+Convenience.h"
#import "NSIndexSet+Convenience.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface JPPhotoTool () <PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) PHImageRequestOptions *fastOptions;
@property (nonatomic, strong) PHImageRequestOptions *highQualityOptions;
@property (nonatomic, assign) BOOL isRegisterChange;
@property (nonatomic, strong) PHFetchResult *changeResult;
@property (nonatomic, strong) PHAssetCollection *currCollection;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSOperationQueue *queue;
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

@implementation JPPhotoTool

static CGSize JPThumbnailPhotoSize;

#pragma mark - singleton

static JPPhotoTool *_sharedInstance;

+ (instancetype)sharedInstance {
    if(_sharedInstance == nil) {
        _sharedInstance = [[JPPhotoTool alloc] init];
    }
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

- (id)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super init];
        [_sharedInstance baseSetup];
    });
    return _sharedInstance;
}

- (void)baseSetup {
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    // 照片获取条件
    /**
     * PHImageRequestOptionsResizeModeNone,
     * PHImageRequestOptionsResizeModeFast, //根据传入的size，迅速加载大小相匹配(略大于或略小于)的图像
     * PHImageRequestOptionsResizeModeExact //精确的加载与传入size相匹配的图像
     */
    
    self.fastOptions = [[PHImageRequestOptions alloc] init];
    self.fastOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
//    self.fastOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    self.fastOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    
    self.highQualityOptions = [[PHImageRequestOptions alloc] init];
    self.highQualityOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    self.highQualityOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    self.queue = [[NSOperationQueue alloc] init];
}

#pragma mark - 配置collectionView

- (void)setupCollectionView:(UICollectionView *)collectionView thumbnailPhotoSize:(CGSize)thumbnailPhotoSize {
    self.collectionView = collectionView;
    JPThumbnailPhotoSize = thumbnailPhotoSize;
    [self resetCachedAssets];
}

#pragma mark - 跳转设置相册权限

- (void)jurisdictionAlertWithTitle:(NSString *)title
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
            [SVProgressHUD showErrorWithStatus:@"无法前往设置页面"];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !cancelHandle ? : cancelHandle();
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:action];
    [alertController addAction:cancel];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 基本相册查询配置

- (PHFetchOptions *)baseFetchOptions {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    return options;
}

#pragma mark - 监听相册权限

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
    __weak typeof(self) wSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            switch (status) {
                case PHAuthorizationStatusDenied:       // 还不确定
                {
                    if (oldStatus != PHAuthorizationStatusNotDetermined) {
                        // 已经点了拒绝
                        [sSelf jurisdictionAlertWithTitle:@"没有访问照片的权限" message:@"请前往设置开启照片访问权限" isAlbum:YES cancelHandle:^{
                            !alreadyRefuseBlock ? : alreadyRefuseBlock();
                        }];
                    } else if (oldStatus == PHAuthorizationStatusNotDetermined) {
                        // 点击拒绝
                        if (refuseBlock) {
                            refuseBlock();
                        } else {
                            [sSelf jurisdictionAlertWithTitle:@"您已拒绝访问照片的权限" message:@"需要开启照片访问权限才可以打开相册" isAlbum:YES cancelHandle:^{
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
                        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:sSelf];
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
                        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                    }
                    break;
                }
            }
        });
    }];
    
}

#pragma mark - 监听相册权限

- (void)cameraAuthorityWithAllowAccessAuthorityHandler:(void (^)(void))allowBlock
                          refuseAccessAuthorityHandler:(void (^)(void))refuseBlock
                   alreadyRefuseAccessAuthorityHandler:(void (^)(void))alreadyRefuseBlock
                          canNotAccessAuthorityHandler:(void (^)(void))canNotBlock {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (canNotBlock) {
            canNotBlock();
        } else {
            // 若不可用则退出方法
            [SVProgressHUD showErrorWithStatus:@"您的相机不能使用"];
        }
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    // AVAuthorizationStatusAuthorized 允许
    // AVAuthorizationStatusNotDetermined 用户还没决定
    // AVAuthorizationStatusDenied 用户已经拒绝
    
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        __weak typeof(self) wSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wSelf) sSelf = wSelf;
                if (!sSelf) return;
                if (granted) {
                    !allowBlock ? : allowBlock();
                } else {
                    if (refuseBlock) {
                        refuseBlock();
                    } else {
                        [sSelf jurisdictionAlertWithTitle:@"您已拒绝访问相机的权限" message:@"需要开启相机访问权限才可以使用相机" isAlbum:NO cancelHandle:^{
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
            [self jurisdictionAlertWithTitle:@"没有访问相机的权限" message:@"需要开启相机访问权限才可以使用相机" isAlbum:NO cancelHandle:^{
                !alreadyRefuseBlock ? : alreadyRefuseBlock();
            }];
        }
    }
}


#pragma mark - 移除相册监听

- (void)unRegisterChange {
    if (self.isRegisterChange) {
        self.isRegisterChange = NO;
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
    self.changeResult = nil;
    self.currCollection = nil;
    self.photoLibraryDidChangeHandler = nil;
    [self resetCachedAssets];
}

#pragma mark - PHPhotoLibraryChangeObserver 相册监听回调

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
        
        [self resetCachedAssets];
    }
    
}

#pragma mark - 获取最新照片

- (PHAsset *)getNewestAsset {
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:self.baseFetchOptions];
    return assetsFetchResults.firstObject;
}

#pragma mark - 获取所有照片

- (void)getAllAssetInPhotoAblumWithFastEnumeration:(AssetFastEnumeration)fastEnumeration
                                        completion:(void (^)(void))completion {
    
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
    
    [self.queue addOperationWithBlock:^{
        
        NSInteger maxIdx = count - 1;
        
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL *stop) {
            
            PHAsset *asset = (PHAsset *)obj;
            // asset.localIdentifier  唯一标识
            
            !fastEnumeration ? : fastEnumeration(asset, idx, count);
            
            if (idx == maxIdx) {
                !completion ? : completion();
            }
            
        }];
    }];
    
}

#pragma mark - 获取指定相册内的所有照片

- (void)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                   fastEnumeration:(AssetFastEnumeration)fastEnumeration
                        completion:(void (^)(void))completion {
    
    PHFetchResult *fetchResult;
    NSInteger count = 0;
    if (assetCollection) {
        fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.baseFetchOptions];
        count = [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    } else {
        fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.baseFetchOptions];
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
    
    [self.queue addOperationWithBlock:^{
        
        NSInteger maxIdx = fetchResult.count - 1;
        
        __block NSInteger index = 0;
        
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PHAsset *asset = (PHAsset *)obj;
            // asset.localIdentifier  唯一标识
            
            if (asset.mediaType == PHAssetMediaTypeImage) {
                !fastEnumeration ? : fastEnumeration(asset, index, count);
                index += 1;
                
                // 倒序排列方法1：总是插到第1个
                //                [photoObjects insertObject:photoObj atIndex:0];
                
                //                if (count < 10) {
                //                    JPLog(@"~~~~~~~~~~~~~~~%zd~~~~~~~~~~~~~~~~", count)
                //                    JPLog(@"%@", asset);
                //                    JPLog(@"==============================");
                //                }
            }
            
            if (idx == maxIdx) {

                // 倒序排列方法2：网上方法
                //                NSArray *daoxuArray = [[photoObjects reverseObjectEnumerator] allObjects];

                !completion ? : completion();
            }
            
        }];
        
    }];
    
}

#pragma mark - 解析照片

- (void)requestThumbnailPhotoForAsset:(PHAsset *)asset
                        resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result))resultHandler {
    [self.imageManager requestImageForAsset:asset targetSize:JPThumbnailPhotoSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        !resultHandler ? : resultHandler(asset, image);
        
//        if (info[PHImageResultIsInCloudKey] && !image) {
//            !resultHandler ? : resultHandler(asset, nil);
//            PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
//            option.networkAccessAllowed = YES;
//            option.resizeMode = PHImageRequestOptionsResizeModeFast;
//            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
//                resultImage = [resultImage resizeImageWithSize:JPThumbnailPhotoSize];
//                if (resultImage) {
//                    !resultHandler ? : resultHandler(asset, resultImage);
//                }
//            }];
//            return;
//        }
//        
//        BOOL downloadFinined =
//        ![info[PHImageCancelledKey] boolValue] &&
//        !info[PHImageErrorKey] &&
//        ![info[PHImageResultIsDegradedKey] boolValue];
//        
//        if (downloadFinined && image) {
//            !resultHandler ? : resultHandler(asset, image);
//        }
        
    }];
}

- (void)requestThumbnailPhotoForAsset:(PHAsset *)asset
                           targetSize:(CGSize)targetSize
                  isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                        resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result))resultHandler {
    [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        if (resultHandler) {
            if (isJustGetFinalPhoto) {
                BOOL downloadFinined = (!info[PHImageErrorKey] &&
                                        ![info[PHImageCancelledKey] boolValue] &&
                                        ![info[PHImageResultIsDegradedKey] boolValue]);
                if (downloadFinined) resultHandler(asset, image);
            } else {
                resultHandler(asset, image);
            }
        }
    }];
}

- (void)requestLargePhotoForAsset:(PHAsset *)asset
                       targetSize:(CGSize)targetSize
                       isFastMode:(BOOL)isFastMode
           isShouldFixOrientation:(BOOL)isFixOrientation
                    resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler {
    
    // [PHImageManager defaultManager]
    // [PHCachingImageManager defaultManager]
    
    // param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    
    PHImageRequestOptions *options = isFastMode ? self.fastOptions : self.highQualityOptions;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        
        if (!resultHandler) return;
        
        /**
         
         * resultHandler中的info 字典提供了关于当前请求状态的信息，比如：
         
            - 图像是否必须从 iCloud 请求 (如果你初始化时将 networkAccessAllowed 设置成 false，那么就必须重新请求图像) —— PHImageResultIsInCloudKey 。
            - 当前递送的 UIImage 是否是最终结果的低质量格式。当高质量图像正在下载时，这个可以让你给用户先展示一个预览图像 —— PHImageResultIsDegradedKey。
            - 请求 ID (可以便捷的取消请求)，以及请求是否已经被取消。 —— PHImageResultRequestIDKey 和 PHImageCancelledKey。
            - 如果没有图像提供给 result handler，字典内还会有一个错误信息 —— PHImageErrorKey。
         
         */
        
        // Download image from iCloud / 从iCloud下载图片
        if (info[PHImageResultIsInCloudKey] && !image) {
            !resultHandler ? : resultHandler(asset, nil, info);
            PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
            option.networkAccessAllowed = YES;
            if (isFastMode) {
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            } else {
                option.resizeMode = PHImageRequestOptionsResizeModeExact;
                option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            }
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                BOOL downloadFinined = (!info[PHImageErrorKey] &&
                                        ![info[PHImageCancelledKey] boolValue] &&
                                        ![info[PHImageResultIsDegradedKey] boolValue]);
                if (downloadFinined) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self resizeImage:resultImage size:targetSize];
                    if (resultImage) {
                        if (isFixOrientation) resultImage = [self imageFixOrientation:resultImage];
                        resultHandler(asset, resultImage, info);
                    }
                }
            }];
            return;
        }
        
        BOOL downloadFinined = (!info[PHImageErrorKey] &&
                                ![info[PHImageCancelledKey] boolValue] &&
                                ![info[PHImageResultIsDegradedKey] boolValue]);
        
        if (downloadFinined && image) {
            if (isFixOrientation) image = [self imageFixOrientation:image];
            resultHandler(asset, image, info);
        }
    }];
    
}

- (void)requestOriginalPhotoForAsset:(PHAsset *)asset
                          targetSize:(CGSize)targetSize
                          isFastMode:(BOOL)isFastMode
              isShouldFixOrientation:(BOOL)isFixOrientation
                 isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                       resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler {
    PHImageRequestOptions *options = isFastMode ? self.fastOptions : self.highQualityOptions;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        if (resultHandler) {
            if (isJustGetFinalPhoto) {
                BOOL downloadFinined = (!info[PHImageErrorKey] &&
                                        ![info[PHImageCancelledKey] boolValue] &&
                                        ![info[PHImageResultIsDegradedKey] boolValue]);
                if (downloadFinined) resultHandler(asset, image, info);
            } else {
                resultHandler(asset, image, info);
            }
        }
    }];
}

#pragma mark - 获取所有相册

- (void)getAllAssetCollectionWithFastEnumeration:(AssetCollectionFastEnumeration)fastEnumeration
                                      completion:(void(^)(void))completion {
    
    [self.queue addOperationWithBlock:^{
        __block NSInteger index = 0;
        __block NSInteger maxIdx = 0;
        void (^getAllUserCreateAssetCollection)(void) = ^{
            PHFetchResult *userAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            NSInteger userAlbumsCount = userAlbumsFR.count;
            if (userAlbumsCount == 0) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    !completion ? : completion();
                }];
            } else {
                maxIdx = userAlbumsCount - 1;
                [userAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
                    PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                    !fastEnumeration ? : fastEnumeration(collection, index, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                    index += 1;
                    if (idx == maxIdx) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            !completion ? : completion();
                        }];
                    }
                }];
            }
        };
        
        PHFetchResult *allPhotoAlbumsFR = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.baseFetchOptions];
        !fastEnumeration ? : fastEnumeration(nil, index, allPhotoAlbumsFR.count);
        index += 1;
        
        PHFetchResult *systemAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        NSInteger systemAlbumsCount = systemAlbumsFR.count;
        if (systemAlbumsCount == 0) {
            getAllUserCreateAssetCollection();
        } else {
            maxIdx = systemAlbumsCount - 1;
            [systemAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
                PHAssetCollectionSubtype subtype = collection.assetCollectionSubtype;
                if (subtype == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
                    subtype == PHAssetCollectionSubtypeSmartAlbumFavorites ||
                    subtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ||
                    subtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                    !fastEnumeration ? : fastEnumeration(collection, index, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                    index += 1;
                } else if (@available(iOS 9.0, *)) {
                    if (subtype == PHAssetCollectionSubtypeSmartAlbumSelfPortraits) {
                        PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                        !fastEnumeration ? : fastEnumeration(collection, index, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                        index += 1;
                    }
                }
                if (idx == maxIdx) {
                    getAllUserCreateAssetCollection();
                }
            }];
        }
    }];
}

#pragma mark - 获取所有系统的相册

- (void)getAllSystemCreateAssetCollectionWithFastEnumeration:(AssetCollectionFastEnumeration)fastEnumeration
                                                  completion:(void(^)(void))completion {
    [self.queue addOperationWithBlock:^{
        PHFetchResult *systemAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        NSInteger systemAlbumsCount = systemAlbumsFR.count;
        if (systemAlbumsCount == 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                !completion ? : completion();
            }];
            return;
        }
        NSInteger maxIdx = systemAlbumsCount - 1;
        __block NSInteger index = 0;
        [systemAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetCollectionSubtype subtype = collection.assetCollectionSubtype;
            // PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,
            // PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,
            // PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,
            // PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,
            // PHAssetCollectionSubtypeSmartAlbumSelfPortraits = 210
            
            if (subtype == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
                subtype == PHAssetCollectionSubtypeSmartAlbumFavorites ||
                subtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ||
                subtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                !fastEnumeration ? : fastEnumeration(collection, index, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                index += 1;
            } else if (@available(iOS 9.0, *)) {
                if (subtype == PHAssetCollectionSubtypeSmartAlbumSelfPortraits) {
                    PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
                    !fastEnumeration ? : fastEnumeration(collection, index, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
                    index += 1;
                }
            }
            if (idx == maxIdx) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    !completion ? : completion();
                }];
            }
        }];
    }];
}

#pragma mark - 获取所有用户创建的相册

- (void)getAllUserCreateAssetCollectionWithFastEnumeration:(AssetCollectionFastEnumeration)fastEnumeration
                                                completion:(void(^)(void))completion {
    [self.queue addOperationWithBlock:^{
        //获取所有用户创建的相册
        PHFetchResult *userAlbumsFR = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        NSInteger userAlbumsCount = userAlbumsFR.count;
        if (userAlbumsCount == 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                !completion ? : completion();
            }];
            return;
        }
        NSInteger maxIdx = userAlbumsCount - 1;
        [userAlbumsFR enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            PHFetchResult *albumsFR = [PHAsset fetchAssetsInAssetCollection:collection options:self.baseFetchOptions];
            !fastEnumeration ? : fastEnumeration(collection, idx, [albumsFR countOfAssetsWithMediaType:PHAssetMediaTypeImage]);
            if (idx == maxIdx) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    !completion ? : completion();
                }];
            }
        }];
    }];
}

#pragma mark - 保存照片到相机胶卷

- (void)savePhotoWithImage:(UIImage *)image
             successHandle:(void (^)(NSString *assetID))successHandle
                failHandle:(void (^)(void))failHandle {
    NSError *error = nil;
    
    // 创建占位照片对象
    __block PHObjectPlaceholder *placeholder = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        placeholder = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
    } error:&error];
    
    if (error) {
        // 保存失败
        !failHandle ? : failHandle();
    } else {
        // 保存成功
        !successHandle ? : successHandle(placeholder.localIdentifier);
    }
}

/**
 @method
 @brief 保存图片到【App相册】
 */
- (BOOL)savePhotoToAppAlbumSuccessWithImage:(UIImage *)image {
    
    NSError *error = nil;
    __block NSString *assetID = nil;
    
    // 保存图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"保存图片失败！"];
        return NO;
    }
    
    // 获取刚才保存的相片
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
    
    // 获得相册
    PHAssetCollection *createdCollection = self.appAssetCollection;
    if (createdCollection == nil) {
        [SVProgressHUD showErrorWithStatus:@"创建或者获取相册失败！"];
        return NO;
    }
    
    // 添加刚才保存的图片到【自定义相册】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 最后的判断
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"保存图片失败！"];
        return NO;
    } else {
        [SVProgressHUD showSuccessWithStatus:@"保存图片成功！"];
        return YES;
    }
    
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

#pragma mark - 缓存处理

- (void)resetCachedAssets {
    if (!self.collectionView) return;
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssetsWithStartCachingBlock:(AssetsCachingHandle)startCachingBlock stopCachingBlock:(AssetsCachingHandle)stopCachingBlock {
    if (!self.collectionView) return;
    
    BOOL isViewVisible = self.collectionView && self.collectionView.window != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta <= CGRectGetHeight(self.collectionView.bounds) / 3.0f) return;
    
    // Compute the assets to start caching and to stop caching.
    NSMutableArray *addedIndexPaths = [NSMutableArray array];
    NSMutableArray *removedIndexPaths = [NSMutableArray array];
    
    [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
        NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
        [removedIndexPaths addObjectsFromArray:indexPaths];
    } addedHandler:^(CGRect addedRect) {
        NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
        [addedIndexPaths addObjectsFromArray:indexPaths];
    }];
    
    //        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
    //        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
    
    GetAssetsCompletion startCaching = ^(NSArray *assets) {
        [self.imageManager startCachingImagesForAssets:assets targetSize:JPThumbnailPhotoSize contentMode:PHImageContentModeAspectFill options:nil];
    };
    
    GetAssetsCompletion stopCaching = ^(NSArray *assets) {
        [self.imageManager stopCachingImagesForAssets:assets targetSize:JPThumbnailPhotoSize contentMode:PHImageContentModeAspectFill options:nil];
    };
    
    startCachingBlock(addedIndexPaths, startCaching);
    stopCachingBlock(removedIndexPaths, stopCaching);
    
    self.previousPreheatRect = preheatRect;
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

#pragma mark - 图片处理

- (UIImage *)imageFixOrientation:(UIImage *)image {
    
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

- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size {
    
    @autoreleasepool {
        UIGraphicsBeginImageContext(size);
        
        [image drawInRect:CGRectMake(0, 0, size.width + 1, size.height + 1)];
        
        UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return resizeImage;
    }
    
}

@end
