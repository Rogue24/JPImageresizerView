# JPImageresizerView

[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Language](http://img.shields.io/badge/language-ObjC-brightgreen.svg?style=flat)](https://developer.apple.com/Objective-C)

[Chinese document(中文文档)](https://github.com/Rogue24/JPImageresizerView) | [Juejin](https://juejin.im/post/5ecd0cddf265da7711699e0d) |
[Little Red Book App Crop](https://github.com/Rogue24/JPCrop)

*本人英语小白，这里基本都是用百度翻译出来的，Sorry。*

## Brief introduction (Current version: 1.7.8)

A special wheel for cutting pictures, GIF and videos is simple and easy to use, with rich functions (high degree of freedom parameter setting, supporting rotation and mirror flipping, masking, compression, etc.), which can meet the needs of most cutting.

![effect](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cover.gif)

    Current functions:
        ✅ Zooming of area that can be tailored adaptively;
        ✅ The parameters are set with high degrees of freedom, include spacing of clipping area, cutting aspect ratio, whether to scale adaptively;
        ✅ Supports up to eight drag and drop direction;
        ✅ Support rotation;
        ✅ Support horizontal and vertical mirror flip;
        ✅ Two border styles;
        ✅ Supports circular clipping;
        ✅ Custom gaussian blur style, border color, background color, mask opacity;
        ✅ Custom border image;
        ✅ It can dynamically change the spacing between view area and crop area, and supports horizontal and vertical screen switching;
        ✅ Can customize the mask image clipping;
        ✅ It can cut the whole picture or a frame of local video;
        ✅ A local video can be intercepted, cut and transferred to GIF;
        ✅ Can crop GIF;
        ✅ The current clipping state can be saved.

    TODO:
        🔘 Swift version;
        🔘 Fix the clipping region without scaling;
        🔘 The video does not need to fix the orientation before clipping;
        🔘 Crop remote video;
        🔘 Persistent cache pruning history;
        🔘 The video clipping part (AVFoundation module) is separated;
        🔘 To achieve the effect of free drag rotation and flip angle.
        
    Note: Because automatic layout is not conducive to gesture control, frame layout is currently used, and automatic layout is not supported for the time being.

## How to use

### Initialization
#### 1. Configure initial parameters

    You can only select one of the clipping elements (picture, GIF, video) that can be set and cannot be nil:
        - image: Image / GIF to crop (sent in as UIImage)
        - imageData: Image / GIF to crop (sent in as NSData)
        - videoURL: Local video to crop (sent in as NSURL)
        - videoAsset: Local video to crop (sent in as AVURLAsset)
        
    Notes to some configurable parameters (see JPImageresizerView.h for more details):
      - blurEffect: gaussian blur style
      - borderImage: custom border image
      - frameType & strokeColor: border style & color
      - bgColor: background color
      - maskAlpha: mask opacity
      - resizeWHScale: width-height ratio of the clipping
      - contentInsets: the inner margin between the crop region and the main view
      - maskImage: customize the mask image
     
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
    
#### Crop image
```objc
// 1.Cut to original size
[self.imageresizerView cropPictureWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
    // Crop complete
    // finalImage: Image that has been decoded after clipping
    // cacheURL: Cache path
    // isCacheSuccess: Whether the cache is successful, NO means unsuccessful, and the cacheurl is nil
    // Pay attention to circular references
}];


// 2.Custom compression ratio crop picture
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropPictureWithCompressScale:(CGFloat)compressScale
                            cacheURL:(NSURL *)cacheURL
                          errorBlock:(JPImageresizerErrorBlock)errorBlock
                       completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

#### Crop GIF
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgif.gif)
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgifdone.gif)
```objc
// 1.Original size clipping GIF
[self.imageresizerView cropGIFWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} completeBlock:^(UIImage *finalImage, NSURL *cacheURL, BOOL isCacheSuccess) {
    // Crop complete
    // finalImage: GIF that has been decoded after clipping
    // cacheURL: Cache path
    // isCacheSuccess: Whether the cache is successful, NO means unsuccessful, and the cacheurl is nil
    // Pay attention to circular references
}];

// 2.Custom compression scale clipping GIF
// completeBlock --- Clipping completed callback (return decoded GIF, cache path, whether cache succeeded)
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.Custom crop GIF
// isReverseOrder --- Inverted or not
// completeBlock --- Clipping completed callback (return decoded GIF, cache path, whether cache succeeded)
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                  isReverseOrder:(BOOL)isReverseOrder
                            rate:(float)rate
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPImageresizerErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

**Crop one of the GIF frames**
```objc
// 1.The size of the original image cuts the current frame of GIF
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropGIFCurrentIndexWithCacheURL:(NSURL *)cacheURL
                             errorBlock:(JPImageresizerErrorBlock)errorBlock
                          completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.Customize the compression ratio to crop the current frame of GIF
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                    cacheURL:(NSURL *)cacheURL
                                  errorBlock:(JPImageresizerErrorBlock)errorBlock
                               completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.Custom compression ratio clipping GIF specified frame
// index --- What frame
- (void)cropGIFWithIndex:(NSUInteger)index
           compressScale:(CGFloat)compressScale
                cacheURL:(NSURL *)cacheURL
              errorBlock:(JPImageresizerErrorBlock)errorBlock
           completeBlock:(JPCropPictureDoneBlock)completeBlock;
```
- PS: You can set isLoopPlaybackGIF to choose which frame to crop (the default is NO, if YES is set, GIF will be played automatically)
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/noloopplaybackgif.gif)
```objc
self.imageresizerView.isLoopPlaybackGIF = NO;
```
#### Crop local video
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideo.gif)
- PS: At present, it is only for local video, and remote video is not suitable for the moment.
```objc
// Clip the entire video
// cacheURL: If it is nil, it will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4
[self.imageresizerView cropVideoWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPImageresizerErrorReason reason) {
    // error callback
    // reason: JPImageresizerErrorReason
    // Pay attention to circular references
} progressBlock:^(float progress) {
    // Monitor progress
    // progress：0~1
    // Pay attention to circular references
} completeBlock:^(NSURL *cacheURL) {
    // Tailoring complete
    // cacheURL: If the cacheurl is set to nil, it will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4
    // Pay attention to circular references
}];

// Video export quality can be set
// presetName --- The video export quality of the system, such as: AVAssetExportPresetLowQuality, AVAssetExportPresetMediumQuality, AVAssetExportPresetHighestQuality, etc
- (void)cropVideoWithPresetName:(NSString *)presetName
                       cacheURL:(NSURL *)cacheURL 
                       errorBlock:(JPImageresizerErrorBlock)errorBlock
                 progressBlock:(JPExportVideoProgressBlock)progressBlock
                 completeBlock:(JPExportVideoCompleteBlock)completeBlock;

// Cancel video export
// When the video is being exported, the call can cancel the export and trigger the errorblock callback (JPIEReason_ExportCancelled)
- (void)videoCancelExport;
```
- PS: Since the width and height of the video must be an integer multiple of 16, otherwise the system will automatically correct the size after export, and the insufficient areas will be filled in the form of green edge. Therefore, I modified the clipping size by division of 16 in the method. Therefore, the width to height ratio of the exported video may be slightly different from the specified width height ratio.

**Clip one frame of the video**
```ojbc
// 1.The size of the original image cuts the current frame of the video
// cacheURL --- Cache path (can be set to nil, it will not be cached)
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropVideoCurrentFrameWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPImageresizerErrorBlock)errorBlock
                            completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.Clipping the current frame of video with custom compression ratio
// cacheURL --- Cache path (can be set to nil, it will not be cached)
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                      cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPImageresizerErrorBlock)errorBlock
                                 completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.Custom compression ratio clipping video frame
// second --- Second screen
// cacheURL --- Cache path (can be set to nil, it will not be cached)
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                           cacheURL:(NSURL *)cacheURL
                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                      completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

**Cut a video segment and transfer it to GIF**
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideotogif.gif)
```objc
// 1.Video from the current time to capture a specified number of seconds screen to GIF (fps = 10, rate = 1, maximumSize = 500 * 500)
// duration --- How many seconds are intercepted
// completeBlock --- Clipping completed callback (return decoded GIF, cache path, whether cache succeeded)
- (void)cropVideoToGIFFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                           cacheURL:(NSURL *)cacheURL
                                         errorBlock:(JPImageresizerErrorBlock)errorBlock
                                      completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.Video custom capture the specified number of seconds to GIF
// duration --- How many seconds are intercepted
// fps --- Frame rate (set to 0 to use the real frame rate of the video)
// maximumSize --- Intercepted size (set to 0 to take the real size of the video)
// completeBlock --- Clipping completed callback (return decoded GIF, cache path, whether cache succeeded)
- (void)cropVideoToGIFFromStartSecond:(NSTimeInterval)startSecond
                             duration:(NSTimeInterval)duration
                                  fps:(float)fps
                                 rate:(float)rate
                          maximumSize:(CGSize)maximumSize
                             cacheURL:(NSURL *)cacheURL
                           errorBlock:(JPImageresizerErrorBlock)errorBlock
                        completeBlock:(JPCropPictureDoneBlock)completeBlock;
```
- PS: The function of cutting the whole video image into circles and masking can not be used. At present, it is only effective for pictures and GIF.

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
// 2.contentInsets：The inner margin between the crop region and the main view.
// 3.duration：Animation Duration (< 0, No animation).
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
UIImage *tileBorderImage = [[UIImage imageNamed:@"jp_dotted_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];

// Set the offset between the border image and the border (CGRectInset, used to adjust the gap between the border image and the border)
self.imageresizerView.borderImageRectInset = CGPointMake(-1.75, -1.75);

// Set the border image (use frameType's borders if it's nil)
self.imageresizerView.borderImage = tileBorderImage;
```

### Switching resizeWHScale
![switch_resizeWHScale](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/switchingresizewhscale.gif)
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

// For more APIs, see the comments on JPImagerestoreview.h
```

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
// Default counterclockwise rotation, rotation angle is 90 degrees
[self.imageresizerView rotation];

// Set the isClockwiseRotation property to YES if clockwise rotation is required
self.imageresizerView.isClockwiseRotation = YES;
```

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

#### 4.Reset with mask imag
```objc
// 4.1 Reset by current mask image
- (void)recoveryByCurrentMaskImage;
- (void)recoveryByCurrentMaskImage:(BOOL)isToBeArbitrarily;

// 4.2 Specify mask image reset
- (void)recoveryToMaskImage:(UIImage *)maskImage isToBeArbitrarily:(BOOL)isToBeArbitrarily;
```

### Preview
```objc
// Preview mode: Hide borders, close drag-and-drop operations, for previewing clipped areas

// 1.Default with animation effect
self.imageresizerView.isPreview = YES;

// 2.Customize whether to with animation effect or not
[self.imageresizerView setIsPreview:YES animated:NO]
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

- PS1：If preserved `savedConfigure.history.viewFrame` If it is inconsistent with the current `viewFrame`, the interface will be disordered, and you need to judge whether it is consistent before reopening;
- PS2：In addition, it can only be saved during the usage of the App, and the persistent cache has not been implemented.

### Other
```objc
// Lock the clipping area. After locking, the clipping area cannot be dragged. NO unlocks the clipping area.
self.imageresizerView.isLockResizeFrame = YES;

// Whether to Adapt the Cutting Area Size when Rotating to Horizontal Direction
// When the width of the picture is smaller than the height of the picture, this property defaults to YES and can be manually set to NO.
self.imageresizerView.isAutoScale = NO;
```

## Install

JPImageresizerView can be installed by [CocoaPods](http://cocoapods.org), just add the following line to your podfile:

```ruby
pod 'JPImageresizerView'
```

## Feedback address

    E-mail: zhoujianping24@hotmail.com
    Blog: https://juejin.im/user/5e55f27bf265da575c16c187
