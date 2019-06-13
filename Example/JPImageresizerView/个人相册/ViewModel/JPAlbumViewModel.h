//
//  JPAlbumViewModel.h
//  Infinitee2.0
//
//  Created by 周健平 on 2018/8/9.
//  Copyright © 2018 Infinitee. All rights reserved.
//

#import "JPCategoryTitleViewModel.h"
#import "JPPhotoViewModel.h"
#import "JPPhotoTool.h"

@interface JPAlbumViewModel : JPCategoryTitleViewModel
+ (JPAlbumViewModel *)albumViewModelWithAssetCollection:(PHAssetCollection *)assetCollection assetTotalCount:(NSInteger)assetTotalCount;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, assign) NSInteger assetTotalCount;
@property (nonatomic, strong) NSMutableArray<JPPhotoViewModel *> *selectedPhotoVMs;
- (void)selectedPhotoVM:(JPPhotoViewModel *)photoVM;
- (void)deSelectedPhotoVM:(JPPhotoViewModel *)photoVM;
@end
