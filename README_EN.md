# JPImageresizerView

[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Language](http://img.shields.io/badge/language-ObjC-brightgreen.svg?style=flat)](https://developer.apple.com/Objective-C)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

[Juejin](https://juejin.cn/post/6958761756978053150) | [Xiaohongshu-like App Cropping with Free-Angle Dragging](https://github.com/Rogue24/JPCrop)

## Introduction (Current Version: 1.14.0)

This is a dedicated library for cropping images, GIFs, and videos. It is easy to use and feature-rich (highly flexible parameters, rotation and mirror flipping, masks, compression, etc.), and can cover most cropping scenarios.

![effect](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cover.gif)

    Features:
        ✅ Adaptive zooming for the cropping area;
        ✅ Highly flexible parameter configuration, including insets, aspect ratio, adaptive scaling, etc.;
        ✅ Up to 8 drag directions for the crop frame;
        ✅ Rotation in up/left/down/right directions;
        ✅ Horizontal and vertical mirror flipping;
        ✅ Two border styles;
        ✅ Round cropping;
        ✅ Custom crop corner radius;
        ✅ Custom blur style, border color, background color, and mask opacity;
        ✅ Custom border image;
        ✅ Custom mask-image-based cropping;
        ✅ Custom initial cropping area;
        ✅ Dynamic updates to view frame and content insets, supports portrait/landscape switching;
        ✅ GIF cropping;
        ✅ GIF image processing settings: background color, corner radius, border, outline stroke, and content insets;
        ✅ Crop a full local video or a specific frame;
        ✅ Crop local videos with custom time range, or convert clipped segments to GIF;
        ✅ Save current crop state;
        ✅ N-grid image cropping;
        ✅ Compatible with Swift & SwiftUI (see Demo).

    TODO:
        🔘 Swift version;
        🔘 Non-scaling fixed crop frame;
        🔘 Crop video without requiring orientation correction first;
        🔘 Remote video cropping;
        🔘 Persistent cached crop history;
        🔘 Split out video-cropping logic (AVFoundation module);
        🔘 Implement free-angle drag rotation/flip like Apple Photos.
        
    Note: Auto Layout is not ideal for gesture handling in this component, so it currently uses frame-based layout and does not support Auto Layout.
    
## Latest Changes
    1. Unified appearance configuration (crop border color, blur effect, background color, mask alpha);
    2. Added custom crop corner radius, and an option to hide corner radius only during editing while keeping rounded corners in final output;
    3. Added custom mask appearance configuration, and support for ignoring mask during crop;
    4. When using mask or round crop, you can still set crop aspect ratio and whether free dragging is allowed.

#### Added an iOS 26-style glass crop frame. You can select **Glass Style** in the Demo (see Demo for setup):

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/glass_effect_border.gif)

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/glass_effect_picture.jpg)

- PS: It looks great in practice. You can take a screenshot directly for a 3D wallpaper (other controls are auto-hidden while screenshotting) 🤠

#### GIF now supports background color, corner radius, border, outline stroke, and content insets:

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/processforgif.gif)

## Usage

### Initialization

#### 1. Configure Initial Parameters

    You can configure only one crop source (image, GIF, or video), and it cannot be nil:
        - image: Image / GIF to crop (sent in as UIImage)
        - imageData: Image / GIF to crop (sent in as NSData)
        - videoURL: Local video to crop (sent in as NSURL)
        - videoAsset: Local video to crop (sent in as AVURLAsset)
        
    Other configurable parameters (see the header files for more details):
        - mainAppearance: primary appearance configuration
            - strokeColor: border color
            - bgEffect: blur style
            - bgColor: background color
            - maskAlpha: mask opacity
        - borderImage: border image
        - frameType: border style
        - resizeWHScale: crop aspect ratio
        - resizeCornerRadius: crop corner radius
        - contentInsets: insets between crop area and view
        - maskImage: mask image
        - gifSettings: GIF image processing settings
     
**Image / GIF**

```objc
// 1. Image/GIF input as UIImage
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImage:image make:^(JPImageresizerConfigure *configure) {
    // Default values are already set here. Adjust anything you need (chain style API).
    configure
    .jp_maskAlpha(0.5)
    .jp_strokeColor([UIColor yellowColor])
    .jp_frameType(JPClassicFrameType)
    .jp_contentInsets(contentInsets)
    .jp_bgColor([UIColor orangeColor])
    .jp_isClockwiseRotation(YES)
    .jp_animationCurve(JPAnimationCurveEaseOut);
}];

// If you want an initial square crop, set resizeWHScale
configure.resizeWHScale = 1; // The default value is 0, full display
// If you also need a fixed aspect ratio:
configure.isArbitrarily = YES; // The default is YES

// 2. Image/GIF input as NSData
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImageData:imageData make:^(JPImageresizerConfigure *configure) { ...... };
```

**Local Video**

For videos selected from the system Photos app, orientation may have been modified (rotated/flipped), meaning `videoTrack.preferredTransform != CGAffineTransformIdentity`. Images have `imageOrientation` to describe orientation changes, but for videos it is hard to infer the exact transform from `preferredTransform` alone, especially for combined rotate + flip cases. That can cause incorrect crop output.  
Current workaround: fix orientation first, then crop (to be improved in the future).

Fix orientation after initialization (enter the crop page first, then fix). See Demo for details:

```objc
// 1. videoURL: local video input as NSURL
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoURL:videoURL make:^(JPImageresizerConfigure *configure) { ...... } fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // Error callback for orientation fix during initialization
} fixStartBlock:^{
    // Start callback for orientation fix during initialization
} fixProgressBlock:^(float progress) {
    // Progress callback for orientation fix during initialization
} fixCompleteBlock:^(NSURL *cacheURL) {
    // Completion callback for orientation fix during initialization
}];

// 2. videoAsset: local video input as AVURLAsset
[JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset 
                                                   make:^(JPImageresizerConfigure *configure) { ...... } 
                                          fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) { ...... } 
                                          fixStartBlock:^{ ...... } fixProgressBlock:^(float progress) { ...... } 
                                       fixCompleteBlock:^(NSURL *cacheURL) { ...... }];
```

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/videofixorientation.gif)

Or fix orientation first and initialize later (fix first, then enter the crop page). You can use `JPImageresizerTool` APIs. See Demo for details:

```objc
// Get video information
AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
[videoAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
    dispatch_semaphore_signal(semaphore);
}];
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
if (CGAffineTransformEqualToTransform(videoTrack.preferredTransform, CGAffineTransformIdentity)) {
    // No fix needed, enter crop UI
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
    ......
    return;
}

// Fix the orientation
[JPImageresizerTool fixOrientationVideoWithAsset:videoAsset fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // Error callback for orientation fix
} fixStartBlock:^(AVAssetExportSession *exportSession) {
    // Start callback for orientation fix
    // Returns exportSession; you can observe progress or cancel export
} fixCompleteBlock:^(NSURL *cacheURL) {
    // Completion callback for orientation fix
    // cacheURL: final exported path after orientation fix.
    // Default path is under NSTemporaryDirectory. Save the path and delete the video after cropping.
    
    // Start cropping and enter crop UI
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:[AVURLAsset assetWithURL:cacheURL] make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
    ......
}];
```

- PS1: If orientation fix is not required, `fixStartBlock`, `fixProgressBlock`, and `fixErrorBlock` are not called. `fixCompleteBlock` is called directly with the original path.
- PS2: If you are sure no orientation fix is needed, pass `nil` to `fixErrorBlock`, `fixStartBlock`, `fixProgressBlock`, and `fixCompleteBlock`.
- PS3: Replacing videos via `-setVideoURL:animated:fixErrorBlock:fixStartBlock:fixProgressBlock:fixCompleteBlock:` and `-setVideoAsset:animated:fixErrorBlock:fixStartBlock:fixProgressBlock:fixCompleteBlock:` follows the same logic internally.
- PS4: If you need a **fixed** crop aspect ratio at initialization (e.g. round crop or mask), set `JPImageresizerConfigure.isArbitrarily` to **NO** (default is YES):

```objc
JPImageresizerConfigure *configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
    configure
    .jp_maskImage([UIImage imageNamed:@"love.png"])
    .jp_isArbitrarily(NO);
}];
```

#### 2. Create JPImageresizerView and Add It to the View

```objc
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    // Listen whether reset is currently available.
    // If reset is unavailable (isCanRecovery = NO), disable or hide your reset button.
    // PS: isCanRecovery only reflects changes from [rotation], [zoom], and [mirror].
    // For other changes (e.g. resizeWHScale, round crop), determine reset availability yourself.
    // See Demo for details.
    // Avoid retain cycles.
} imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
    // Listen whether crop frame is preparing to scale into a valid range.
    // When isPrepareToScale = YES, crop/rotate/mirror actions are unavailable.
    // You can disable or hide related buttons here. See Demo for details.
    // Avoid retain cycles.
}];
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// After creation, you can dynamically update related properties
self.imageresizerView.image = [UIImage imageNamed:@"Kobe.jpg"]; // Replace image (animated by default)
self.imageresizerView.resizeWHScale = 16.0 / 9.0; // Change crop aspect ratio
self.imageresizerView.initialResizeWHScale = 0.0; // Defaults to initial resizeWHScale. Calling -recoveryByInitialResizeWHScale resets resizeWHScale to this value.

// Note: For systems under iOS 11, it is best for the controller to set automaticallyAdjustsScrollViewInsets to NO
// Otherwise, imageresizerView may shift with navigation/status bar changes
if (@available(iOS 11.0, *)) {

} else {
    self.automaticallyAdjustsScrollViewInsets = NO;
}
```

#### Swift Usage

```swift
// 1. Initial configuration
let configure = JPImageresizerConfigure.defaultConfigure(with: image) { c in
    _ = c
        .jp_viewFrame(frame)
        .jp_bgColor(.black)
        .jp_frameType(.classicFrameType)
        .jp_contentInsets(.init(top: 16, left: 16, bottom: 16, right: 16))
        .jp_animationCurve(.easeInOut)
}

// 2. Create imageresizerView
let imageresizerView = JPImageresizerView(configure: configure) { [weak self] isCanRecovery in
    // Disable reset button when reset is not needed
    self?.recoveryBtn.isEnabled = isCanRecovery
} imageresizerIsPrepareToScale: { [weak self] isPrepareToScale in
    // Disable operation buttons while preparing to scale; re-enable after done
    self?.operationView.isUserInteractionEnabled = !isPrepareToScale
}

// 3. Add to view
view.insertSubview(imageresizerView, at: 0)
self.imageresizerView = imageresizerView
```

For details, refer to the Demo (`JPCropViewController`).

#### Custom Initial Cropping Area

You can modify the initial cropping area by setting the `resizeScaledBounds` property of `JPImageresizerConfigure` (by default, the entire crop element's size is displayed).

```objc
configure.resizeScaledBounds = CGRectMake(0.1, 0.1, 0.8, 0.8);
```

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/initial_resizeScaledBounds.jpg)

- The value of this property is represented as a **percentage of the original size**. For example, the above setting means the initial cropping area will cover `80%` of the crop element's center.
- This property is mutually exclusive with another property of `JPImageresizerConfigure`, `resizeWHScale`. When `resizeScaledBounds` is set, the `resizeWHScale` of `imageresizerView` will be automatically calculated as `resizeScaledBounds.size.width / resizeScaledBounds.size.height`.
- This property will only be used once during initialization. Therefore, if it has been set or if you later configure `imageresizerView` with `resizeWHScale`, `isRoundResize`, or `maskImage`, the `resizeScaledBounds` will be cleared.

For detailed usage, see **Face Cropping** in the Demo.

### Crop
    Notes:
        1. Cropping runs on a background thread; progress/error/completion callbacks are dispatched to the main thread. For high-resolution images, you can show a HUD before cropping.
        2. compressScale: compression ratio for images and GIFs. If >= 1, crop in original size; if <= 0, returns nil. (Example: compressScale = 0.5, 1000 x 500 --> 500 x 250)
        3. cacheURL: can be nil. If nil, images/GIFs are not cached. Videos are cached by default under NSTemporaryDirectory with a timestamp filename and mp4 extension.
        4. JPImageresizerErrorReason:
            - JPIEReason_NilObject: Crop source is empty
            - JPIEReason_CacheURLAlreadyExists: Another file already exists for the cache path
            - JPIEReason_NoSupportedFileType: Unsupported file type
            - JPIEReason_VideoAlreadyDamage: The video file is corrupted
            - JPIEReason_VideoExportFailed: Video export failed
            - JPIEReason_VideoExportCancelled: Video export cancelled
        5. Note: output image format in cache path may be auto-corrected. For example, `xxx/xxx.jpeg` may become `xxx/xxx.png` when a mask is used. Always use `result.cacheURL` from `completeBlock` as the final output path.
    
#### Crop image

```objc
// 1. Crop at original image size
[self.imageresizerView cropPictureWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} completeBlock:^(JPImageresizerResult *result) {
    // Crop complete
    // result: JPImageresizerResult
    // result.image: Image that has been decoded after clipping
    // result.cacheURL: Cache path
    // result.isCacheSuccess: whether caching succeeded (if failed, cacheURL is nil)
    // Pay attention to circular references
}];


// 2. Crop image with custom compression scale
// compressScale: if >= 1, crop at original size; if <= 0, returns nil (e.g. compressScale = 0.5, 1000 x 500 --> 500 x 250)
// completeBlock: callback after crop finishes (returns JPImageresizerResult with decoded image and cache path)
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                            cacheURL:(NSURL *)cacheURL
                          errorBlock:(JPImageresizerErrorBlock)errorBlock
                       completeBlock:(JPCropDoneBlock)completeBlock;
```

- **Crop N-grid pictures**

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropngird.gif)

```objc
// 1. Custom N-grid cropping
// columnCount: The number of columns of n-grid (minimum 1 column)
// rowCount: The number of rows of n-grid (minimum 1 row)
// compressScale: if >= 1, crop at original size; if <= 0, returns nil (e.g. compressScale = 0.5, 1000 x 500 --> 500 x 250)
// bgColor: background color for hidden (transparent) areas, effective when source has transparency or mask is used
[self.imageresizerView cropGirdPicturesWithColumnCount:4 rowCount:2 compressScale:1 bgColor:UIColor.redColor cacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} completeBlock:^(JPImageresizerResult *originResult, NSArray<JPImageresizerResult *> *fragmentResults, NSInteger columnCount, NSInteger rowCount) {
    // Crop complete
    // originResult: JPImageresizerResult (The result before the n-grid)
    // fragmentResults: The originResult.image is cropped into the result set of n-grid pictures (total = columnCount * rowCount)
    // columnCount: The number of columns passed in when the method is called
    // rowCount: The number of rows passed in when the method is called
    // Pay attention to circular references
}];

// 2. Nine-grid cropping (3x3)
- (void)cropNineGirdPicturesWithCompressScale:(CGFloat)compressScale
                                      bgColor:(UIColor *)bgColor
                                     cacheURL:(NSURL *)cacheURL
                                   errorBlock:(JPImageresizerErrorBlock)errorBlock
                                completeBlock:(JPCropNGirdDoneBlock)completeBlock;
```

#### Crop GIF

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgif.gif)

↓↓↓

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgifdone.gif)

```objc
// 1. Crop GIF at original size
[self.imageresizerView cropGIFWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} completeBlock:^(JPImageresizerResult *result) {
    // Crop complete
    // result: JPImageresizerResult
    // result.image: GIF that has been decoded after clipping
    // result.cacheURL: Cache path
    // result.isCacheSuccess: whether caching succeeded (if failed, cacheURL is nil)
    // Pay attention to circular references
}];

// 2. Crop GIF with custom compression scale
// completeBlock: callback after crop finishes (returns JPImageresizerResult with decoded GIF and cache path)
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropDoneBlock)completeBlock;

// 3. Custom GIF crop options
// isReverseOrder: whether to reverse playback
// completeBlock: callback after crop finishes (returns JPImageresizerResult with decoded GIF and cache path)
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                  isReverseOrder:(BOOL)isReverseOrder
                            rate:(float)rate
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropDoneBlock)completeBlock;
```

- **Process Images for GIF**

Original GIF:

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/bazhuawan_origin.gif)

```objc
// 1.Configure settings for processing
JPImageProcessingSettings *settings = [[JPImageProcessingSettings alloc] init];
settings.backgroundColor = UIColor.blackColor;
settings.outlineStrokeColor = UIColor.whiteColor;
settings.outlineStrokeWidth = 3;
settings.cornerRadius = 30;

// 2.Set within `gifSettings` before cropping (can be dynamically configured)
self.imageresizerView.gifSettings = settings;
```

Processed GIF:

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/bazhuawa_processed.gif)

- **Crop one of the GIF frames**

```objc
// 1. Crop current GIF frame at original size
// completeBlock: callback after crop finishes (returns JPImageresizerResult with decoded image and cache path)
- (void)cropGIFCurrentIndexWithCacheURL:(NSURL *)cacheURL
                             errorBlock:(JPImageresizerErrorBlock)errorBlock
                          completeBlock:(JPCropDoneBlock)completeBlock;

// 2. Crop current GIF frame with custom compression scale
// completeBlock: callback after crop finishes (returns JPImageresizerResult with decoded image and cache path)
- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                    cacheURL:(NSURL *)cacheURL
                                  errorBlock:(JPImageresizerErrorBlock)errorBlock
                               completeBlock:(JPCropDoneBlock)completeBlock;

// 3. Crop a specified GIF frame with custom compression scale
// index: frame index
// compressScale: if >= 1, crop at original size; if <= 0, returns nil (e.g. compressScale = 0.5, 1000 x 500 --> 500 x 250)
- (void)cropGIFWithIndex:(NSUInteger)index
           compressScale:(CGFloat)compressScale
                cacheURL:(NSURL *)cacheURL
              errorBlock:(JPImageresizerErrorBlock)errorBlock
           completeBlock:(JPCropDoneBlock)completeBlock;
```
PS: You can set `isLoopPlaybackGIF` and choose which frame to crop manually (default is NO; if set to YES, GIF plays automatically).
```objc
self.imageresizerView.isLoopPlaybackGIF = NO;
```

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/noloopplaybackgif.gif)

#### Crop local video

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideo.gif)

PS: Currently only local videos are supported. Remote video is not supported yet.

```objc
// Clip the entire video
// cacheURL: If it is nil, it will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4
[self.imageresizerView cropVideoWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} progressBlock:^(float progress) {
    // Monitor progress
    // progress: 0~1
    // Pay attention to circular references
} completeBlock:^(JPImageresizerResult *result) {
    // Crop completed
    // result: JPImageresizerResult
    // result.cacheURL: output path. If nil is passed in, it is cached by default under NSTemporaryDirectory with a timestamp mp4 filename.
    // Pay attention to circular references
}];

// Video export quality can be set
// presetName: The video export quality of the system, such as: AVAssetExportPresetLowQuality, AVAssetExportPresetMediumQuality, AVAssetExportPresetHighestQuality, etc
- (void)cropVideoWithPresetName:(NSString *)presetName
                       cacheURL:(NSURL *_Nullable)cacheURL 
                     errorBlock:(JPImageresizerErrorBlock)errorBlock
                  progressBlock:(JPExportVideoProgressBlock)progressBlock
                  completeBlock:(JPCropDoneBlock)completeBlock;
                  
// Crop the video and extract a specified duration starting from the current time
// duration: Duration to extract in seconds (minimum 1s; if 0, extracts until the end of the video)
- (void)cropVideoFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                    presetName:(NSString *)presetName
                                      cacheURL:(NSURL *_Nullable)cacheURL
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
                                 progressBlock:(JPExportVideoProgressBlock)progressBlock
                                 completeBlock:(JPCropDoneBlock)completeBlock;

// Crop the video and customize the extraction duration
// startSecond: Start extracting from which second
// duration: Duration to extract in seconds (minimum 1s; if 0, extracts until the end of the video)
- (void)cropVideoFromStartSecond:(NSTimeInterval)startSecond
                        duration:(NSTimeInterval)duration
                      presetName:(NSString *)presetName
                        cacheURL:(NSURL *_Nullable)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   progressBlock:(JPExportVideoProgressBlock)progressBlock
                   completeBlock:(JPCropDoneBlock)completeBlock;

// Cancel video export
// Call this while exporting to cancel export, which triggers errorBlock (JPIEReason_ExportCancelled)
- (void)videoCancelExport;
```

PS: Video width and height must be multiples of 16; otherwise the system may auto-correct dimensions after export and fill missing areas with green edges.  
So this library adjusts crop size internally to satisfy the multiple-of-16 rule, and the exported aspect ratio may differ slightly from the specified ratio.

- **Clip one frame of the video**

```objc
// 1. Crop current video frame at original size
// cacheURL: Cache path (can be set to nil, it will not be cached)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropVideoCurrentFrameWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPImageresizerErrorBlock)errorBlock
                            completeBlock:(JPCropDoneBlock)completeBlock;

// 2. Crop current video frame with custom compression scale
// cacheURL: Cache path (can be set to nil, it will not be cached)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                      cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
                                 completeBlock:(JPCropDoneBlock)completeBlock;

// 3. Crop specified video frame with custom compression scale
// second: target second
// cacheURL: Cache path (can be set to nil, it will not be cached)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                           cacheURL:(NSURL *)cacheURL
                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                      completeBlock:(JPCropDoneBlock)completeBlock;
```

- **Crop video and convert a selected segment to GIF**

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideotogif.gif)

```objc
// 1. Crop video and convert segment from current time to GIF (fps = 10, rate = 1, maximumSize = 500 * 500)
// duration: segment length in seconds
// completeBlock: callback after crop finishes (returns JPImageresizerResult with decoded GIF and cache path)
- (void)cropVideoToGIFFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                           cacheURL:(NSURL *)cacheURL
                                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                                      completeBlock:(JPCropDoneBlock)completeBlock;

// 2. Crop video and convert custom segment to GIF
// duration: segment length in seconds
// fps: Frame rate (set to 0 to use the real frame rate of the video)
// maximumSize: output size (set to 0 to use original video size)
// completeBlock: callback after crop finishes (returns JPImageresizerResult with decoded GIF and cache path)
- (void)cropVideoToGIFFromStartSecond:(NSTimeInterval)startSecond
                             duration:(NSTimeInterval)duration
                                  fps:(float)fps
                                 rate:(float)rate
                          maximumSize:(CGSize)maximumSize
                             cacheURL:(NSURL *)cacheURL
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
                        completeBlock:(JPCropDoneBlock)completeBlock;
```
PS: Round crop and mask are not available when exporting a full video. They currently apply only to images and GIFs.

### Mask image

![mask](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/mask.gif)

```objc
// Set mask image (currently only PNG is supported)
self.imageresizerView.maskImage = [UIImage imageNamed:@"love.png"];

// Setting this value directly calls `-setMaskImage:isToBeArbitrarily:animated:`
// Default: isToBeArbitrarily = (maskImage ? NO : self.isArbitrarily), isAnimated = YES

// Remove mask image
self.imageresizerView.maskImage = nil;
```

![maskdone](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/maskdone.png)

- PS: If a mask image is used, the final output is PNG, so file size may be larger than the original image.

### Round Resize

![round_resize](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/roundresize.jpg)

```objc
// Enable round crop
// After setting, the resizeWHScale is 1:1, the radius is half of the width and height, and the top, left, bottom and right middle of the border can be dragged.
self.imageresizerView.isRoundResize = YES;

// Setting this value directly calls `-setIsRoundResize:isToBeArbitrarily:animated:`
// Default: isToBeArbitrarily = (isRoundResize ? NO : self.isArbitrarily), isAnimated = YES

// Restore rectangle crop
self.imageresizerView.isRoundResize = NO;
// Or just set resizeWHScale to any value
self.imageresizerView.resizeWHScale = 0.0;
```

### Horizontal and vertical screen switching

![screenswitching](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/screenswitching.gif)

```objc
// Call this method when handling portrait/landscape changes or manual layout updates
// 1. updateFrame: target frame (e.g. pass self.view.bounds on orientation change)
// 2. contentInsets: insets between crop area and main view
// 3. duration: refresh animation duration (> 0 enables animation)
// See Demo for details
[self.imageresizerView updateFrame:self.view.bounds contentInsets:contentInsets duration:duration];
```

### Change border style

![concise](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/conciseframetype.jpg)
![classic](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/classicframetype.jpg)

```objc
// Two border styles are provided: concise (JPConciseFrameType) and classic (JPClassicFrameType)
// You can set frameType at initialization or dynamically
self.imageresizerView.frameType = JPClassicFrameType;
```

### Custom Border Image

![stretch_mode](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/customborder1.jpg)
![tile_mode](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/customborder2.jpg)

```objc
// Use custom border image (example: tile mode)
UIImage *tileBorderImage = [[UIImage imageNamed:@"dotted_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];

// Set the offset between the border image and the border (CGRectInset, used to adjust the gap between the border image and the border)
self.imageresizerView.borderImageRectInset = CGPointMake(-1.75, -1.75);

// Set border image (if nil, frameType's default border is used)
self.imageresizerView.borderImage = tileBorderImage;
```

### Switching resizeWHScale

- PS: Setting crop aspect ratio will automatically remove round crop and mask.

```objc
// 1. Switch with custom parameters
/**
 * resizeWHScale:      Target crop aspect ratio (0 means free ratio)
 * isToBeArbitrarily:  Whether resizeWHScale becomes free ratio after switching (if YES, final resizeWHScale = 0)
 * animated:           Whether to animate
 */
[self.imageresizerView setResizeWHScale:(16.0 / 9.0) isToBeArbitrarily:YES animated:YES];

// 2. Direct switch
self.imageresizerView.resizeWHScale = 1.0;
// By default this keeps the latest resizeWHScale and applies animation.
// If set to 0, it uses current crop-frame ratio and finally sets isArbitrarily = YES, equivalent to:
[self.imageresizerView setResizeWHScale:1.0 isToBeArbitrarily:(resizeWHScale <= 0) animated:YES];

// Whether free-ratio dragging is enabled (including round crop and mask)
self.imageresizerView.isArbitrarily = !self.imageresizerView.isArbitrarily;

// For more APIs, see comments in JPImageresizerView.h
```

### Custom crop corner radius

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cornerRadius_crop.gif)

Set crop corner radius:

```objc
self.imageresizerView.resizeCornerRadius = 20;
```

- It is independent of `isRoundResize`, and its priority is lower than `isRoundResize`. The final corner radius will not exceed half of the **shorter side of the crop size**.

If you set crop corner radius, the crop frame will also display rounded corners. If you want the crop frame to stay sharp while only the final output has rounded corners, set:

```objc
self.imageresizerView.ignoresCornerRadiusForDisplay = YES;
```

- Default is `NO`. If set to `YES`, the frame will not display rounded corners even when `resizeCornerRadius` is not 0, but the final cropped result still keeps the corner radius.

### Custom gaussian blur style, border color, background color, mask opacity

```objc
// Set gaussian blur style (default animated is YES)
self.imageresizerView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

// Set border color (default animated is YES)
self.imageresizerView.strokeColor = UIColor.whiteColor;

// Set background color (default animated is YES)
self.imageresizerView.bgColor = UIColor.blackColor;

// Set mask opacity (default animated is YES)
// PS: mutually exclusive with Gaussian blur. When Gaussian blur is set, the mask is transparent
self.imageresizerView.maskAlpha = 0.5; // Only blurEffect = nil will take effect 

// Configure blur style, border color, background color, and mask opacity in one call
[self.imageresizerView setupStrokeColor:strokeColor blurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark] bgColor:UIColor.blackColor maskAlpha: 0.5 animated:YES];
```

### Mirror reversal

![mirror](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/mirror.gif)

```objc
// 1. Vertical mirror, YES -> rotate 180 degrees along Y axis, NO -> restore
BOOL isVerticalityMirror = !self.imageresizerView.verticalityMirror;
[self.imageresizerView setVerticalityMirror:isVerticalityMirror animated:YES];

// 2. Horizontal mirror, YES -> rotate 180 degrees along X axis, NO -> restore
BOOL isHorizontalMirror = !self.imageresizerView.horizontalMirror;
[self.imageresizerView setHorizontalMirror:isHorizontalMirror animated:YES];
```

### Rotate

```objc
// 1.Rotate 90 ° clockwise / counterclockwise (default counterclockwise)
[self.imageresizerView rotation];

// Set the isClockwiseRotation property to YES if clockwise rotation is required
self.imageresizerView.isClockwiseRotation = YES;

// 2.Customize the rotation to the target direction (four directions are supported: vertical up, horizontal left, vertical down and horizontal right)
[self.imageresizerView rotationToDirection:JPImageresizerVerticalDownDirection];
```

If a fixed `resizeWHScale` is set and you want it to automatically flip when switching between portrait and landscape orientation (e.g., `resizeWHScale = 3 / 5` in portrait becomes `resizeWHScale = 5 / 3` in landscape), set `isFlipResizeWHScaleOnVerHorSwitch = YES`.

![flip_resizeWHScale_onVerHorSwitch](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/flip_resizeWHScale_onVerHorSwitch.gif)

- **Note 1:** By default, `resizeWHScale` is based on the view's orientation from the user's perspective, not the image's orientation. For example, if `resizeWHScale = 16 / 9` is set, rotating the view 90° will still display a 16:9 ratio from the user's point of view, though the image's internal orientation would effectively be 9:16. Setting `isFlipResizeWHScaleOnVerHorSwitch = YES` makes the `resizeWHScale` follow the image's orientation instead.

- **Note 2:** If a mask image (`maskImage`) is set, `isFlipResizeWHScaleOnVerHorSwitch` will be ignored.

### Reset

Reset target state to vertical-up direction. You can reset to different resizeWHScale, round crop, or mask.

#### 1. Reset all based on current state
```objc
- (void)recovery;
```

#### 2. Reset by resizeWHScale (removes round crop and mask)

```objc
// 2.1 Reset according to the initial clipping aspect ratio
- (void)recoveryByInitialResizeWHScale;
- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily;

// 2.2 Reset to the current clipping aspect ratio (reset to the entire crop element area if the resizeWHScale is 0)
- (void)recoveryByCurrentResizeWHScale;
- (void)recoveryByCurrentResizeWHScale:(BOOL)isToBeArbitrarily;

// 2.3 Reset by target crop aspect ratio (if resizeWHScale is 0, reset to full crop source area)
// targetResizeWHScale: Target clipping aspect ratio
// isToBeArbitrarily: Whether resizeWHScale becomes free ratio after reset (if YES, final resizeWHScale = 0)
- (void)recoveryToTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily;
```

#### 3. Reset to round crop

```objc
- (void)recoveryToRoundResize;
- (void)recoveryToRoundResize:(BOOL)isToBeArbitrarily;
```

#### 4. Reset with mask image

```objc
// 4.1 Reset by current mask image
- (void)recoveryByCurrentMaskImage;
- (void)recoveryByCurrentMaskImage:(BOOL)isToBeArbitrarily;

// 4.2 Reset with specified mask image
- (void)recoveryToMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily;
```

### Preview

```objc
// Preview mode: hide the frame and disable drag operations, used to preview the cropped area.

// Default includes animation:
self.imageresizerView.isPreview = YES;

// Equivalent:
[self.imageresizerView setIsPreview:YES animated:YES];
```

### Save current crop state

```objc
// 1. Call saveCurrentConfigure to get current crop state. You can store this object in a global variable.
JPImageresizerConfigure *savedConfigure = [self.imageresizerView saveCurrentConfigure];

// 2. Reopen crop history
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:savedConfigure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    ......
} imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
    ......
}];
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// 3. You can set JPImageresizerConfigure.isCleanHistoryAfterInitial = YES to auto-clear history after initialization (default is YES)
// Or call cleanHistory directly
```

![save](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/save.gif)

- PS1: If `savedConfigure.history.viewFrame` is inconsistent with current `viewFrame`, UI may become incorrect. Check consistency before reopening.
- PS2: Currently this works only during app runtime. Persistent history cache is not implemented yet.

### Other

```objc
// Lock the clipping area. After locking, the clipping area cannot be dragged. NO unlocks the clipping area.
self.imageresizerView.isLockResizeFrame = YES;
```

## Install

### Swift Package Manager

- In Xcode, select: File -> Swift Packages -> Add Package Dependency
- Enter the package repository URL: https://github.com/Rogue24/JPImageresizerView.git
- Choose an appropriate version (for example, a specific version, branch, or commit)
- Add `JPImageresizerView` to your target dependencies

### CocoaPods

Just add the following line to your Podfile:

```ruby
pod 'JPImageresizerView'

Update command: pod update --no-repo-update
```

### Swift Package Manager

This library now supports Swift Package Manager (requires **Xcode 11** or later):

```swift
.dependencies: [
    .package(url: "https://github.com/Rogue24/JPImageresizerView.git", .upToNextMajor(from: "1.14.0"))
]
```

Or add the repository URL in Xcode:

```swift
https://github.com/Rogue24/JPImageresizerView.git
```

## Feedback address

    E-mail: zhoujianping24@hotmail.com
    Blog: https://juejin.im/user/5e55f27bf265da575c16c187

## License

JPImageresizerView is available under the MIT license. See the LICENSE file for more info.
