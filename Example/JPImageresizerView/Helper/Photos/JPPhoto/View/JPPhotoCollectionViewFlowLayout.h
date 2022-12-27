//
//  JPPhotoCollectionViewFlowLayout.h
//  Infinitee2.0
//
//  Created by 周健平 on 2019/6/13.
//  Copyright © 2019 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPPhotoCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, copy) CGRect (^getLayoutAttributeFrame)(NSIndexPath *indexPath);
@end

NS_ASSUME_NONNULL_END
