# JPImageresizerView

[![CI Status](http://img.shields.io/travis/ZhouJianPing/JPImageresizerView.svg?style=flat)](https://travis-ci.org/ZhouJianPing/JPImageresizerView)
[![Version](https://img.shields.io/cocoapods/v/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![License](https://img.shields.io/cocoapods/l/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)
[![Platform](https://img.shields.io/cocoapods/p/JPImageresizerView.svg?style=flat)](http://cocoapods.org/pods/JPImageresizerView)

## 简介
仿微信裁剪图片的一个小框架，自适应裁剪区域的缩放，高自由度的参数设定，目前支持最多8个方向进行拖拽和4个方向的旋转。以后会更新Swift版本，并陆续添加别的样式和实现苹果系统的裁剪中的自由拖拽控制方向效果。

## 如何使用

#### 初始化
// 使用工厂方法配置参数（frame、图片、裁剪线颜色、背景色、遮罩透明度、垂直和水平的间距、裁剪的宽高比，可否重置的回调）
JPImageresizerView *imageresizerView = [[JPImageresizerView alloc]
initWithFrame:frame
resizeImage:[UIImage imageNamed:@"Girl.jpg"]
strokeColor:[UIColor whiteColor]
bgColor:[UIColor blackColor]
maskAlpha:0.75
verBaseMargin:10
horBaseMargin:10
resizeWHScale:0
imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
// 可在这里监听到是否可以重置
// 注意循环引用
}];
[self.view addSubview:imageresizerView];
self.imageresizerView = imageresizerView;

// 创建后也可以随意修改以上参数
self.imageresizerView.resizeImage = [UIImage imageNamed:@"Kobe.jpg"];
self.imageresizerView.resizeWHScale = 16.0 / 9.0;

#### 旋转
// 默认逆时针旋转，旋转角度为90°
[self.imageresizerView rotation];

// 若需要顺时针旋转可设置isClockwiseRotation属性为YES
self.imageresizerView.isClockwiseRotation = YES;

#### 重置
// 重置为初始状态，方向垂直向上
[self.imageresizerView recovery];

#### 裁剪
// 裁剪过程是在子线程中执行，回调则切回主线程执行
// 调用可添加提示...
[self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
// 裁剪完成，resizeImage为裁剪后的图片
// 注意循环引用
}];

## 安装

JPImageresizerView 可通过[CocoaPods](http://cocoapods.org)安装，只需添加下面一行到你的podfile：

```ruby
pod 'JPImageresizerView'
```

## 反馈地址

邮箱：zhoujianping24@hotmail.com
博客：https://www.jianshu.com/u/2edfbadd451c

## License

JPImageresizerView is available under the MIT license. See the LICENSE file for more info.
