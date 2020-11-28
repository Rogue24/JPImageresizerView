//
//  JPMainViewModel.h
//  JPImageresizerView_Example
//
//  Created by aa on 2020/11/28.
//  Copyright © 2020 ZhouJianPing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPMainHeader.h"
#import "JPMainCell.h"
#import "JPConfigureModel.h"

typedef NS_ENUM(NSUInteger, JPExampleType) {
    JPExampleType_Base,
    JPExampleType_GIFandVideo,
    JPExampleType_Game,
    JPExampleType_Custom
};

@interface JPCellModel : NSObject
+ (NSArray<JPCellModel *> *)examplesCellModels;
+ (void)setupCellSize:(UIEdgeInsets)screenInsets isVer:(BOOL)isVer;
+ (CGSize)cellSize;
@property (nonatomic, strong) JPConfigureModel *model;
@property (nonatomic, assign) BOOL isTopImage;
@property (nonatomic, assign) CGRect imageFrame;
@property (nonatomic, assign) CGPoint imageAnchorPoint;
@property (nonatomic, assign) CGPoint imagePosition;
@property (nonatomic, assign) CGRect titleFrame;
- (void)updateLayout:(BOOL)isVer;
- (void)setupCellUI:(JPMainCell *)cell;
@end

@interface JPHeaderModel : NSObject
+ (NSArray<JPHeaderModel *> *)examplesHeaderModels;
+ (void)setupHeaderSize:(UIEdgeInsets)screenInsets isVer:(BOOL)isVer;
+ (CGSize)headerSize;
@property (nonatomic, assign) JPExampleType type;
@property (nonatomic, copy) NSAttributedString *title;
@property (nonatomic, copy) NSArray<JPCellModel *> *cellModels;
- (void)updateLayout:(BOOL)isVer;
@end

@interface JPMainViewModel : NSObject

@end

