# JPImageresizerView

[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)

[简书](https://www.jianshu.com/p/dec3e33bbce1)

[英文文档（English document）](https://github.com/Rogue24/JPImageresizerView/blob/master/README_EN.md)

## 简介（当前版本：1.3.7）
***新版Demo目前构建中。***

仿微信裁剪图片的一个裁剪小工具。

    目前功能：
        1.能自适应裁剪区域的缩放；
        2.高自由度的参数设定，包括裁剪区域的间距、裁剪宽高比、是否自适应缩放等；
        3.支持最多8个拖拽方向的裁剪区域；
        4.支持上左下右的旋转；
        5.水平和垂直的镜像翻转；
        6.两种边框样式；
        7.支持圆框裁剪；
        8.自定义毛玻璃样式、边框颜色、背景颜色、遮罩透明度；
        9.自定义边框图片。
        10.支持横竖屏切换

    注意：
        1.由于autoLayout不利于手势控制，所以目前使用的是frame布局，暂不支持autoLayout；
        
    努力着的更新内容：
        1.Swift版本；
        3.更多新的边框和遮罩样式；
        4.更多的参数设定；
        5.实现苹果自带的裁剪功能中的自由拖拽旋转方向的效果。

![effect.gif](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/cover.gif)

## 如何使用

#### 初始化
```objc
// 1.配置初始参数（更多可查看JPImageresizerConfigure的头文件）
/**
 * 部分配置参数：
 * 1.resizeImage：裁剪的图片
 * 2.blurEffect：毛玻璃样式
 * 3.borderImage：边框图片
 * 4.frameType & strokeColor：边框样式&颜色
 * 5.bgColor：背景色
 * 6.maskAlpha：遮罩透明度
 * 7.resizeWHScale：裁剪的宽高比
 * 8.contentInsets：裁剪区域与视图的间距
 */
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:image make:^(JPImageresizerConfigure *configure) {
    // 到这里已经有了默认参数值，可以在这里另外设置你想要的参数值（使用了链式编程方式）
    configure
    .jp_resizeImage([UIImage imageNamed:@"Kobe.jpg"])
    .jp_maskAlpha(0.5)
    .jp_strokeColor([UIColor yellowColor])
    .jp_frameType(JPClassicFrameType)
    .jp_contentInsets(contentInsets)
    .jp_bgColor([UIColor orangeColor])
    .jp_isClockwiseRotation(YES)
    .jp_animationCurve(JPAnimationCurveEaseOut);
}];

// 2.创建JPImageresizerView对象
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:self.configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    // 可在这里监听到是否可以重置
    // 如果不需要重置（isCanRecovery为NO），可在这里做相应处理，例如将重置按钮设置为不可点或隐藏
    // 具体操作可参照Demo
    // 注意循环引用
} imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
    // 可在这里监听到裁剪区域是否预备缩放至适合范围
    // 如果预备缩放（isPrepareToScale为YES），此时裁剪、旋转、镜像功能不可用，可在这里做相应处理，例如将对应按钮设置为不可点或隐藏
    // 具体操作可参照Demo
    // 注意循环引用
}];

// 3.添加到视图上
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// 创建后也可以动态修改以上大部分参数（除了maskType和contentInsets）
self.imageresizerView.resizeImage = [UIImage imageNamed:@"Kobe.jpg"]; // 更换裁剪图片（默认带动画效果）
self.imageresizerView.resizeWHScale = 16.0 / 9.0; // 修改裁剪宽高比
self.imageresizerView.initialResizeWHScale = 0.0; // 默认为初始化时的resizeWHScale，调用 -recoveryByInitialResizeWHScale 方法进行重置则 resizeWHScale 会重置为该属性的值

// 注意：iOS11以下的系统，所在的controller最好设置automaticallyAdjustsScrollViewInsets为NO
// 不然imageresizerView会随导航栏或状态栏的变化产生偏移
if (@available(iOS 11.0, *)) {

} else {
    self.automaticallyAdjustsScrollViewInsets = NO;
}
```

#### 横竖屏切换
![screenswitching](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/screenswitching.gif)
```objc
// 需要用户去监听横竖屏的切换，或自己手动切换时，调用该方法刷新
// 1.updateFrame：刷新的Frame（例如横竖屏切换，传入self.view.bounds即可）
// 2.contentInsets：裁剪区域与主视图的内边距
// 3.duration：刷新时长（大于0即带有动画效果）
//【具体操作可参照Demo】
[self.imageresizerView updateFrame:self.view.bounds contentInsets:contentInsets duration:duration];
```

#### 更改边框样式
![concise](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPConciseFrameTypeCover.jpeg)
![classic](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPClassicFrameTypeCover.jpeg)
```objc
// 目前只提供两种边框样式，分别是简洁样式JPConciseFrameType，和经典样式JPClassicFrameType
// 可在初始化或直接设置frameType属性来修改边框样式
self.imageresizerView.frameType = JPClassicFrameType;
```

#### 自定义边框图片
![stretch_mode](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPCustomBorderImage1.jpg)
![tile_mode](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPCustomBorderImage2.jpg)
```objc
// 使用自定义边框图片（例：平铺模式）
UIImage *tileBorderImage = [[UIImage imageNamed:@"dotted_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];

// 设置边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距）
self.imageresizerView.borderImageRectInset = CGPointMake(-1.75, -1.75);

// 设置边框图片（若为nil则使用frameType的边框）
self.imageresizerView.borderImage = tileBorderImage;
```

#### 切换裁剪宽高比
![修改裁剪宽高比的动画效果](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/ivpFV94K5W.gif)
```objc
// 1.自定义参数切换
/**
 * resizeWHScale：    目标裁剪宽高比（0则为任意比例）
 * isToBeArbitrarily：切换之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 * animated：         是否带动画效果
 */
[self.imageresizerView setResizeWHScale:(16.0 / 9.0) isToBeArbitrarily:YES animated:YES];

// 2.直接切换
self.imageresizerView.resizeWHScale = 1.0;
// 默认切换之后保存最新的 resizeWHScale，且自带动画效果，相当于：
[self.imageresizerView setResizeWHScale:1.0 isToBeArbitrarily:NO animated:YES];
```

#### 圆切
![round_resize](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/roundresize.jpg)
```objc
// 设置圆切
// 设置后，resizeWHScale为1:1，半径为宽高的一半，边框的上、左、下、右的中部均可拖动。
[self.imageresizerView roundResize:YES];

// 还原矩形
// 只需设置一下resizeWHScale为任意值即可
self.imageresizerView.resizeWHScale = 0.0;
```

#### 自定义毛玻璃样式、边框颜色、背景颜色、遮罩透明度
```objc
// 设置毛玻璃样式（默认带动画效果）
self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

// 设置边框颜色（默认带动画效果）
self.imageresizerView.strokeColor = UIColor.whiteColor;

// 设置背景颜色（默认带动画效果）
self.imageresizerView.bgColor = UIColor.blackColor;

// 设置遮罩透明度（默认带动画效果）
// PS：跟毛玻璃互斥，当设置了毛玻璃则遮罩为透明
self.imageresizerView.maskAlpha = 0.5; // blurEffect = nil 才生效

// 一步设置毛玻璃样式、边框颜色、背景颜色、遮罩透明度
[self.imageresizerView setupStrokeColor:strokeColor blurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark] bgColor:UIColor.blackColor maskAlpha: 0.5 animated:YES];
```

#### 镜像翻转
![mirror.gif](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/ggseHhuRnt.gif)
```objc
// 1.垂直镜像，YES->沿着Y轴旋转180°，NO->还原
BOOL isVerticalityMirror = !self.imageresizerView.verticalityMirror;
self.imageresizerView.verticalityMirror = isVerticalityMirror;
// 默认自带动画效果，相当于：
[self.imageresizerView setVerticalityMirror:isVerticalityMirror animated:YES];

// 2.水平镜像，YES->沿着X轴旋转180°，NO->还原
BOOL isHorizontalMirror = !self.imageresizerView.horizontalMirror;
self.imageresizerView.horizontalMirror = isHorizontalMirror;
// 默认自带动画效果，相当于：
[self.imageresizerView setHorizontalMirror:isHorizontalMirror animated:YES];
```

#### 旋转
```objc
// 默认逆时针旋转，旋转角度为90°
[self.imageresizerView rotation];

// 若需要顺时针旋转可设置isClockwiseRotation属性为YES
self.imageresizerView.isClockwiseRotation = YES;
```

#### 重置
```objc
// 重置为初始状态，方向垂直向上，可重置为不同的resizeWHScale

// 1.按当前 resizeWHScale 进行重置
/**
 * 使用该方法进行重置，裁剪框的宽高比会按照当前 resizeWHScale 的值进行重置
 */
[self.imageresizerView recoveryByCurrentResizeWHScale];

// isToBeArbitrarily：重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
BOOL isToBeArbitrarily = self.isToBeArbitrarily;   

// 2.按 initialResizeWHScale 进行重置
/**
 * initialResizeWHScale 默认为初始化时的 resizeWHScale，此后可自行修改 initialResizeWHScale 的值
 * 使用该方法进行重置，裁剪框的宽高比会按照 initialResizeWHScale 的值进行重置
 * 若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale = initialResizeWHScale
 */
[self.imageresizerView recoveryByInitialResizeWHScale:isToBeArbitrarily];
    
// 3.按 目标裁剪宽高比 进行重置
/**
 * 使用该方法进行重置，裁剪框的宽高比会按照 目标裁剪宽高比 进行重置
 * 若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale = targetResizeWHScale
 */
CGFloat imageresizeWHScale = self.imageresizerView.imageresizeWHScale; // 获取当前裁剪框的宽高比
[self.imageresizerView recoveryByTargetResizeWHScale:imageresizeWHScale isToBeArbitrarily:isToBeArbitrarily];
```

#### 预览
```objc
// 预览模式：隐藏边框，停止拖拽操作，用于预览裁剪后的区域

self.imageresizerView.isPreview = YES;

// 默认自带动画效果，相当于：
[self.imageresizerView setIsPreview:YES animated:YES];
```

#### 裁剪
```objc
// 裁剪过程是在子线程中执行，回调则切回主线程执行
// 如果是高清图片，调用前可添加HUD提示...
// compressScale：压缩比例（0.0 ~ 1.0），大于等于1.0按原图尺寸裁剪，小于等于0.0则返回nil
// 例：compressScale = 0.5，1000 x 500 --> 500 x 250

// 1.自定义压缩比例进行裁剪
[self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
    // 裁剪完成，resizeImage为裁剪后的图片
    // 注意循环引用
} compressScale:0.7]; // 例：压缩为原图尺寸的70%

// 2.以原图尺寸进行裁剪
[self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
    // 裁剪完成，resizeImage为裁剪后的图片
    // 注意循环引用
}];
```

#### 其他
```objc
// 锁定裁剪区域，锁定后无法拖动裁剪区域，NO则解锁
self.imageresizerView.isLockResizeFrame = YES;

// 旋转至水平方向时是否自适应裁剪区域大小
// 当图片宽度比图片高度小时，该属性默认YES，可手动设为NO
self.imageresizerView.isAutoScale = NO;
```

## 各版本的主要更新

版本 | 更新内容
----|------
1.3.8  | 1. 适配横竖屏切换；<br>2. 废除verBaseMargin和horBaseMargin属性，统一使用contentInsets设置裁剪区域与视图的间距；<br>3. 优化逻辑，减少裁剪误差。  
1.2.1~1.3.6 | 1. 新增圆切样式；<br>2. 中间的点/块可隐藏；<br>3. 可动态切换图片、设置边框颜色和背景颜色，可设置是否带有动画效果；<br>4. 毛玻璃效果可设置系统现有的所有效果；<br>5. 适配深色/浅色模式的切换（前提是颜色使用的是系统的动态颜色）；<br>6. 优化逻辑。  
1.2.0 | 1. 固定比例的裁剪宽高比，裁剪边框也均可拖拽8个方向；<br>2. 优化了显示/隐藏毛玻璃效果。  
1.1.2~1.1.5 | 1. 优化计算逻辑；<br>2. 初始化时可自定义最大缩放比例（maximumZoomScale）。
1.1.1 | 1. 新增 imageresizeWHScale 属性，获取当前裁剪框的宽高比；<br>2. 新增 isToBeArbitrarily 关键字，用于设置裁剪宽高比、重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0），即可以继续任意拖拽裁剪框，对设置裁剪宽高比、重置等方法进行了修改，详情请查看Demo；<br>3.直接设置 resizeWHScale、verticalityMirror、horizontalMirror、isPreview 默认自带动画效果（isAnimated = YES，其中 resizeWHScale 的 isToBeArbitrarily = NO）。
1.1.0 | 1. 现在可以自定义边框图片，新增borderImage（边框图片）和borderImageRectInset（边框图片与边线的偏移量）接口用于设置自定义边框图片；<br>2. 优化计算逻辑。
1.0.1~1.0.4 | 1. recovery方法更名为recoveryByInitialResizeWHScale，意思按initialResizeWHScale进行重置，避免误导。<br>2. 裁剪后不再按参照宽度来进行压缩了，现在按比例来进行压缩（现在使用scale，referenceWidth已废除）；<br>3. 优化了裁剪和压缩逻辑；
1.0.0 | 1. 新增了isPreview属性，用于预览裁剪后的区域；<br>2. 新增了initialResizeWHScale属性，初始裁剪宽高比，重置时resizeWHScale会重置为该属性的值；<br>3. 新增recoveryByCurrentResizeWHScale方法，重置时不改变resizeWHScale；<br>4. 新增recoveryByResizeWHScale:方法，重置时可修改成任意resizeWHScale；<br>5. 修复了不断切换resizeWHScale时不断缩放的问题；<br>6. 优化了切换resizeWHScale、手指拖动时的交互效果。
0.5.1~0.5.3 | 1. 修复了设置镜像后的旋转、裁剪错乱问题；<br>2. 修复了切换裁剪比例时的缩放错误问题；<br>3. 移除isRotatedAutoScale属性（该属性会导致多处错误，且不利于优化，所以决定移除）；<br>4. 优化计算逻辑。
0.4.9 | 新增edgeLineIsEnabled属性：用于设置裁剪框边线能否进行对边拖拽，只有当裁剪宽高比(resizeWHScale)为0，即任意比例时才有效，适用于所有边框样式，默认为yes。（之前是只有触碰上下左右的中点才可以进行对边拖拽，现在是整条边线的作用范围）
0.4.3~0.4.6 | 1. 修复了image的scale不为1的情况下裁剪错误问题；<br>2. 移除裁剪方法（imageresizerWithComplete:isOriginImageSize:），新增（originImageresizerWithComplete:）来代替原图尺寸裁剪；<br>3. 新增两个压缩尺寸裁剪方法（imageresizerWithComplete:referenceWidth:）和（imageresizerWithComplete:），其中referenceWidth为裁剪的图片的参照宽度，例如设置为375，如果裁剪区域为图片宽度的一半，则裁剪的图片宽度为187.5，而高度则根据宽高比得出，最大和最小不超过原图和imageView两者的宽度。<br>4. 修复了原图裁剪导致的内存泄露；<br>5. 修复了长久以来旋转后没有自动调整至最大尺寸的问题；<br>6. 修复了拖拽边框松手时没有立刻更新拖拽区域的问题。
0.4.1 | 1. 优化了重置动画；<br>2. 裁剪方法（imageresizerWithComplete:isOriginImageSize:）新增 isOriginImageSize 参数，YES 为裁剪的图片尺寸按原图尺寸裁剪，NO 则为屏幕尺寸。
0.3.8~0.3.9 | 1. 修复1:1比例情况下旋转导致错位的问题；<br>2. 优化代码结构，更好的注释。
0.3.6 | 1. 修复了图片旋转和镜像后裁剪位置错乱的问题；<br>2. 新增边框样式：只有4角拖拽方向的简洁样式（JPConciseWithoutOtherDotFrameType）。
0.3.4 | 修复了指定裁剪宽高比（resizeWHScale大于0）的情况下，重置动画的错乱（recovery方法）。
0.3.3 | 新增resizeWHScale的动画形式的设置接口（-setResizeWHScale:animated:）。<br>说明：平时裁剪头像区域一般都是使用1:1的比例，但如果一进去就以该比例呈现，就会立马裁掉超出区域，可能会给人一种图片尺寸改变了的错觉，所以个人建议进去页面后（例如控制器的viewDidApper时）再调用改方法重新调整宽高比（请看gif图效果），这样用户体验会好点。
0.3.2 | 1. 新增【裁剪区域预备缩放至适应范围的回调】，当预备缩放时裁剪、旋转、镜像功能不可用，可在这回调中作相应处理；<br>2. 修改【旋转后是否自动缩放】的属性名 isAutoScale -> isRotatedAutoScale。
0.3.0 | 1. 修正旋转水平方向时自动整体自适应缩小的问题，现在为图片宽度比图片高度小时才自适应，也可以手动设定；<br>2. 新增锁定功能，裁剪区域可锁定，无法继续拖动；<br>3. 新增镜像功能，可进行垂直方向和水平方向镜像操作。
0.2.3 | 1. 修复相册照片方向错乱的bug；<br>2. 修复水平方向边框点和线有所缩小的问题；<br>3.更正属性的注释。
0.2.0 | 1. 新增高斯模糊的遮罩样式；<br>2. 可设置动画曲线；<br>3. 可设置裁剪区域的内边距；<br>4. 新增JPImageresizerConfigure类，更加方便设定参数。

## 安装

JPImageresizerView 可通过[CocoaPods](http://cocoapods.org)安装，只需添加下面一行到你的podfile：

```ruby
pod 'JPImageresizerView'

版本更新指令：pod update --no-repo-update
```

## 反馈地址

    扣扣：184669029
    博客：https://www.jianshu.com/u/2edfbadd451c

## License

JPImageresizerView is available under the MIT license. See the LICENSE file for more info.

