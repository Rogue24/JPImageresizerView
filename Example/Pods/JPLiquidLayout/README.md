# JPLiquidLayout

[![CI Status](https://img.shields.io/travis/Rogue24/JPLiquidLayout.svg?style=flat)](https://travis-ci.org/Rogue24/JPLiquidLayout)
[![Version](https://img.shields.io/cocoapods/v/JPLiquidLayout.svg?style=flat)](https://cocoapods.org/pods/JPLiquidLayout)
[![License](https://img.shields.io/cocoapods/l/JPLiquidLayout.svg?style=flat)](https://cocoapods.org/pods/JPLiquidLayout)
[![Platform](https://img.shields.io/cocoapods/p/JPLiquidLayout.svg?style=flat)](https://cocoapods.org/pods/JPLiquidLayout)

## 简介

流式布局：流水方式排列，元素宽高比保持不变，能完整展示每个元素，每行高度相同且不会超过最大列数。

    功能介绍：
        1. 多种参数可自定义化；
        2. 包含ViewModel和CollectionViewLaout两种形式的使用；
        3. CollectionViewLaout形式下包含单个元素的增、删、改动画效果
        4. 简单易用。

    注意：
        1. 目前仅支持垂直方向
        2. CollectionViewLaout形式下目前仅支持单个section的情况；
        3. CollectionViewLaout形式下的动画效果目前仅支持单个元素的。

- 画面展示：

![image](https://github.com/Rogue24/JPLiquidLayout/raw/master/Cover/cover.gif)

- 相册照片应用：

![image](https://github.com/Rogue24/JPLiquidLayout/raw/master/Cover/photos.gif)

## 如何使用

### 一. ViewModel形式
1. viewModel得遵守JPLiquidLayoutProtocol协议（用于记录元素的位置信息，如frame）；
2. 然后使用JPLiquidLayoutTool计算所有元素的位置；
3. collectionView需要使用UICollectionViewFlowLayout布局，并且需要在"- (CGSize)collectionView:layout:sizeForItemAtIndexPath:"返回viewMdeol中计算好的的cellSize。

```objc
// 在UICollectionViewDelegateFlowLayout的代理方法中返回viewModel的cellSize
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPCollectionViewCellViewModel *cellVM = self.cellVMs[indexPath.item];\
    return cellVM.jp_itemFrame.size;
}
```

### 二. JPLiquidLayout形式
1. JPLiquidLayout是继承于UICollectionViewFlowLayout的布局类，使用JPLiquidLayout作为collectionView的collectionViewLayout；
2. 不需要JPLiquidLayoutTool进行计算，内部已进行计算。

```objc
// 初始化配置
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithCollectionViewLayout:layout]) {
        if ([layout isKindOfClass:JPLiquidLayout.class]) {
            JPLiquidLayout *liquidLayout = (JPLiquidLayout *)layout;

            // 配置基本参数
            liquidLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
            liquidLayout.minimumLineSpacing = 2;
            liquidLayout.minimumInteritemSpacing = 2;

            // 配置其他参数
            liquidLayout.maxCol = 4;
            liquidLayout.maxWidth = [UIScreen mainScreen].bounds.size.width - liquidLayout.sectionInset.left - liquidLayout.sectionInset.right;
            liquidLayout.baseHeight = liquidLayout.maxWidth * 0.5;
            liquidLayout.itemMaxWhScale = 16.0 / 9.0;

            // 配置回调block，用于获取相应的图片宽高比
            __weak typeof(self) weakSelf = self;
            liquidLayout.itemWhScale = ^CGFloat(NSIndexPath *indexPath) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf || strongSelf.picModels.count == 0) return 1;
                    return [strongSelf.picModels[indexPath.item] picWhScale];
            };
        }
        self.picModels = [NSMutableArray array];
    }
    return self;
}
```

#### ViewModel形式和JPLiquidLayout形式的对比
- ViewModel形式：图片数量很多时（例如相册照片有几千张的情况下）使用ViewModel形式效果更优，JPLiquidLayout形式会有些许卡顿（后续优化），每次数据发生变化都需要使用JPLiquidLayoutTool进行计算更新布局；
- JPLiquidLayout形式：代码会更简洁，只需要初始化时配置好参数，后续不需要别的操作。

### 增、删、改三种动画效果
- 使用ViewModel形式使用系统自带的方法即可；
- 使用JPLiquidLayout形式，则需要设置singleAnimated属性为YES（默认就为YES），同样使用系统自带的方法即可；
- 目前只支持单个元素的增删改动画，后续添加多个组合的动画和挪动动画。

1. 增（demo中为点击添加）
```objc
[self.collectionView insertItemsAtIndexPaths:@[indexPath]];
```
![image](https://github.com/Rogue24/JPLiquidLayout/raw/master/Cover/insert.gif)

2. 删（demo中为点击删除）
```objc
[self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
```
![image](https://github.com/Rogue24/JPLiquidLayout/raw/master/Cover/delete.gif)

3. 改（demo中为点击替换）
```objc
[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
```
![image](https://github.com/Rogue24/JPLiquidLayout/raw/master/Cover/reload.gif)

###

## 安装

JPLiquidLayout 可通过[CocoaPods](http://cocoapods.org)安装，只需添加下面一行到你的podfile：

```ruby
pod 'JPLiquidLayout'
```

## 反馈地址

邮箱：zhoujianping24@hotmail.com

博客：https://www.jianshu.com/u/2edfbadd451c

## License

JPLiquidLayout is available under the MIT license. See the LICENSE file for more info.
