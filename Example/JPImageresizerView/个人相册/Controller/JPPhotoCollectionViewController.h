//
//  JPPhotoCollectionViewController.h
//  Infinitee2.0
//
//  Created by 周健平 on 2018/8/10.
//  Copyright © 2018 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPAlbumViewModel;
@class JPPhotoViewModel;
@class JPPhotoCollectionViewController;

@protocol JPPhotoCollectionViewControllerDelegate <NSObject>
- (BOOL)pcVC:(JPPhotoCollectionViewController *)pcVC photoDidSelected:(JPPhotoViewModel *)photoVM;
@end

@interface JPPhotoCollectionViewController : UICollectionViewController
@property (nonatomic, assign) BOOL isBecomeDanielWu;

@property (nonatomic, weak) id<JPPhotoCollectionViewControllerDelegate> pcVCDelegate;

@property (nonatomic, strong) JPAlbumViewModel *albumVM;
@property (nonatomic, strong) NSMutableArray<JPPhotoViewModel *> *photoVMs;

@property (nonatomic, assign) CGFloat hideScale;
@property (nonatomic, assign) CGFloat showScale;
- (void)willBeginScorllHandle;

+ (JPPhotoCollectionViewController *)pcVCWithAlbumVM:(JPAlbumViewModel *)albumVM
                                          sideMargin:(CGFloat)sideMargin
                                           cellSpace:(CGFloat)cellSpace
                                          maxWHSclae:(CGFloat)maxWHSclae
                                              maxCol:(NSInteger)maxCol
                                        pcVCDelegate:(id<JPPhotoCollectionViewControllerDelegate>)pcVCDelegate;

- (void)requestPhotosWithComplete:(void(^)(NSInteger photoTotal))complete;

- (void)insertPhotoVM:(JPPhotoViewModel *)photoVM atIndex:(NSInteger)index;

- (void)removeSelectedPhotoVMs;

@end
