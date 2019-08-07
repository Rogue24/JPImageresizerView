//
//  JPBrowseImagesViewController.h
//  Infinitee2.0
//
//  Created by guanning on 2017/1/3.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPBrowseImageCell.h"

@protocol JPBrowseImagesDelegate <NSObject>

/*!
 @method
 @brief 获取当前位置的对应的imageView
 @param currIndex --- 当前位置
 @discussion 一般用于打开的那个imageView
 */
- (UIImageView *)getOriginImageView:(NSInteger)currIndex;

/*!
 @method
 @brief 获取当前位置的图片高宽比（h:w）
 @param currIndex --- 当前位置
 @discussion 以屏幕宽度为基准，获取该值得到图片高度
 */
- (CGFloat)getImageHWScale:(NSInteger)currIndex;

/*!
 @method
 @brief 打开/退出时是否切割圆角
 @param currIndex --- 当前位置
 @discussion 打开的imageView有圆角的话，退出时过程还原圆角
 */
- (BOOL)isCornerRadiusTransition:(NSInteger)currIndex;

/*!
 @method
 @brief 是否以变透明的方式退出
 @param currIndex --- 当前位置
 @discussion 渐变形式
 */
- (BOOL)isAlphaTransition:(NSInteger)currIndex;

/*!
 @method
 @brief 转换图片时的回调
 @param lastIndex --- 上个位置
 @param currIndex --- 当前位置
 @discussion 切换到新的位置，可以在这里将上个位置对应的imageView隐藏掉
 */
- (void)flipImageViewWithLastIndex:(NSInteger)lastIndex currIndex:(NSInteger)currIndex;

/*!
 @method
 @brief 完全退出的回调
 @param currIndex --- 当前位置
 @discussion 可在这里清理缓存
 */
- (void)dismissComplete:(NSInteger)currIndex;

/*!
 @method
 @brief 设置cell的内容的回调（例如用sd加载image）
 @param cell --- 当前的cell
 @param index --- cell位置
 @param progressBlock --- 加载中的block，调用这个block显示进度
 @param completeBlock --- 加载完的block，调用这个block显示图片、修正位置
 @discussion 显示cell前一刻的回调，自定义如何展示，并不在内部设置或使用第三方
 */
- (void)cellRequestImage:(JPBrowseImageCell *)cell
                   index:(NSInteger)index
           progressBlock:(void(^)(NSInteger kIndex, JPBrowseImageModel *kModel, float percent))progressBlock
           completeBlock:(void(^)(NSInteger kIndex, JPBrowseImageModel *kModel, UIImage *resultImage))completeBlock;

/*!
 @method
 @brief 设置cell的内容【失败】的回调
 @param model --- 对应模型
 @param index --- cell位置
 @discussion 失败的处理
 */
- (void)requestImageFailWithModel:(JPBrowseImageModel *)model index:(NSInteger)index;

/*!
 @method
 @brief 获取导航栏退出按钮的图标
 @discussion isShowNavigationBar设置为YES才会触发
 */
- (NSString *)getNavigationDismissIcon;

/*!
 @method
 @brief 获取导航栏右侧按钮的图标
 @discussion isShowNavigationBar设置为YES才会触发
 */
- (NSString *)getNavigationOtherIcon;

/*!
 @method
 @brief 导航栏右侧按钮的事件处理
 @param browseImagesVC --- 浏览控制器
 @param model --- 对应模型
 @param index --- cell位置
 @discussion isShowNavigationBar设置为YES才会触发
 */
- (void)browseImagesVC:(JPBrowseImagesViewController *)browseImagesVC navigationOtherHandleWithModel:(JPBrowseImageModel *)model index:(NSInteger)index;

@end

@interface JPBrowseImagesViewController : UIViewController

/*!
 @method
 @brief 实例方法
 @param delegate --- 代理
 @param totalCount --- 总数
 @param isShowProgress --- 是否在加载图片时显示进度
 @param isShowNavigationBar --- 是否带导航栏（暂时废用，还没适配好）
 @discussion 创建的类方法，要有代理且实现代理方法
 */
+ (instancetype)browseImagesViewControllerWithDelegate:(id<JPBrowseImagesDelegate>)delegate
                                            totalCount:(NSInteger)totalCount
                                             currIndex:(NSInteger)currIndex
                                        isShowProgress:(BOOL)isShowProgress
                                   isShowNavigationBar:(BOOL)isShowNavigationBar;

- (void)willTransitionAnimateion:(BOOL)isPresent;
- (void)transitionAnimateion:(BOOL)isPresent;
- (void)transitionDoneAnimateion:(BOOL)isPresent complete:(void(^)(void))complete;
- (void)dismiss;

@property (nonatomic, weak, readonly) UIView *bgView;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (nonatomic, assign, readonly) CGRect contentFrame;

@property (nonatomic, weak) id<JPBrowseImagesDelegate> delegate;
@property (nonatomic, copy) NSArray<JPBrowseImageModel *> *dataSource;
@property (nonatomic, assign, readonly) NSInteger currIndex;
@end
