# JPCrop

[![Language](http://img.shields.io/badge/language-Swift-brightgreen.svg?style=flat)](https://developer.apple.com/Swift)

![effect](https://github.com/Rogue24/JPCover/raw/master/JPCrop/cover.jpg)

## Example

Tool class with high imitation of cutting function of little red book app.

    高仿小红书App裁剪功能的工具：
        1.集成类似小红书基本的裁剪功能；
        2.API简单易用；
        3.切换裁剪比例时可设置带有动画过渡，不会那么生硬；
        4.可异步可同步裁剪，并且可压缩。
        
![example](https://github.com/Rogue24/JPCover/raw/master/JPCrop/example.gif)

## How to use

Is so easy:

### Initialization
```swift
// 1.Import
import JPCrop

// 2.Initialize
let croper = Croper(frame: croperFrame, configure)

// 3.Add to superview, done!
view.insertSubview(croper, at: 0)
```

### Rotate
```swift
// Default radian range is -45° ~ 45°
croper.updateRadian(radian)

// Show grid before rotating
// animated: with animation or not
croper.showRotateGrid(animated: true)

// Hide grid after rotating
// animated: with animation or not
croper.hideRotateGrid(animated: true)
```

### Switch the crop width to height ratio
```swift
// rotateGridCount: Number of grid in rotation
// animated: with animation or not
croper.updateCropWHRatio(3.0 / 4.0, rotateGridCount: (6, 5), animated: true)
```

### Reset
```swift
// animated: with animation or not
croper.recover(animated: true)
```

### Crop
```swift
let configure = croper.syncConfigure()

// 1.Sync crop
let image = croper.crop() 
cropDone?(image, configure)

// 2.Async crop: crop in DispatchQueue.global, result back to DispatchQueue.main 
croper.asyncCrop {
    guard let image = $0 else { return }
    cropDone(image, configure)
}

// PS: You can set the compressionScale to compress the image
```

### More features will be added in the future...

## Installation

JPCrop is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JPCrop'
```

## Author

Rogue24, zhoujianping24@hotmail.com

## License

JPCrop is available under the MIT license. See the LICENSE file for more info.
