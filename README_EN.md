# JPImageresizerView

[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Language](http://img.shields.io/badge/language-ObjC-brightgreen.svg?style=flat)](https://developer.apple.com/Objective-C)

[Juejin](https://juejin.im/post/5ecd0cddf265da7711699e0d)

[Chinese document(中文文档)](https://github.com/Rogue24/JPImageresizerView)

*本人英语小白，这里基本都是用百度翻译出来的，Sorry。*

## Brief introduction (Current version: 1.7.0)

A wheel specially designed for cutting pictures and videos is easy to use and has rich functions (high degree of freedom parameter setting, supporting rotation and mirror flipping, multiple style selection, etc.), which can meet the needs of most pictures and videos cutting.

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
        ✅ Can crop GIF.

    What I'm trying to achieve:
        ☑️ Swift version;
        ☑️ Crop remote video;
        ☑️ To achieve the effect of free drag rotation and flip angle.
        
    Note: Because automatic layout is not conducive to gesture control, frame layout is currently used, and automatic layout is not supported for the time being.

## How to use

### Initialization
```objc
// 1. Configure initial parameters (see JPImageresizerView.h for more details)
/**
 * Notes to some configurable parameters:
    - image: Cropped image / GIF (passed in as UIImage)
    - imageData: Cropped image / GIF (passed in as NSData)
    - videoURL: Cropped video URL (local)
    - blurEffect: gaussian blur style
    - borderImage: custom border image
    - frameType & strokeColor: border style & color
    - bgColor: background color
    - maskAlpha: mask opacity
    - resizeWHScale: width-height ratio of the clipping
    - contentInsets: the inner margin between the crop region and the main view
    - maskImage: customize the mask image
 */
// 1.1 Cropped image / GIF as UIImage
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

// 1.2 Cropped image / GIF as NSData
JPImageresizerConfigure *configure = [JPImageresize
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithImageData:imageData make:^(JPImageresizerConfigure *configure) { ...... };

// 1.3 Video is passed in as NSURL
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithVideoURL:videoURL make:^(JPImageresizerConfigure *configure) { ...... }];

// PS: Only one clip video or picture or GIF can be selected at the same time.

// 2. Create JPImageresizerView instance object
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

// 3. Add to view
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
        2.compressScale: Image and GIF compression ratio, greater than or equal to 1, according to the size of the original image, less than or equal to 0, return nil (Example: compressScale = 0.5，1000 x 500 --> 500 x 250);
        3.cacheURL: The cache path can be set to nil, while the images and GIF will not be cached. The video will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4;
        4.JPCropErrorReason: Cause of error
            - JPCEReason_NilObject: The clipping element is empty
            - JPCEReason_CacheURLAlreadyExists: Another file already exists for the cache path
            - JPCEReason_NoSupportedFileType: Unsupported file type
            - JPCEReason_VideoAlreadyDamage: The video file is corrupted
            - JPCEReason_VideoExportFailed: Video export failed
            - JPCEReason_VideoExportCancelled: Video export cancelled
    
#### Crop image
```objc
// 1.Cut to original size
[self.imageresizerView cropPictureWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPCropErrorReason reason) {
    // error callback
    // reason: JPCropErrorReason
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
                          errorBlock:(JPCropErrorBlock)errorBlock
                       completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

#### Crop GIF
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgif.gif)
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropgifdone.gif)
```objc
// 1.Original size clipping GIF
[self.imageresizerView cropGIFWithCacheURL:cacheURL errorBlock:^(NSURL *cacheURL, JPCropErrorReason reason) {
    // error callback
    // reason: JPCropErrorReason
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
                      errorBlock:(JPCropErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.Custom crop GIF
// isReverseOrder --- Inverted or not
// completeBlock --- Clipping completed callback (return decoded GIF, cache path, whether cache succeeded)
- (void)cropGIFWithCompressScale:(CGFloat)compressScale
                  isReverseOrder:(BOOL)isReverseOrder
                            rate:(float)rate
                        cacheURL:(NSURL *)cacheURL
                      errorBlock:(JPCropErrorBlock)errorBlock
                   completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

**Crop one of the GIF frames**
```objc
// 1.The size of the original image cuts the current frame of GIF
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropGIFCurrentIndexWithCacheURL:(NSURL *)cacheURL
                             errorBlock:(JPCropErrorBlock)errorBlock
                          completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.Customize the compression ratio to crop the current frame of GIF
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropGIFCurrentIndexWithCompressScale:(CGFloat)compressScale
                                    cacheURL:(NSURL *)cacheURL
                                  errorBlock:(JPCropErrorBlock)errorBlock
                               completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.Custom compression ratio clipping GIF specified frame
// index --- What frame
- (void)cropGIFWithIndex:(NSUInteger)index
           compressScale:(CGFloat)compressScale
                cacheURL:(NSURL *)cacheURL
              errorBlock:(JPCropErrorBlock)errorBlock
           completeBlock:(JPCropPictureDoneBlock)completeBlock;
```
PS: You can set isLoopPlaybackGIF to choose which frame to crop (the default is NO, if YES is set, GIF will be played automatically)
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/noloopplaybackgif.gif)
```objc
self.imageresizerView.isLoopPlaybackGIF = NO;
```
#### Crop local video
![mask](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideo.gif)
PS: At present, it is only for local video, and remote video is not suitable for the moment.
```objc
// Clip the entire video
// cacheURL: If it is nil, it will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4
[self.imageresizerView cropVideoWithCacheURL:cacheURL progressBlock:^(float progress) {
    // Monitor progress
    // progress：0~1
    // Pay attention to circular references
} errorBlock:^(NSURL *cacheURL, JPCropErrorReason reason) {
    // error callback
    // reason: JPCropErrorReason
    // Pay attention to circular references
} completeBlock:^(NSURL *cacheURL) {
    // Tailoring complete
    // cacheURL: If the cacheurl is set to nil, it will be cached in the NSTemporaryDirectory folder of the system by default. The video name is the current timestamp, and the format is MP4
    // Pay attention to circular references
}];

// Video export quality can be set
// presetName --- The video export quality of the system, such as: AVAssetExportPresetLowQuality，AVAssetExportPresetMediumQuality，AVAssetExportPresetHighestQuality, etc
- (void)cropVideoWithPresetName:(NSString *)presetName
                       cacheURL:(NSURL *)cacheURL
                 progressBlock:(JPCropVideoProgressBlock)progressBlock
                    errorBlock:(JPCropErrorBlock)errorBlock
                 completeBlock:(JPCropVideoCompleteBlock)completeBlock;

// Cancel video export
// When the video is being exported, the call can cancel the export and trigger the errorblock callback (JPCEReason_ExportCancelled)
- (void)videoCancelExport;
```
PS: Since the width and height of the video must be an integer multiple of 16, otherwise the system will automatically correct the size after export, and the insufficient areas will be filled in the form of green edge. Therefore, I modified the clipping size by division of 16 in the method. Therefore, the width to height ratio of the exported video may be slightly different from the specified width height ratio.

**Clip one frame of the video**
```ojbc
// 1.The size of the original image cuts the current frame of the video
// cacheURL --- Cache path (can be set to nil, it will not be cached)
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropVideoCurrentFrameWithCacheURL:(NSURL *)cacheURL
                               errorBlock:(JPCropErrorBlock)errorBlock
                            completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 2.Clipping the current frame of video with custom compression ratio
// cacheURL --- Cache path (can be set to nil, it will not be cached)
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropVideoCurrentFrameWithCompressScale:(CGFloat)compressScale
                                      cacheURL:(NSURL *)cacheURL
                                    errorBlock:(JPCropErrorBlock)errorBlock
                                 completeBlock:(JPCropPictureDoneBlock)completeBlock;

// 3.Custom compression ratio clipping video frame
// second --- Second screen
// cacheURL --- Cache path (can be set to nil, it will not be cached)
// completeBlock --- Clipping completed callback (return decoded image, cache path, whether cache succeeded)
- (void)cropVideoOneFrameWithSecond:(float)second
                      compressScale:(CGFloat)compressScale
                           cacheURL:(NSURL *)cacheURL
                         errorBlock:(JPCropErrorBlock)errorBlock
                      completeBlock:(JPCropPictureDoneBlock)completeBlock;
```

**Cut a video segment and transfer it to GIF**
![](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/cropvideotogif.gif)
```objc
// 1.Video from the current time to capture a specified number of seconds screen to GIF (fps = 10，rate = 1，maximumSize = 500 * 500)
// duration --- How many seconds are intercepted
// completeBlock --- Clipping completed callback (return decoded GIF, cache path, whether cache succeeded)
- (void)cropVideoToGIFFromCurrentSecondWithDuration:(NSTimeInterval)duration
                                           cacheURL:(NSURL *)cacheURL
                                         errorBlock:(JPCropErrorBlock)errorBlock
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
                           errorBlock:(JPCropErrorBlock)errorBlock
                        completeBlock:(JPCropPictureDoneBlock)completeBlock;
```
PS: The function of cutting the whole video image into circles and masking can not be used. At present, it is only effective for pictures and GIF.

### Customize the mask image clipping
![mask](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/mask.gif)
```objc
// Set mask picture (currently only PNG picture is supported)
self.imageresizerView.maskImage = [UIImage imageNamed:@"love.png"];

// Remove mask image
self.imageresizerView.maskImage = nil;

// You can set whether the mask image can be dragged at any scale
self.imageresizerView.isArbitrarilyMask = YES;
```
![maskdone](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/maskdone.png)
PS: If the mask image is used, the PNG image is finally cropped out, so the cropped size may be larger than the original image.

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
// The latest resizeWHScale is saved after the default switch, and it has its own animation effect, which is equivalent to:
[self.imageresizerView setResizeWHScale:1.0 isToBeArbitrarily:NO animated:YES];
```

### Round Resize
![round_resize](https://github.com/Rogue24/JPCover/raw/master/JPImageresizerView/roundresize.jpg)
```objc
// Set circle cut
// After setting, the resizeWHScale is 1:1, the radius is half of the width and height, and the top, left, bottom and right middle of the border can be dragged.
[self.imageresizerView roundResize:YES];

// Reduced rectangle
// Just set resizeWHScale to any value
self.imageresizerView.resizeWHScale = 0.0;
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
```objc
// Reset to the initial state, vertical direction, can be reset to different resizeWHScale

// 1.Reset by currently resizeWHScale
/**
 * With this method, the width-height ratio of the clipping box is reset according to the current resizeWHScale value.
 */
[self.imageresizerView recoveryByCurrentResizeWHScale];

// isToBeArbitrarily: Is resizeWHScale in any proportion after reset (if YES, last resizeWHScale = 0)
BOOL isToBeArbitrarily = self.isToBeArbitrarily;   

// 2.Reset by initialResizeWHScale
/**
 * initialResizeWHScale defaults to resizeWHScale at initialization, after which it can modify the value of initialResizeWHScale itself.
 * With this method, the width-height ratio of the clipping box is reset according to the initialResizeWHScale value.
 * If isToBeArbitrarily is NO, resizeWHScale = initialResizeWHScale after reset.
 */
[self.imageresizerView recoveryByInitialResizeWHScale:isToBeArbitrarily];
    
// 3.Reset by targetResizeWHScale
/**
 * With this method, the width-to-height ratio of the clipping frame is reset according to the targetResizeWHScale.
 * If isToBeArbitrarily is NO, resizeWHScale = targetResizeWHScale after reset.
 */
CGFloat imageresizeWHScale = self.imageresizerView.imageresizeWHScale; // Gets the aspect ratio of the current clipping box
[self.imageresizerView recoveryToTargetResizeWHScale:imageresizeWHScale isToBeArbitrarily:isToBeArbitrarily];

// 4.Reset rounding status
/**
 * Use this method to reset and return to the original state in circular cutting state
 * After reset: resizeWHScale = 1
 */
[self.imageresizerView recoveryToRoundResize];

// 5.Reset with mask image
/**
 * Use this method to reset and take the aspect ratio of the mask image as the clipping aspect ratio to return to the original state
 * After reset: resizeWHScale = maskImage.size.width / maskImage.size.height
 */
[self.imageresizerView recoveryByCurrentMaskImage]; // Use the current mask image
[self.imageresizerView recoveryToMaskImage:[UIImage imageNamed:@"love.png"]]; // Specify mask image
```

### Preview
```objc
// Preview mode: Hide borders, close drag-and-drop operations, for previewing clipped areas

// 1.Default with animation effect
self.imageresizerView.isPreview = YES;

// 2.Customize whether to with animation effect or not
[self.imageresizerView setIsPreview:YES animated:NO]
```

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
