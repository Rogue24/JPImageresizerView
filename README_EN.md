# JPImageresizerView

[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Language](http://img.shields.io/badge/language-ObjC-brightgreen.svg?style=flat)](https://developer.apple.com/Objective-C)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

[Juejin](https://juejin.cn/post/6958761756978053150) | [Xiaohongshu-like App Cropping with Free-Angle Dragging](https://github.com/Rogue24/JPCrop)

## Introduction (Current version: 1.14.0)

This is a dedicated library for cropping images, GIFs, and videos. It is easy to use and feature-rich (highly flexible parameters, rotation and mirror flipping, masks, compression, etc.), and can cover most cropping scenarios.

![effect](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cover.gif)

    Feature:
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
        🔘 Fixed non-scalable crop frame;
        🔘 Crop video without requiring orientation correction first;
        🔘 Remote video cropping;
        🔘 Persistent cached crop history;
        🔘 Split out video-cropping logic (AVFoundation module);
        🔘 Implement free-angle drag rotation/flip like Apple Photos.
        
    Note: Because automatic layout is not conducive to gesture control, frame layout is currently used, and automatic layout is not supported for the time being.
    
## Latest Changes
    1. Unified appearance configuration (crop border color, blur effect, background color, mask alpha);
    2. Added custom crop corner radius, and an option to hide corner radius only during editing while keeping rounded corners in final output;
    3. Added custom mask appearance configuration, and support for ignoring mask during crop;
    4. When using mask or round crop, you can still set crop aspect ratio and whether free dragging is allowed.

#### Added an iOS 26 style glass crop frame, selectable as the **Glass Style** frame in Demo (see Demo for specific setup):

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/glass_effect_border.gif)

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/glass_effect_picture.jpg)

- PS: The visual effect is nice. You can directly take a screenshot to generate a 3D wallpaper (other controls are automatically hidden while screenshotting) 🤠

#### GIF now supports background color, corner radius, border, outline stroke, and content insets:

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/processforgif.gif)

## How to use

### Initialization

#### 1. Configure initial parameters

    You can only select one of the clipping elements (picture, GIF, video) that can be set and cannot be nil:
        - image: Image / GIF to crop (sent in as UIImage)
        - imageData: Image / GIF to crop (sent in as NSData)
        - videoURL: Local video to crop (sent in as NSURL)
        - videoAsset: Local video to crop (sent in as AVURLAsset)
        
    Other configurable parameters (see header files for more details):
        - mainAppearance: primary appearance configuration
            - strokeColor: border color
            - bgEffect: blur effect
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
// 1.Image / GIF to crop (sent in as UIImage)
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImage:image make:^(JPImageresizerConfigure *configure) {
    // Now that you have the default parameter value, you can set the parameter value you want here
    configure
    .jp_maskAlpha(0.5)
    .jp_strokeColor([UIColor yellowColor])
    .jp_frameType(JPClassicFrameType)
    .jp_contentInsets(contentInsets)
    .jp_bgColor([UIColor orangeColor])
    .jp_isClockwiseRotation(YES)
    .jp_animationCurve(JPAnimationCurveEaseOut);
}];

// If you want to initialize to a square, you can set the resizeWHScale property of JPImageresizerConfigure
configure.resizeWHScale = 1; // The default value is 0, full display
// In addition, if a fixed proportion is needed:
configure.isArbitrarily = YES; // The default is YES

// 2.Image / GIF to crop (sent in as NSData)
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImageData:imageData make:^(JPImageresizerConfigure *configure) { ...... };
```

**Local Video**

For the video obtained from the system album, the video direction may be modified (i.e. rotated and flipped in system album), revised `videoTrack.preferredTransform != CGAffineTransformIdentity`. The image will, but at least the image has an `imageOrientation` property to tell me what has been changed. Due to my shallow learning, I don't know what specific changes have been made from `preferredTransform` alone, If only the rotation is good, the value after rotation + flip is not certain, which will lead to confusion in the final cutting. At present, we have to correct the direction before cutting, and improve it in the future. We hope that we can get some advice from those who have the chance!

Modify after initialization (modify after entering the page first). For specific operations, please refer to demo:

```objc
// 1.videoURL: Local video to crop (sent in as NSURL)
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoURL:videoURL make:^(JPImageresizerConfigure *configure) { ...... } fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // Initialize error callback to correct video direction
} fixStartBlock:^{
    // Initializes the start callback for correcting the video direction
} fixProgressBlock:^(float progress) {
    // Initiate the progress callback of correcting video direction
} fixCompleteBlock:^(NSURL *cacheURL) {
    // Initializes the completion callback for correcting the video direction
}];

// 2.videoAsset: Local video to crop (sent in as AVURLAsset)
[JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset 
                                                   make:^(JPImageresizerConfigure *configure) { ...... } 
                                          fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) { ...... } 
                                          fixStartBlock:^{ ...... } fixProgressBlock:^(float progress) { ...... } 
                                       fixCompleteBlock:^(NSURL *cacheURL) { ...... }];
```

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/videofixorientation.gif)

Or fix it first and then initialize it (fix it first and then enter the page). You can use the API of `JPImageresizerTool` to fix it. For specific operations, please refer to demo:

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
    // No need to modify, enter the clipping interface
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:videoAsset make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
    ......
    return;
}

// Fix the orientation
[JPImageresizerTool fixOrientationVideoWithAsset:videoAsset fixErrorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // Fixed error callback in video direction
} fixStartBlock:^(AVAssetExportSession *exportSession) {
    // Fixed the start callback of video direction
    // Return to exportsession to monitor the progress or cancel the export
} fixCompleteBlock:^(NSURL *cacheURL) {
    // Fixed the completion callback of video direction
    // cacheURL: The final storage path of the video after the direction correction is exported. The default path is NSTemporaryDirectory folder. Save the path and delete the video after clipping.
    
    // Start clipping and enter the clipping interface
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoAsset:[AVURLAsset assetWithURL:cacheURL] make:nil fixErrorBlock:nil fixStartBlock:nil fixProgressBlock:nil fixCompleteBlock:nil];
    ......
}];
```

- PS1: If the video does not need to be corrected, `fixStartBlock`, `fixProgressBlock`, `fixErrorBlock` will not be called. Instead, `fixCompleteBlock` will be called directly to return to the original path; 
- PS2: If it is determined that the video does not need to be corrected, `fixErrorBlock`、`fixStartBlock`、`fixProgressBlock`、`fixCompleteBlock` are transmitted to `nil`;
- PS3: The same is true for replace video `-setVideoURL: animated: fixErrorBlock: fixStartBlock: fixProgressBlock: fixCompleteBlock:` and `-setVideoAsset: animated: fixErrorBlock: fixStartBlock: fixProgressBlock: fixCompleteBlock:` methods, internal will determine whether it needs to be corrected;
- PS4: If you need to initialize and fix the clipping aspect ratio (such as circular cutting, masking, etc.), you need to set the `isArbitrarily` property of `JPImageresizerConfigure` to **NO** (the default is YES) :

```objc
JPImageresizerConfigure *configure = [JPImageresizerConfigure darkBlurMaskTypeConfigureWithImage:nil make:^(JPImageresizerConfigure *configure) {
    configure
    .jp_maskImage([UIImage imageNamed:@"love.png"])
    .jp_isArbitrarily(NO);
}];
```

#### 2. Create JPImageresizerView instance object and add to view

```objc
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    // You can listen here to see if you can reset it.
    // If you don't need to reset (isCanRecovery is NO), you can do the corresponding processing here, such as setting the reset button to be non-point or hidden
    // PS: isCanRecovery is only for the changes of [Rotation], [Zoom] and [Mirror]. For other changes such as resizeWHScale and isRoundResize, the user must decide whether to reset
    // Specific operation can refer to Demo
    // Pay attention to circular references
} imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
    // Here you can monitor whether the clipping area is ready to be scaled to the appropriate size.
    // If isPrepareToScale is YES, the clipping, rotation, and mirroring functions are not available at this time, the corresponding processing can be done here, such as setting the corresponding button to be non-point or hidden.
    // Specific operation can refer to Demo
    // Pay attention to circular references
}];
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// After creation, you can dynamically modify the parameters of configure
self.imageresizerView.image = [UIImage imageNamed:@"Kobe.jpg"]; // Change picture (animated by default)
self.imageresizerView.resizeWHScale = 16.0 / 9.0; // Change crop aspect ratio
self.imageresizerView.initialResizeWHScale = 0.0; // The default value is resizeWHScale at initialization. If you call the - recoveryByInitialResizeWHScale method to reset, the value of this property will be reset

// Note: For systems under iOS 11, it is best for the controller to set automaticallyAdjustsScrollViewInsets to NO
// Otherwise, imagesizerView will be offset with the change of navigationBar or statusBar
if (@available(iOS 11.0, *)) {

} else {
    self.automaticallyAdjustsScrollViewInsets = NO;
}
```

#### Using in Swift

```swift
// 1.Initial configuration
let configure = JPImageresizerConfigure.defaultConfigure(with: image) { c in
    _ = c
        .jp_viewFrame(frame)
        .jp_bgColor(.black)
        .jp_frameType(.classicFrameType)
        .jp_contentInsets(.init(top: 16, left: 16, bottom: 16, right: 16))
        .jp_animationCurve(.easeInOut)
}

// 2.Create imageresizerView
let imageresizerView = JPImageresizerView(configure: configure) { [weak self] isCanRecovery in
    // Disable reset button when reset is not needed
    self?.recoveryBtn.isEnabled = isCanRecovery
} imageresizerIsPrepareToScale: { [weak self] isPrepareToScale in
    // Disable operation buttons while preparing to scale; re-enable after done
    self?.operationView.isUserInteractionEnabled = !isPrepareToScale
}

// 3.Add to view
view.insertSubview(imageresizerView, at: 0)
self.imageresizerView = imageresizerView
```

For specific use, refer to Demo (JPCropViewController).

#### Customizable Initial Cropping Area

You can modify the initial cropping area by setting the `resizeScaledBounds` property of `JPImageresizerConfigure` (by default, the entire crop element's size is displayed).

```objc
configure.resizeScaledBounds = CGRectMake(0.1, 0.1, 0.8, 0.8);
```

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/initial_resizeScaledBounds.jpg)

- The value of this property is represented as a **percentage of the original size**. For example, the above setting means the initial cropping area will cover `80%` of the crop element's center.
- This property is mutually exclusive with another property of `JPImageresizerConfigure`, `resizeWHScale`. When `resizeScaledBounds` is set, the `resizeWHScale` of `imageresizerView` will be automatically calculated as `resizeScaledBounds.size.width / resizeScaledBounds.size.height`.
- This property will only be used once during initialization. Therefore, if it has been set or if you later configure `imageresizerView` with `resizeWHScale`, `isRoundResize`, or `maskImage`, the `resizeScaledBounds` will be cleared.

For detailed usage, please refer to **Face Cropping** in the Demo.

### Crop
    Explain: 
        1.The clipping process is executed in the sub thread, and the progress, error and completed callback will be switched back to the main thread for execution. If it is a high-definition image, HUD prompt can be added before clipping;
        2.compressScale: Image and GIF compression ratio, greater than or equal to 1, according to the size of the original image, less than or equal to 0, return nil (Example: compressScale = 0.5, 1000 x 500 --> 500 x 250);
        3.cacheURL: The cache path can be set to nil, while the images and GIF will not be cached. The video will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4;
        4.JPImageresizerErrorReason: Cause of error
            - JPIEReason_NilObject: The clipping element is empty
            - JPIEReason_CacheURLAlreadyExists: Another file already exists for the cache path
            - JPIEReason_NoSupportedFileType: Unsupported file type
            - JPIEReason_VideoAlreadyDamage: The video file is corrupted
            - JPIEReason_VideoExportFailed: Video export failed
            - JPIEReason_VideoExportCancelled: Video export cancelled
        5.Note: the image format of the cache path will be automatically corrected. For example, it was originally written as `xxx/xxx.jpeg`. Due to the use of mask, it will be corrected to `xxx/xxx.png` after clipping. The final cache path shall be subject to `result.cacheurl` in the callback(`completeBlock`).
    
#### Crop image

```objc
// 1.Cut to original size
[self.imageresizerView cropPictureWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} completeBlock:^(JPImageresizerResult *result) {
    // Crop complete
    // result: JPImageresizerResult
    // result.image: Image that has been decoded after clipping
    // result.cacheURL: Cache path
    // result.isCacheSuccess: Whether the cache is successful, NO means unsuccessful, and the cacheurl is nil
    // Pay attention to circular references
}];


// 2.Custom compression ratio crop picture
// compressScale: If it is greater than or equal to 1, it will be cropped according to the size of the original image; if it is less than or equal to 0, it will return nil (for example: compressscale = 0.51000 x 500 -- > 500 x 250)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                            cacheURL:(NSURL *)cacheURL
                          errorBlock:(JPImageresizerErrorBlock)errorBlock
                       completeBlock:(JPCropDoneBlock)completeBlock;
```

- **Crop N-grid pictures**

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropngird.gif)

```objc
// 1.Custom n-grid crop picture
// columnCount: The number of columns of n-grid (minimum 1 column)
// rowCount: The number of rows of n-grid (minimum 1 row)
// compressScale: If it is greater than or equal to 1, it will be cropped according to the size of the original image; if it is less than or equal to 0, it will return nil (for example: compressscale = 0.51000 x 500 -- > 500 x 250)
// bgColor: Background color of nine grid (set the background color of hidden (transparent) area if the picture has transparent area or mask is set)
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

// 2.Nine grid crop picture (3 rows and 3 columns)
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
// 1.Original size clipping GIF
[self.imageresizerView cropGIFWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} completeBlock:^(JPImageresizerResult *result) {
    // Crop complete
    // result: JPImageresizerResult
    // result.image: GIF that has been decoded after clipping
    // result.cacheURL: Cache path
    // result.isCacheSuccess: Whether the cache is successful, NO means unsuccessful, and the cacheurl is nil
    // Pay attention to circular references
}];

// 2.Custom compression scale clipping GIF
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded GIF and cache path)
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropDoneBlock)completeBlock;

// 3.Custom crop GIF
// isReverseOrder: Inverted or not
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded GIF and cache path)
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
// 1.The size of the original image cuts the current frame of GIF
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropGIFCurrentIndexWithCacheURL:(NSURL *)cacheURL
                             errorBlock:(JPImageresizerErrorBlock)errorBlock
                          completeBlock:(JPCropDoneBlock)completeBlock;

// 2.Customize the compression ratio to crop the current frame of GIF
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                    cacheURL:(NSURL *)cacheURL
                                  errorBlock:(JPImageresizerErrorBlock)errorBlock
                               completeBlock:(JPCropDoneBlock)completeBlock;

// 3.Custom compression ratio clipping GIF specified frame
// index: What frame
// compressScale: If it is greater than or equal to 1, it will be cropped according to the size of the original image; if it is less than or equal to 0, it will return nil (for example: compressscale = 0.51000 x 500 -- > 500 x 250)
- (void)cropGIFWithIndex:(NSUInteger)index
           compressScale:(CGFloat)compressScale
                cacheURL:(NSURL *)cacheURL
              errorBlock:(JPImageresizerErrorBlock)errorBlock
           completeBlock:(JPCropDoneBlock)completeBlock;
```
PS: You can set isLoopPlaybackGIF to choose which frame to crop (the default is NO, if YES is set, GIF will be played automatically)
```objc
self.imageresizerView.isLoopPlaybackGIF = NO;
```

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/noloopplaybackgif.gif)

#### Crop local video

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideo.gif)

PS: At present, it is only for local video, and remote video is not suitable for the moment.

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
    // Tailoring complete
    // result: JPImageresizerResult
    // result.cacheURL: If the cacheurl is set to nil, it will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4
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
// When the video is being exported, the call can cancel the export and trigger the errorblock callback (JPIEReason_ExportCancelled)
- (void)videoCancelExport;
```

PS: Since the width and height of the video must be an integer multiple of 16, otherwise the system will automatically correct the size after export, and the insufficient areas will be filled in the form of green edge. Therefore, I modified the clipping size by division of 16 in the method. Therefore, the width to height ratio of the exported video may be slightly different from the specified width height ratio.

- **Clip one frame of the video**

```ojbc
// 1.The size of the original image cuts the current frame of the video
// cacheURL: Cache path (can be set to nil, it will not be cached)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropVideoCurrentFrameWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPImageresizerErrorBlock)errorBlock
                            completeBlock:(JPCropDoneBlock)completeBlock;

// 2.Clipping the current frame of video with custom compression ratio
// cacheURL: Cache path (can be set to nil, it will not be cached)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                      cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
                                 completeBlock:(JPCropDoneBlock)completeBlock;

// 3.Custom compression ratio clipping video frame
// second: Second screen
// cacheURL: Cache path (can be set to nil, it will not be cached)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded image and cache path)
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                           cacheURL:(NSURL *)cacheURL
                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                      completeBlock:(JPCropDoneBlock)completeBlock;
```

- **Cut a video segment and transfer it to GIF**

![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideotogif.gif)

```objc
// 1.Video from the current time to capture a specified number of seconds screen to GIF (fps = 10, rate = 1, maximumSize = 500 * 500)
// duration: How many seconds are intercepted
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded GIF and cache path)
- (void)cropVideoToGIFFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                           cacheURL:(NSURL *)cacheURL
                                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                                      completeBlock:(JPCropDoneBlock)completeBlock;

// 2.Video custom capture the specified number of seconds to GIF
// duration: How many seconds are intercepted
// fps: Frame rate (set to 0 to use the real frame rate of the video)
// maximumSize: Intercepted size (set to 0 to take the real size of the video)
// completeBlock: Clipping completed callback (return JPImageresizerResult, contains the decoded GIF and cache path)
- (void)cropVideoToGIFFromStartSecond:(NSTimeInterval)startSecond
                             duration:(NSTimeInterval)duration
                                  fps:(float)fps
                                 rate:(float)rate
                          maximumSize:(CGSize)maximumSize
                             cacheURL:(NSURL *)cacheURL
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
                        completeBlock:(JPCropDoneBlock)completeBlock;
```
PS: The function of cutting the whole video image into circles and masking can not be used. At present, it is only effective for pictures and GIF.

### Mask image

![mask](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/mask.gif)

```objc
// Set mask picture (currently only PNG picture is supported)
self.imageresizerView.maskImage = [UIImage imageNamed:@"love.png"];

// Setting this value directly calls the `-setMaskImage: isToBeArbitrarily: animated:` method, where the default `isToBeArbitrarily` = (maskImage ? No : self.isArbitrarily), `isAnimated` = YES

// Remove mask image
self.imageresizerView.maskImage = nil;
```

![maskdone](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/maskdone.png)

- PS: If the mask image is used, the PNG image is finally cropped out, so the cropped size may be larger than the original image.

### Round Resize

![round_resize](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/roundresize.jpg)

```objc
// Set circle cut
// After setting, the resizeWHScale is 1:1, the radius is half of the width and height, and the top, left, bottom and right middle of the border can be dragged.
self.imageresizerView.isRoundResize = YES;

// Setting this value directly calls the `-setIsRoundResize: isToBeArbitrarily: animated:` method, where the default `isToBeArbitrarily` = (isRoundResize ? No : self.isArbitrarily), `isAnimated` = YES

// Reduced rectangle
self.imageresizerView.isRoundResize = NO;
// Or just set resizeWHScale to any value
self.imageresizerView.resizeWHScale = 0.0;
```

### Horizontal and vertical screen switching

![screenswitching](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/screenswitching.gif)

```objc
// This method is called to refresh when the user needs to listen to the horizontal and vertical screen switching or manually switch by himself
// 1.updateFrame: Refresh frame (e.g. horizontal and vertical screen switching, incoming self.view.bounds Just).
// 2.contentInsets: The inner margin between the crop region and the main view.
// 3.duration: Animation Duration (< 0, No animation).
//【Specific operation can refer to Demo】
[self.imageresizerView updateFrame:self.view.bounds contentInsets:contentInsets duration:duration];
```

### Change border style

![concise](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/conciseframetype.jpg)
![classic](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/classicframetype.jpg)

```objc
// Only two border styles are available, concise style(JPConciseFrameType) and classic style(JPClassicFrameTypeCurrently).
// You can modify the border style by initializing or directly setting frameType properties
self.imageresizerView.frameType = JPClassicFrameType;
```

### Custom Border Image

![stretch_mode](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/customborder1.jpg)
![tile_mode](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/customborder2.jpg)

```objc
// Use custom border pictures (example: tile mode)
UIImage *tileBorderImage = [[UIImage imageNamed:@"dotted_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];

// Set the offset between the border image and the border (CGRectInset, used to adjust the gap between the border image and the border)
self.imageresizerView.borderImageRectInset = CGPointMake(-1.75, -1.75);

// Set the border image (use frameType's borders if it's nil)
self.imageresizerView.borderImage = tileBorderImage;
```

### Switching resizeWHScale

- PS: Setting the clipping aspect ratio automatically removes the circular cuts and masks

```objc
// 1.Custom parameter switching
/**
 * resizeWHScale:      Target tailoring aspect ratio (0 is arbitrary ratio)
 * isToBeArbitrarily:  Whether resizeWHScale is an arbitrary proportion after switching (if YES, last resizeWHScale = 0)
 * animated:           Whether with animation
 */
[self.imageresizerView setResizeWHScale:(16.0 / 9.0) isToBeArbitrarily:YES animated:YES];

// 2.Direct Settings
self.imageresizerView.resizeWHScale = 1.0;
// After the default switch, the latest resizeWHScale is saved with its own animation effect. If it is set to 0, the width to height ratio of the current clipping box is set, and finally isArbitrarily = YES, which is equivalent to:
[self.imageresizerView setResizeWHScale:1.0 isToBeArbitrarily:(resizeWHScale <= 0) animated:YES];

// Whether it can be dragged in any proportion (including circle cutting and masking)
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

// One step: set the gaussian blur style, border color, background color and mask opacity
[self.imageresizerView setupStrokeColor:strokeColor blurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark] bgColor:UIColor.blackColor maskAlpha: 0.5 animated:YES];
```

### Mirror reversal

![mirror](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/mirror.gif)

```objc
// Vertical Mirror, YES -> Rotates 180 degrees along Y axis, NO -> Reduction
BOOL isVerticalityMirror = !self.imageresizerView.verticalityMirror;
[self.imageresizerView setVerticalityMirror:isVerticalityMirror animated:YES];

// Horizontal Mirror, YES -> Rotates 180 Degrees along X-axis, NO -> Reduction
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

Reset the target state, the direction is vertical upward, can be reset to different resizeWHScale, circle cut, mask

#### 1.Everything is reset according to the current state
```objc
- (void)recovery;
```

#### 2.Reset with resizeWHScale (circle cuts and masks will be removed)

```objc
// 2.1 Reset according to the initial clipping aspect ratio
- (void)recoveryByInitialResizeWHScale;
- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily;

// 2.2 Reset to the current clipping aspect ratio (reset to the entire crop element area if the resizeWHScale is 0)
- (void)recoveryByCurrentResizeWHScale;
- (void)recoveryByCurrentResizeWHScale:(BOOL)isToBeArbitrarily;

// 2.3 Reset by target crop aspect ratio (reset to the entire crop element area if resizeWHScale is 0)
// targetResizeWHScale: Target clipping aspect ratio
// isToBeArbitrarily: Whether the size of the resizewhscale is any scale after reset (if YES, the last resizeWHScale = 0)
- (void)recoveryToTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily;
```

#### 3.Reset with circle cut

```objc
- (void)recoveryToRoundResize;
- (void)recoveryToRoundResize:(BOOL)isToBeArbitrarily;
```

#### 4.Reset with mask image

```objc
// 4.1 Reset by current mask image
- (void)recoveryByCurrentMaskImage;
- (void)recoveryByCurrentMaskImage:(BOOL)isToBeArbitrarily;

// 4.2 Specify mask image reset
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
// 1.It is easy to directly call the savecurrentconfigure method to obtain the current clipping state. A global variable can be used to save the object
JPImageresizerConfigure *savedConfigure = [self.imageresizerView saveCurrentConfigure];

// 2.Reopen crop history
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:savedConfigure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    ......
} imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
    ......
}];
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// 3.You can set the isCleanHistoryAfterInitial property of JPImageresizerConfigure to YES, and automatically clear the history after initialization (yes by default)
// Or call the cleanHistory method directly to clear the history
```

![save](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/save.gif)

- PS1: If preserved `savedConfigure.history.viewFrame` If it is inconsistent with the current `viewFrame`, the interface will be disordered, and you need to judge whether it is consistent before reopening;
- PS2: In addition, it can only be saved during the usage of the App, and the persistent cache has not been implemented.

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
