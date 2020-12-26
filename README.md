# JPImageresizerView

[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Language](http://img.shields.io/badge/language-ObjC-brightgreen.svg?style=flat)](https://developer.apple.com/Objective-C)

[英文文档（English document）](https://github.com/Rogue24/JPImageresizerView/blob/master/README_EN.md) | [掘金](https://juejin.im/post/5e67cf33f265da5749475935) |
[高仿小红书App可拖拽任意角度的裁剪功能](https://github.com/Rogue24/JPCrop)

## 简介（当前版本：1.7.8）

一个专门裁剪图片、GIF、视频的轮子，简单易用，功能丰富（高自由度的参数设定、支持旋转和镜像翻转、蒙版、压缩等），能满足绝大部分裁剪的需求。

![effect](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cover.gif)

    目前功能：
        ✅ 能自适应裁剪区域的缩放；
        ✅ 高自由度的参数设定，包括裁剪区域的间距、裁剪宽高比、是否自适应缩放等；
        ✅ 支持最多8个拖拽方向的裁剪区域；
        ✅ 支持上左下右的旋转；
        ✅ 水平和垂直的镜像翻转；
        ✅ 两种边框样式；
        ✅ 支持圆框裁剪；
        ✅ 自定义毛玻璃样式、边框颜色、背景颜色、遮罩透明度；
        ✅ 自定义边框图片；
        ✅ 可动态修改视图区域和裁剪区域间距，支持横竖屏切换;
        ✅ 可自定义蒙版图片裁剪；
        ✅ 可裁剪本地视频整段画面或某一帧画面；
        ✅ 可截取某一段本地视频，裁剪后并转成GIF；
        ✅ 可裁剪GIF；
        ✅ 可保存当前裁剪状态。

    TODO：
        🔘 Swift版本；
        🔘 固定不缩放裁剪区域；
        🔘 视频不再需要修正方向再裁剪；
        🔘 裁剪远程视频；
        🔘 持久化缓存裁剪历史；
        🔘 将视频裁剪部分（AVFoundation模块）分离出来；
        🔘 实现苹果相册裁剪功能中的自由拖拽旋转、翻转角度的效果。
        
    注意：由于autoLayout不利于手势控制，所以目前使用的是frame布局，暂不支持autoLayout。

## 如何使用

### 初始化
#### 1. 配置初始参数

    可设置的裁剪元素（图片、GIF、视频），只能选择其中一个，并且不能为nil：
        - image：裁剪的图片/GIF（以UIImage传入）
        - imageData：裁剪的图片/GIF（以NSData传入）
        - videoURL：裁剪的本地视频（以NSURL传入）
        - videoAsset：裁剪的本地视频（以AVURLAsset传入）
        
    其他部分可配置参数（更多可查看JPImageresizerView的头文件）：
        - blurEffect：毛玻璃样式
        - borderImage：边框图片
        - frameType & strokeColor：边框样式&颜色
        - bgColor：背景色
        - maskAlpha：遮罩透明度
        - resizeWHScale：裁剪的宽高比
        - contentInsets：裁剪区域与视图的间距
        - maskImage：蒙版图片
     
**图片/GIF**
```objc
//【裁剪的图片/GIF】以UIImage传入
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImage:image make:^(JPImageresizerConfigure *configure) {
    // 到这里已经有了默认参数值，可以在这里另外设置你想要的参数值（使用了链式编程方式）
    configure
    .jp_maskAlpha(0.5)
    .jp_strokeColor([UIColor yellowColor])
    .jp_frameType(JPClassicFrameType)
    .jp_contentInsets(contentInsets)
    .jp_bgColor([UIColor orangeColor])
    .jp_isClockwiseRotation(YES)
    .jp_animationCurve(JPAnimationCurveEaseOut);
}];

// 如果想要初始化为正方形，可设置 JPImageresizerConfigure 的 resizeWHScale 属性
configure.resizeWHScale = 1; // 默认为0，完全显示
// 另外如果还需要固定比例的话：
configure.isArbitrarily = YES; // 默认为YES

// 2.【裁剪的图片/GIF】以NSData传入
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImageData:imageData make:^(JPImageresizerConfigure *configure) { ...... };
```

**视频**

关于从系统相册获取的视频，视频方向有可能是修改过的（即相册中旋转、翻转过），修改后的`videoTrack.preferredTransform != CGAffineTransformIdentity`，图片也会，不过好歹图片有个`imageOrientation`属性告知具体改动了什么，由于我才疏学浅，单单从`preferredTransform`并不知道是经过了具体的哪些改动，如果只是旋转还好，旋转+翻转后的数值都是不一定的，这样导致最后裁剪时会错乱，目前只好先修正方向后再进行裁剪，日后改进，希望能有缘之士给予指点！

初始化后再修正（先进入页面后再修正），具体操作可参照Demo：
```objc
// 1.【视频】以NSURL传入
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoURL:videoURL make:^(JPImageresizerConfigure *configure) { ...... } fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // 初始化修正视频方向的错误回调
} fixStartBlock:^{
    // 初始化修正视频方向的开始回调
} fixProgressBlock:^(float progress) {
    // 初始化修正视频方向的进度回调 
} fixCompleteBlock:^(NSURL *cacheURL) {
    // 初始化修正视频方向的完成回调
}];

// 2.【视频】以AVURLAsset传入
[JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset 
                                                   make:^(JPImageresizerConfigure *configure) { ...... } 
                                          fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) { ...... } 
                                          fixStartBlock:^{ ...... } fixProgressBlock:^(float progress) { ...... } 
                                       fixCompleteBlock:^(NSURL *cacheURL) { ...... }];
```
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/videofixorientation.gif)

又或者先修正再初始化（先修正后再进入页面），可以使用`JPImageresizerTool`的API来修正，具体操作可参照Demo：
```objc
// 获取视频信息
AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
[videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
    dispatch_semaphore_signal(semaphore);
}];
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
if (CGAffineTransformEqualToTransform(videoTrack.preferredTransform, CGAffineTransformIdentity)) {
    // 无需修正，进入裁剪界面
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
    ......
    return;
}

// 修正方向
[JPImageresizerTool fixOrientationVideoWithAsset:videoAsset fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // 修正视频方向的错误回调
} fixStartBlock:^(AVAssetExportSession *exportSession) {
    // 修正视频方向的开始回调
    // 返回exportSession，可监听进度或取消导出
} fixCompleteBlock:^(NSURL *cacheURL) {
    // 修正视频方向的完成回调
    // cacheURL：修正方向后的视频导出后的最终存放路径，默认该路径为NSTemporaryDirectory文件夹下，保存该路径，裁剪后删除视频。
    
    // 开始裁剪，进入裁剪界面
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:[AVURLAsset assetWithURL:cacheURL] make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
    ......
}];
```
- PS1：如果视频不需要修正，`fixStartBlock`、`fixProgressBlock`、`fixErrorBlock`均不会调用，会直接调用`fixCompleteBlock`，返回原路径；
- PS2：如果确定是无需修正方向的视频，`fixErrorBlock`、`fixStartBlock`、`fixProgressBlock`、`fixCompleteBlock`传`nil`；
- PS3：更换视频：`-setVideoURL: animated: fixErrorBlock: fixStartBlock: fixProgressBlock: fixCompleteBlock:` 和 `-setVideoAsset: animated: fixErrorBlock: fixStartBlock: fixProgressBlock: fixCompleteBlock:` 方法也与之同理，内部会判定是否需要修正；
- PS4：如果需要初始化就**固定**裁剪宽高比（如圆切、蒙版等），需要设置`JPImageresizerConfigure`的`isArbitrarily`属性为**NO**（默认为YES）：
```objc
JPImageresizerConfigure *configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
    configure
    .jp_maskImage([UIImage imageNamed:@"love.png"])
    .jp_isArbitrarily(NO);
}];
```

#### 2. 创建JPImageresizerView对象并添加到视图上
```objc
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
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
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// 创建后均可动态修改configure的参数
self.imageresizerView.image = [UIImage imageNamed:@"Kobe.jpg"]; // 更换裁剪图片（默认带动画效果）
self.imageresizerView.resizeWHScale = 16.0 / 9.0; // 修改裁剪宽高比
self.imageresizerView.initialResizeWHScale = 0.0; // 默认为初始化时的resizeWHScale，调用 -recoveryByInitialResizeWHScale 方法进行重置则 resizeWHScale 会重置为该属性的值

// 注意：iOS11以下的系统，所在的controller最好设置automaticallyAdjustsScrollViewInsets为NO
// 不然imageresizerView会随导航栏或状态栏的变化产生偏移
if (@available(iOS 11.0, *)) {

} else {
    self.automaticallyAdjustsScrollViewInsets = NO;
}
```

### 裁剪
    裁剪说明：
        1.裁剪过程是在子线程中执行，进度、错误、完成的回调都会切回主线程执行，如果是高清图片，裁剪前可添加HUD提示
        2.compressScale：图片和GIF的压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
        3.cacheURL：缓存路径，可设置为nil，图片和GIF则不缓存，而视频会默认缓存到系统的NSTemporaryDirectory文件夹下，视频名为当前时间戳，格式为mp4
        4.错误原因 JPImageresizerErrorReason 说明：
            - JPIEReason_NilObject：裁剪元素为空
            - JPIEReason_CacheURLAlreadyExists：缓存路径已存在其他文件
            - JPIEReason_NoSupportedFileType：不支持的文件类型
            - JPIEReason_VideoAlreadyDamage：视频文件已损坏
            - JPIEReason_VideoExportFailed：视频导出失败
            - JPIEReason_VideoExportCancelled：视频导出取消
    
#### 裁剪图片
```objc
// 1.以原图尺寸进行裁剪
[self.imageresizerView cropPictureWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // 错误的回调
    // reason：错误原因
    // 注意循环引用
} completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
    // 裁剪完成
    // finalImage：裁剪后已经解码的图片
    // cacheURL：缓存路径
    // isCacheSuccess：是否缓存成功，NO为不成功，并且cacheURL为nil
    // 注意循环引用
}];


// 2.自定义压缩比例裁剪图片
// completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                            cacheURL:(NSURL *)cacheURL
                          errorBlock:(JPImageresizerErrorBlock)errorBlock
                       completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

#### 裁剪GIF
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgif.gif)
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgifdone.gif)
```objc
// 1.原图尺寸裁剪GIF
[self.imageresizerView cropGIFWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // 错误的回调
    // reason：错误原因
    // 注意循环引用
} completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
    // 裁剪完成
    // finalImage：裁剪后已经解码的GIF
    // cacheURL：缓存路径
    // isCacheSuccess：是否缓存成功，NO为不成功，并且cacheURL为nil
    // 注意循环引用
}];

// 2.自定义压缩比例裁剪GIF
// completeBlock --- 裁剪完成的回调（返回已解码好的GIF，缓存路径，是否缓存成功）
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.自定义裁剪GIF
// isReverseOrder --- 是否倒放
// rate --- 速率
// completeBlock --- 裁剪完成的回调（返回已解码好的GIF，缓存路径，是否缓存成功）
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                  isReverseOrder:(BOOL)isReverseOrder
                            rate:(float)rate
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

**裁剪GIF的其中一帧**
```objc
// 1.原图尺寸裁剪GIF当前帧画面
// completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
- (void)cropGIFCurrentIndexWithCacheURL:(NSURL *)cacheURL
                             errorBlock:(JPImageresizerErrorBlock)errorBlock
                          completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.自定义压缩比例裁剪GIF当前帧画面
// completeBlock --- 裁剪完成的回调（返回已解码好的图片，缓存路径，是否缓存成功）
- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                    cacheURL:(NSURL *)cacheURL
                                  errorBlock:(JPImageresizerErrorBlock)errorBlock
                               completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.自定义压缩比例裁剪GIF指定帧画面
// index --- 第几帧画面
- (void)cropGIFWithIndex:(NSUInteger)index
           compressScale:(CGFloat)compressScale
                cacheURL:(NSURL *)cacheURL
              errorBlock:(JPImageresizerErrorBlock)errorBlock
           completeBlock:(JPCropPictureDoneBlock)completeBlock;
```
- PS：可以设置isLoopPlaybackGIF自主选择裁剪哪一帧（默认为NO，设置为YES会自动播放GIF）
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/noloopplaybackgif.gif)
```objc
self.imageresizerView.isLoopPlaybackGIF = NO;
```
#### 裁剪本地视频
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideo.gif)
- PS：目前只针对本地视频，远程视频暂未适配。
```objc
// 裁剪整段视频
// cacheURL：如果为nil，会默认缓存到系统的NSTemporaryDirectory文件夹下，视频名为当前时间戳，格式为mp4
[self.imageresizerView cropVideoWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // 错误的回调
    // reason：错误原因
    // 注意循环引用
} progressBlock:^(float progress) {
    // 监听进度
    // progress：0~1
    // 注意循环引用
} completeBlock:^(NSURL *cacheURL) {
    // 裁剪完成
    // cacheURL：缓存路径
    // 注意循环引用
}];

// 可设置视频导出质量
// presetName --- 系统的视频导出质量，如：AVAssetExportPresetLowQuality，AVAssetExportPresetMediumQuality，AVAssetExportPresetHighestQuality等
- (void)cropVideoWithPresetName:(NSString *)presetName
                       cacheURL:(NSURL *)cacheURL
                    errorBlock:(JPImageresizerErrorBlock)errorBlock
                 progressBlock:(JPExportVideoProgressBlock)progressBlock
                 completeBlock:(JPExportVideoCompleteBlock)completeBlock;

// 取消视频导出
// 当视频正在导出时调用即可取消导出，触发errorBlock回调（JPIEReason_ExportCancelled）
- (void)videoCancelExport;
```
- PS：由于视频的宽高都必须是16的整数倍，否则导出后系统会自动对尺寸进行校正，不足的地方会以绿边的形式进行填充，因此我在方法内部对裁剪尺寸做了对16除余的修改，最后导出视频的宽高比有可能跟指定的宽高比有些许差异。

**裁剪视频的其中一帧**
```ojbc
// 1.原图尺寸裁剪视频当前帧画面
// cacheURL --- 缓存路径（可设置为nil，则不会缓存）
// completeBlock --- 裁剪完成的回调（返回已解码好的图片、缓存路径、是否缓存成功）
- (void)cropVideoCurrentFrameWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPImageresizerErrorBlock)errorBlock
                            completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.自定义压缩比例裁剪视频当前帧画面
// cacheURL --- 缓存路径（可设置为nil，则不会缓存）
// completeBlock --- 裁剪完成的回调（返回已解码好的图片、缓存路径、是否缓存成功）
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                      cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
                                 completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.自定义压缩比例裁剪视频指定帧画面
// second --- 第几秒画面
// cacheURL --- 缓存路径（可设置为nil，则不会缓存）
// completeBlock --- 裁剪完成的回调（返回已解码好的图片、缓存路径、是否缓存成功）
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                           cacheURL:(NSURL *)cacheURL
                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                      completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

**截取视频某一段裁剪后转GIF**
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideotogif.gif)
```objc
// 1.视频从当前时间开始截取指定秒数画面转GIF（fps = 10，rate = 1，maximumSize = 500 * 500）
// duration --- 截取多少秒
// completeBlock --- 裁剪完成的回调（返回已解码好的GIF、缓存路径、是否缓存成功）
- (void)cropVideoToGIFFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                           cacheURL:(NSURL *)cacheURL
                                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                                      completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.视频自定义截取指定秒数画面转GIF
// duration --- 截取多少秒
// fps --- 帧率（设置为0则以视频真身帧率）
// rate --- 速率
// maximumSize --- 截取的尺寸（设置为0则以视频真身尺寸）
// completeBlock --- 裁剪完成的回调（返回已解码好的GIF、缓存路径、是否缓存成功）
- (void)cropVideoToGIFFromStartSecond:(NSTimeInterval)startSecond
                             duration:(NSTimeInterval)duration
                                  fps:(float)fps
                                 rate:(float)rate
                          maximumSize:(CGSize)maximumSize
                             cacheURL:(NSURL *)cacheURL
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
                        completeBlock:(JPCropPictureDoneBlock)completeBlock;
```
- PS：裁剪整段视频画面圆切、蒙版的功能不能使用，目前只对图片和GIF有效。

### 蒙版
![mask](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/mask.gif)
```objc
// 设置蒙版图片（目前仅支持png图片）
self.imageresizerView.maskImage = [UIImage imageNamed:@"love.png"];

// 直接设置该值即是调用 -setMaskImage: isToBeArbitrarily: animated: 方法，其中默认 isToBeArbitrarily = (maskImage ? NO : self.isArbitrarily)，isAnimated = YES

// 移除蒙版图片
self.imageresizerView.maskImage = nil;
```
![maskdone](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/maskdone.png)
- PS：如果使用了蒙版图片，那么最后裁剪出来的是png图片，因此裁剪后体积有可能会比原本的图片更大。

### 圆切
![round_resize](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/roundresize.jpg)
```objc
// 设置圆切
// 设置后，resizeWHScale为1:1，半径为宽高的一半，边框的上、左、下、右的中部均可拖动。
self.imageresizerView.isRoundResize = YES;

// 直接设置该值即是调用 -setIsRoundResize: isToBeArbitrarily: animated: 方法，其中默认 isToBeArbitrarily = (isRoundResize ? NO : self.isArbitrarily)，isAnimated = YES

// 还原矩形
self.imageresizerView.isRoundResize = NO;
// 或者只需设置一下resizeWHScale为任意值即可
self.imageresizerView.resizeWHScale = 0.0;
```

### 横竖屏切换
![screenswitching](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/screenswitching.gif)
```objc
// 需要用户去监听横竖屏的切换，或自己手动切换时，调用该方法刷新
// 1.updateFrame：刷新的Frame（例如横竖屏切换，传入self.view.bounds即可）
// 2.contentInsets：裁剪区域与主视图的内边距
// 3.duration：刷新时长（大于0即带有动画效果）
//【具体操作可参照Demo】
[self.imageresizerView updateFrame:self.view.bounds contentInsets:contentInsets duration:duration];
```

### 更改边框样式
![concise](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/conciseframetype.jpg)
![classic](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/classicframetype.jpg)
```objc
// 目前只提供两种边框样式，分别是简洁样式JPConciseFrameType，和经典样式JPClassicFrameType
// 可在初始化或直接设置frameType属性来修改边框样式
self.imageresizerView.frameType = JPClassicFrameType;
```

### 自定义边框图片
![stretch_mode](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/customborder1.jpg)
![tile_mode](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/customborder2.jpg)
```objc
// 使用自定义边框图片（例：平铺模式）
UIImage *tileBorderImage = [[UIImage imageNamed:@"dotted_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];

// 设置边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距）
self.imageresizerView.borderImageRectInset = CGPointMake(-1.75, -1.75);

// 设置边框图片（若为nil则使用frameType的边框）
self.imageresizerView.borderImage = tileBorderImage;
```

### 切换裁剪宽高比
![switch_resizeWHScale](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/switchingresizewhscale.gif)
- PS：设置裁剪宽高比会自动移除圆切和蒙版
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
// 默认切换之后保存最新的 resizeWHScale，且自带动画效果，如果设置为0，以当前裁剪框的宽高比设置，并且最后 isArbitrarily = YES，相当于：
[self.imageresizerView setResizeWHScale:1.0 isToBeArbitrarily:(resizeWHScale <= 0) animated:YES];

// 是否可以任意比例拖拽（包括圆切、蒙版）
self.imageresizerView.isArbitrarily = !self.imageresizerView.isArbitrarily;

// 更多API可查看 JPImageresizerView.h 上的注释
```

### 自定义毛玻璃样式、边框颜色、背景颜色、遮罩透明度
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

### 镜像翻转
![mirror](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/mirror.gif)
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

### 旋转
```objc
// 默认逆时针旋转，旋转角度为90°
[self.imageresizerView rotation];

// 若需要顺时针旋转可设置isClockwiseRotation属性为YES
self.imageresizerView.isClockwiseRotation = YES;
```

### 重置
重置目标状态，方向垂直向上，可重置为不同的resizeWHScale、圆切、蒙版
#### 1. 一切按当前状态重置
```objc
- (void)recovery;
```

#### 2. 以resizeWHScale重置（会移除圆切、蒙版）
```objc
// 2.1 按初始裁剪宽高比（initialResizeWHScale）进行重置
- (void)recoveryByInitialResizeWHScale;
- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily;

// 2.2 按当前裁剪宽高比进行重置（如果resizeWHScale为0，则重置到整个裁剪元素区域）
- (void)recoveryByCurrentResizeWHScale;
- (void)recoveryByCurrentResizeWHScale:(BOOL)isToBeArbitrarily;

// 2.3 按目标裁剪宽高比进行重置（如果resizeWHScale为0，则重置到整个裁剪元素区域）
// targetResizeWHScale：目标裁剪宽高比
// isToBeArbitrarily：重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
- (void)recoveryToTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily;
```

#### 3. 以圆切重置
```objc
- (void)recoveryToRoundResize;
- (void)recoveryToRoundResize:(BOOL)isToBeArbitrarily;
```

#### 4. 以蒙版图片重置
```objc
// 4.1 按当前蒙版图片重置
- (void)recoveryByCurrentMaskImage;
- (void)recoveryByCurrentMaskImage:(BOOL)isToBeArbitrarily;

// 4.2 指定蒙版图片重置
- (void)recoveryToMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily;
```

### 预览
```objc
// 预览模式：隐藏边框，停止拖拽操作，用于预览裁剪后的区域

self.imageresizerView.isPreview = YES;

// 默认自带动画效果，相当于：
[self.imageresizerView setIsPreview:YES animated:YES];
```

### 保存当前裁剪状态
```objc
// 1.很Easy，直接调用saveCurrentConfigure方法获取当前裁剪的状态，可用一个全局变量来保存该对象
JPImageresizerConfigure *savedConfigure = [self.imageresizerView saveCurrentConfigure];

// 2.重新打开裁剪历史
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:savedConfigure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    ......
} imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
    ......
}];
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// 3.可以设置JPImageresizerConfigure的isCleanHistoryAfterInitial属性为YES，当初始化结束后自动清空历史（默认为YES）
// 或者直接调用cleanHistory方法清空历史
```
![save](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/save.gif)

- PS1：若保存的`savedConfigure.history.viewFrame`跟当前的`viewFrame`不一致，界面会导致错乱，需要自行判断是否一致才可重新打开；
- PS2：另外目前只能在App使用期间进行保存，暂未实现持久化缓存。

### 其他
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
1.7.8 | 1. 新增可保存当前历史状态的功能。
1.7.6~1.7.7 | 1. 修复了固定比例旋转时无故放大的问题；<br>2. 修复iOS14版本下自定义进度条的拖动块消失的问题。
1.7.3~1.7.5 | 1. 修复了初始化无法固定裁剪比例的问题；<br>2. 现在圆切和蒙版均可设置是否自由拖拽；<br>3. 优化了设置裁剪宽高比和重置的接口；<br>4. 优化了图片缓存逻辑；<br>5. 修复了GIF时长过短导致截取错误的问题。
1.7.1~1.7.2 | 1. 新增修正视频方向的功能（有待改进）；<br>2. 裁剪视频可以以AVURLAsset形式传入；<br>3. 优化切换裁剪元素的过渡。
1.7.0 | 1. 新增可裁剪GIF功能，可以裁剪一整个GIF文件，也可以裁剪其中一帧画面，可设置是否倒放、速率；<br>2. 视频可以截取任意一段转成GIF，可设置帧率、尺寸；<br>3. 裁剪图片和GIF可以以UIImage形式传入，也可以以NSData形式传入；<br>4. 图片和GIF可设置缓存路径保存到本地磁盘；<br>5. 极大地优化了裁剪逻辑。
1.6.0~1.6.3 | 1. 可裁剪本地视频整段画面或某一帧画面，并且可以动态切换裁剪素材；<br>2. 现在默认经典模式下，闲置时网格线会隐藏，拖拽时才会显示，新增了isShowGridlinesWhenIdle属性，可以跟isShowGridlinesWhenDragging属性自定义显示时机；<br>3. 修复了设置蒙版图片后切换裁剪素材时的方向错乱问题；<br>4. 优化图片裁剪的逻辑，优化API。
1.5.0~1.5.3 | 1. 新增自定义蒙版图片功能，从而实现可自定义任意裁剪区域；<br>2. 修复了经旋转重置后裁剪宽高比错乱的问题；<br>3. 优化了旋转、翻转的过渡动画。
1.4.0 | 1. 新增isBlurWhenDragging属性：拖拽时是否遮罩裁剪区域以外的区域；<br>2. 新增isShowGridlinesWhenDragging属性：拖拽时是否能继续显示网格线（frameType 为 JPClassicFrameType 且 gridCount > 1 才显示网格）；<br>3. 新增gridCount属性：每行/列的网格数（frameType 为 JPClassicFrameType 且 gridCount > 1 才显示网格）。
1.3.8~1.3.9  | 1. 适配横竖屏切换；<br>2. 废除verBaseMargin和horBaseMargin属性，统一使用contentInsets设置裁剪区域与视图的间距；<br>3. 优化代码，并减少裁剪误差。  
1.2.1~1.3.6 | 1. 新增圆切样式；<br>2. 中间的点/块可隐藏；<br>3. 可动态切换图片、设置边框颜色和背景颜色，可设置是否带有动画效果；<br>4. 毛玻璃效果可设置系统现有的所有效果；<br>5. 适配深色/浅色模式的切换（前提是颜色使用的是系统的动态颜色）；<br>6. 优化逻辑。  
1.2.0 | 1. 固定比例的裁剪宽高比，裁剪边框也均可拖拽8个方向；<br>2. 优化了显示/隐藏毛玻璃效果。  
1.1.2~1.1.5 | 1. 优化计算逻辑；<br>2. 初始化时可自定义最大缩放比例（maximumZoomScale）。
1.1.1 | 1. 新增 imageresizeWHScale 属性，获取当前裁剪框的宽高比；<br>2. 新增 isToBeArbitrarily 关键字，用于设置裁剪宽高比、重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0），即可以继续任意拖拽裁剪框，对设置裁剪宽高比、重置等方法进行了修改，详情请查看Demo；<br>3. 直接设置 resizeWHScale、verticalityMirror、horizontalMirror、isPreview 默认自带动画效果（isAnimated = YES，其中 resizeWHScale 的 isToBeArbitrarily = NO）。
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
0.2.3 | 1. 修复相册照片方向错乱的bug；<br>2. 修复水平方向边框点和线有所缩小的问题；<br>3. 更正属性的注释。
0.2.0 | 1. 新增高斯模糊的遮罩样式；<br>2. 可设置动画曲线；<br>3. 可设置裁剪区域的内边距；<br>4. 新增JPImageresizerConfigure类，更加方便设定参数。

## 安装

JPImageresizerView 可通过[CocoaPods](http://cocoapods.org)安装，只需添加下面一行到你的podfile：

```ruby
pod 'JPImageresizerView'

版本更新指令：pod update --no-repo-update
```

## 反馈地址

    扣扣：184669029
    E-mail: zhoujianping24@hotmail.com
    博客：https://juejin.im/user/5e55f27bf265da575c16c187

## License

JPImageresizerView is available under the MIT license. See the LICENSE file for more info.

