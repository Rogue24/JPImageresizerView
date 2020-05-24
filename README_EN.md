# JPImageresizerView

[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)

[Jianshu](https://www.jianshu.com/p/5600da5c9bf6)

[Chinese document(中文文档)](https://github.com/Rogue24/JPImageresizerView)

## Brief introduction (Current version: 1.3.8)

Imitation WeChat picture clipping function of a small tool.

    Current functions:
        1. Zooming of area that can be tailored adaptively;
        2. The parameters are set with high degrees of freedom, include spacing of clipping area, cutting aspect ratio, whether to scale adaptively;
        3. Supports up to eight drag and drop direction;
        4. Support rotation;
        5. Support horizontal and vertical mirror flip;
        6. Two border styles;
        7. Supports circular clipping;
        8. Custom gaussian blur style, border color, background color, mask opacity;
        9. Custom border image;
        10. It can dynamically change the spacing between view area and crop area, and supports horizontal and vertical screen switching.

    Trying to update the content:
        1. Swift version;
        2. More new border and mask styles;
        3. More parameter setting;
        4. To achieve the effect of free dragging rotation direction.
        
    Note: Because automatic layout is not conducive to gesture control, frame layout is currently used, and automatic layout is not supported for the time being;

![effect.gif](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/cover.gif)

## How to use

#### Initialization
```objc
// 1. Configure initial parameters (see JPImageresizerConfigure.h for more details)
/**
 * Some configuration parameters:
 * 1.resizeImage: clipping picture
 * 2.blurEffect: gaussian blur style
 * 3.borderImage: custom border image
 * 4.frameType & strokeColor: border style & color
 * 5.bgColor: background color
 * 6.maskAlpha: mask opacity
 * 7.resizeWHScale: width-height ratio of the clipping
 * 8.contentInsets: the inner margin between the crop region and the main view
 */
JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:image make:^(JPImageresizerConfigure *configure) {
    // Now that you have the default parameter values, you can set the parameters you want here (using chain programming)
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

// 2. Create JPImageresizerView instance object
JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:self.configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
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

// Most of the above parameters can also be modified dynamically after creation (except for maskType and contentinsets)
self.imageresizerView.resizeImage = [UIImage imageNamed:@"Kobe.jpg"]; // Change picture (animated by default)
self.imageresizerView.resizeWHScale = 16.0 / 9.0; // Change crop aspect ratio
self.imageresizerView.initialResizeWHScale = 0.0; // The default value is resizeWHScale at initialization. If you call the - recoveryByInitialResizeWHScale method to reset, the value of this property will be reset

// Note: For systems under iOS 11, it is best for the controller to set automaticallyAdjustsScrollViewInsets to NO
// Otherwise, imagesizerView will be offset with the change of navigationBar or statusBar
if (@available(iOS 11.0, *)) {

} else {
    self.automaticallyAdjustsScrollViewInsets = NO;
}
```

#### 横竖屏切换
![screenswitching](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/screenswitching.gif)
```objc
// This method is called to refresh when the user needs to listen to the horizontal and vertical screen switching or manually switch by himself
// 1.updateFrame: Refresh frame (e.g. horizontal and vertical screen switching, incoming self.view.bounds Just).
// 2.contentInsets：The inner margin between the crop region and the main view.
// 3.duration：Animation Duration (< 0, No animation).
//【Specific operation can refer to Demo】
[self.imageresizerView updateFrame:self.view.bounds contentInsets:contentInsets duration:duration];
```

#### Change border style
![concise](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPConciseFrameTypeCover.jpeg)
![classic](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPClassicFrameTypeCover.jpeg)
```objc
// Only two border styles are available, concise style(JPConciseFrameType) and classic style(JPClassicFrameTypeCurrently).
// You can modify the border style by initializing or directly setting frameType properties
self.imageresizerView.frameType = JPClassicFrameType;
```

#### Custom Border Image
![stretch_mode](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPCustomBorderImage1.jpg)
![tile_mode](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/JPCustomBorderImage2.jpg)
```objc
// Use custom border pictures (example: tile mode)
UIImage *tileBorderImage = [[UIImage imageNamed:@"jp_dotted_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) resizingMode:UIImageResizingModeTile];

// Set the offset between the border image and the border (CGRectInset, used to adjust the gap between the border image and the border)
self.imageresizerView.borderImageRectInset = CGPointMake(-1.75, -1.75);

// Set the border image (use frameType's borders if it's nil)
self.imageresizerView.borderImage = tileBorderImage;
```

#### Switching resizeWHScale
![switch resizeWHScale](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/ivpFV94K5W.gif)
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

#### Round Resize
![round_resize](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/roundresize.jpg)
```objc
// Set circle cut
// After setting, the resizeWHScale is 1:1, the radius is half of the width and height, and the top, left, bottom and right middle of the border can be dragged.
[self.imageresizerView roundResize:YES];

// Reduced rectangle
// Just set resizeWHScale to any value
self.imageresizerView.resizeWHScale = 0.0;
```

#### Custom gaussian blur style, border color, background color, mask opacity
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

#### Mirror reversal
![mirror.gif](https://github.com/Rogue24/JPImageresizerView/raw/master/Cover/ggseHhuRnt.gif)
```objc
// Vertical Mirror, YES -> Rotates 180 degrees along Y axis, NO -> Reduction
BOOL isVerticalityMirror = !self.imageresizerView.verticalityMirror;
[self.imageresizerView setVerticalityMirror:isVerticalityMirror animated:YES];

// Horizontal Mirror, YES -> Rotates 180 Degrees along X-axis, NO -> Reduction
BOOL isHorizontalMirror = !self.imageresizerView.horizontalMirror;
[self.imageresizerView setHorizontalMirror:isHorizontalMirror animated:YES];
```

#### Rotate
```objc
// Default counterclockwise rotation, rotation angle is 90 degrees
[self.imageresizerView rotation];

// Set the isClockwiseRotation property to YES if clockwise rotation is required
self.imageresizerView.isClockwiseRotation = YES;
```

#### Reset
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
[self.imageresizerView recoveryByTargetResizeWHScale:imageresizeWHScale isToBeArbitrarily:isToBeArbitrarily];
```

#### Preview
```objc
// Preview mode: Hide borders, close drag-and-drop operations, for previewing clipped areas

// 1.Default with animation effect
self.imageresizerView.isPreview = YES;

// 2.Customize whether to with animation effect or not
[self.imageresizerView setIsPreview:YES animated:NO]
```

#### Tailoring
```objc
// The clipping process is executed in the sub-thread, and the callback is cut back to the main thread for execution.
// If it is a HD image, HUD prompt can be added before calling.
// compressScale(0.0 ~ 1.0): If it is greater than or equal to 1.0, clip it according to the size of the original drawing, and return it to nil if it is less than or equal to 0.0.
// example: compressScale = 0.5, 1000 x 500 --> 500 x 250

// 1.Custom Compression scale for Tailoring
[self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
    // When the clipping is completed, resizeImage is the clipped image.
    // Pay attention to circular references
} compressScale:0.7]; // example: Compressed to 70% of the original size.

// 2.Tailoring with original size
[self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
    // When the clipping is completed, resizeImage is the clipped image.
    // Pay attention to circular references
}];
```

#### Other
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
    Blog: https://www.jianshu.com/u/2edfbadd451c
