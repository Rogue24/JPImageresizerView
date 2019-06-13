//
//  JPAlbumViewModel.m
//  Infinitee2.0
//
//  Created by 周健平 on 2018/8/9.
//  Copyright © 2018 Infinitee. All rights reserved.
//

#import "JPAlbumViewModel.h"

@implementation JPAlbumViewModel

- (NSMutableArray<JPPhotoViewModel *> *)selectedPhotoVMs {
    if (!_selectedPhotoVMs) {
        _selectedPhotoVMs = [NSMutableArray array];
    }
    return _selectedPhotoVMs;
}

+ (JPAlbumViewModel *)albumViewModelWithAssetCollection:(PHAssetCollection *)assetCollection assetTotalCount:(NSInteger)assetTotalCount {
    JPAlbumViewModel *albumVM = [JPAlbumViewModel new];
    albumVM.assetCollection = assetCollection;
    albumVM.assetTotalCount = assetTotalCount;
    return albumVM;
}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    self.title = assetCollection ? assetCollection.localizedTitle : @"全部";
}

- (void)setAssetTotalCount:(NSInteger)assetTotalCount {
    _assetTotalCount = assetTotalCount;
    self.count = [NSString stringWithFormat:@"%zd", assetTotalCount];
}

- (void)selectedPhotoVM:(JPPhotoViewModel *)photoVM {
    [self.selectedPhotoVMs addObject:photoVM];
}

- (void)deSelectedPhotoVM:(JPPhotoViewModel *)photoVM {
    for (JPPhotoViewModel *selPhotoVM in self.selectedPhotoVMs) {
        if ([selPhotoVM.asset.localIdentifier isEqualToString:photoVM.asset.localIdentifier]) {
            [self.selectedPhotoVMs removeObject:selPhotoVM];
            break;
        }
    }
}

@end
