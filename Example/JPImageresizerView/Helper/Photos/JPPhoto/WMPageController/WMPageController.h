//
//  WMPageController.h
//  WMPageController
//
//  Created by Mark on 15/6/11.
//  Copyright (c) 2015年 yq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMScrollView.h"

@class WMPageController;

/*
 *  WMPageController 的缓存设置，默认缓存为无限制，当收到 memoryWarning 时，会自动切换到低缓存模式 (WMPageControllerCachePolicyLowMemory)，并在一段时间后切换到 High .
 收到多次警告后，会停留在到 WMPageControllerCachePolicyLowMemory 不再增长
 *
 *  The Default cache policy is No Limit, when recieved memory warning, page controller will switch mode to 'LowMemory'
 and continue to grow back after a while.
 If recieved too much times, the cache policy will stay at 'LowMemory' and don't grow back any more.
 */
typedef NS_ENUM(NSInteger, WMPageControllerCachePolicy) {
    WMPageControllerCachePolicyDisabled   = -1,  // Disable Cache
    WMPageControllerCachePolicyNoLimit    = 0,   // No limit
    WMPageControllerCachePolicyLowMemory  = 1,   // Low Memory but may block when scroll
    WMPageControllerCachePolicyBalanced   = 3,   // Balanced ↑ and ↓
    WMPageControllerCachePolicyHigh       = 5    // High
};

typedef NS_ENUM(NSUInteger, WMPageControllerPreloadPolicy) {
    WMPageControllerPreloadPolicyNever     = 0, // Never pre-load controller.
    WMPageControllerPreloadPolicyNeighbour = 1, // Pre-load the controller next to the current.
    WMPageControllerPreloadPolicyNear      = 2  // Pre-load 2 controllers near the current.
};

NS_ASSUME_NONNULL_BEGIN
extern NSString *const WMControllerDidAddToSuperViewNotification;
extern NSString *const WMControllerDidFullyDisplayedNotification;
@protocol WMPageControllerDataSource <NSObject>
@optional

/**
 *  To inform how many child controllers will in `WMPageController`.
 *
 *  @param pageController The parent controller.
 *
 *  @return The value of child controllers's count.
 */
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController;

/**
 *  Return a controller that you wanna to display at index. You can set properties easily if you implement this methods.
 *
 *  @param pageController The parent controller.
 *  @param index          The index of child controller.
 *
 *  @return The instance of a `UIViewController`.
 */
- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index;

@required
/**
 Implement this datasource method, in order to customize your own contentView's frame
 
 @param pageController The container controller
 @param contentView The contentView, each is the superview of the child controllers
 @return The frame of the contentView
 */
- (CGRect)pageController:(WMPageController *)pageController viewControllerFrameAtIndex:(NSInteger)index;

@end

@protocol WMPageControllerDelegate <NSObject>
@optional

/**
 *  If the child controller is heavy, put some work in this method. This method will only be called when the controller is initialized and stop scrolling. (That means if the controller is cached and hasn't released will never call this method.)
 *
 *  @param pageController The parent controller (WMPageController)
 *  @param viewController The viewController first show up when scroll stop.
 *  @param info           A dictionary that includes some infos, such as: `index` / `title`
 */
- (void)pageController:(WMPageController *)pageController lazyLoadViewController:(__kindof UIViewController *)viewController index:(NSInteger)index;

/**
 *  Called when a viewController will be cached. You can clear some data if it's not reusable.
 *
 *  @param pageController The parent controller (WMPageController)
 *  @param viewController The viewController will be cached.
 *  @param info           A dictionary that includes some infos, such as: `index` / `title`
 */
- (void)pageController:(WMPageController *)pageController willCachedViewController:(__kindof UIViewController *)viewController index:(NSInteger)index;

/**
 *  Called when a viewController will be appear to user's sight. Do some preparatory methods if needed.
 *
 *  @param pageController The parent controller (WMPageController)
 *  @param viewController The viewController will appear.
 *  @param info           A dictionary that includes some infos, such as: `index` / `title`
 */
- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController index:(NSInteger)index;

/**
 * 【我自己添加的】
 *  手动拖拽前一刻
 */
- (void)pageController:(WMPageController *)pageController scrollViewWillBeginDragging:(UIScrollView *)scrollView;

/**
 * 【我自己添加的】
 *  正在滑动中
 */
- (void)pageController:(WMPageController *)pageController scrollViewDidScroll:(UIScrollView *)scrollView;

/**
 *  完全进入控制器 (即停止滑动后调用)
 *  Called when a viewController will fully displayed, that means, scrollView have stopped scrolling and the controller's view have entirely displayed.
 *
 *  @param pageController The parent controller (WMPageController)
 *  @param viewController The viewController entirely displayed.
 *  @param info           A dictionary that includes some infos, such as: `index` / `title`
 */
- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController index:(NSInteger)index;

@end

@interface WMPageController : UIViewController <UIScrollViewDelegate, WMPageControllerDataSource, WMPageControllerDelegate>

@property (nonatomic, assign) CGRect viewFrame;

@property (nonatomic, weak) id<WMPageControllerDelegate> delegate;
@property (nonatomic, weak) id<WMPageControllerDataSource> dataSource;

/**
 *  Values and keys can set properties when initialize child controlelr (it's KVC)
 *  values keys 属性可以用于初始化控制器的时候为控制器传值(利用 KVC 来设置)
 使用时请确保 key 与控制器的属性名字一致！！(例如：控制器有需要设置的属性 type，那么 keys 所放的就是字符串 @"type")
 */
@property (nonatomic, nullable, strong) NSMutableArray<id> *values;
@property (nonatomic, nullable, strong) NSMutableArray<NSString *> *keys;

/**
 *  各个控制器的 class, 例如:[UITableViewController class]
 *  Each controller's class, example:[UITableViewController class]
 */
@property (nonatomic, nullable, copy) NSArray<Class> *viewControllerClasses;

@property (nonatomic, strong, readonly) UIViewController *currentViewController;

/**
 *  设置选中几号 item
 *  To select item at index
 */
@property (nonatomic, assign) int selectIndex;

/** Whether the controller can scroll. Default is YES. */
@property (nonatomic, assign) BOOL scrollEnable;

/**
 *  是否发送在创建控制器或者视图完全展现在用户眼前时通知观察者，默认为不开启，如需利用通知请开启
 *  Whether notify observer when finish init or fully displayed to user, the default is NO.
 *  See `WMPageConst.h` for more information.
 */
@property (nonatomic, assign) BOOL postNotification;

/**
 *  是否记录 Controller 的位置，并在下次回来的时候回到相应位置，默认为 NO (若当前缓存中存在不会触发)
 *  Whether to remember controller's positon if it's a kind of scrollView controller,like UITableViewController,The default value is NO.
 *  比如 `UITabelViewController`, 当然你也可以在自己的控制器中自行设置, 如果将 Controller.view 替换为 scrollView 或者在Controller.view 上添加了一个和自身 bounds 一样的 scrollView 也是OK的
 */
@property (nonatomic, assign) BOOL rememberLocation __deprecated_msg("Because of the cache policy,this property can abondon now.");

/** 缓存的机制，默认为无限制 (如果收到内存警告, 会自动切换) */
@property (nonatomic, assign) WMPageControllerCachePolicy cachePolicy;

/** 预加载机制，在停止滑动的时候预加载 n 页 */
@property (nonatomic, assign) WMPageControllerPreloadPolicy preloadPolicy;

/** Whether ContentView bounces */
@property (nonatomic, assign) BOOL bounces;

/** 内部容器 */
@property (nonatomic, nullable, weak) WMScrollView *scrollView;

/**
 *  构造方法，请使用该方法创建控制器. 或者实现数据源方法. /
 *  Init method，recommend to use this instead of `-init`. Or you can implement datasource by yourself.
 *
 *  @param classes 子控制器的 class，确保数量与 titles 的数量相等
 *  @param titles  各个子控制器的标题，用 NSString 描述
 *
 *  @return instancetype
 */
- (instancetype)initWithViewControllerClasses:(NSArray<Class> *)classes;

/**
 *  A method in order to reload MenuView and child view controllers. If you had set `itemsMargins` or `itemsWidths` `values` and `keys` before, make sure you have update them also before you call this method. And most important, PAY ATTENTION TO THE COUNT OF THOSE ARRAY.
 该方法用于重置刷新父控制器，该刷新包括顶部 MenuView 和 childViewControllers.如果之前设置过 `itemsMargins` 和 `itemsWidths` `values` 以及 `keys` 属性，请确保在调用 reload 之前也同时更新了这些属性。并且，最最最重要的，注意数组的个数以防止溢出。
 */
- (void)reloadData;

/**
 Layout all views in WMPageController
 @discussion This method will recall `-pageController:preferredFrameForContentView:` and `-pageContoller:preferredFrameForMenuView:`
 */
- (void)forceLayoutSubviews;

/** 当 app 即将进入后台接收到的通知 */
- (void)willResignActive:(NSNotification *)notification;
/** 当 app 即将回到前台接收到的通知 */
- (void)willEnterForeground:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
