//
//  JPTestViewController.m
//  JPImageresizerView_Example
//
//  Created by aa on 2023/10/13.
//  Copyright © 2023 ZhouJianPing. All rights reserved.
//

#import "JPTestViewController.h"
#import "JPConstant.h"
#import <FunnyButton/FunnyButton-Swift.h>

@interface JPTestViewController ()
@property (nonatomic, weak) UIImageView *imgView;
@end

@implementation JPTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 150, 150)];
    imgView.backgroundColor = JPRandomColor;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgView];
    self.imgView = imgView;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [self replaceFunnyActionWithWork:^{
        [weakSelf prep];
    }];
}

- (void)prep {
    
    CGContextRef context1 = nil;
    if (!context1) {
        JPLog(@"context1 0")
    } else {
        JPLog(@"context1 1")
    }
    
    CGContextRef context2 = NULL;
    if (!context2) {
        JPLog(@"context2 0")
    } else {
        JPLog(@"context2 1")
    }
    
    CGImageRef decoded1 = CGBitmapContextCreateImage(context1);
    if (!decoded1) {
        JPLog(@"decoded1 0")
    } else {
        JPLog(@"decoded1 1")
    }
    
    CGImageRef decoded2 = CGBitmapContextCreateImage(context2);
    if (!decoded2) {
        JPLog(@"decoded2 0")
    } else {
        JPLog(@"decoded2 1")
    }
    
    CGImageRef decoded3 = nil;
    if (!decoded3) {
        JPLog(@"decoded3 0")
    } else {
        JPLog(@"decoded3 1")
    }
    
    CGImageRef decoded4 = NULL;
    if (!decoded4) {
        JPLog(@"decoded4 0")
    } else {
        JPLog(@"decoded4 1")
    }
    
    UIImage *image = [UIImage imageWithCGImage:decoded4];
    if (!image) {
        JPLog(@"image 0")
    } else {
        JPLog(@"image 1")
    }
    
//    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
//    if (!source) return nil;
//    
//    size_t count = CGImageSourceGetCount(source);
//    if (count <= 1) {
//        CFRelease(source);
//        return [UIImage imageWithData:data];
//    }
//    
//    NSUInteger frames[count];
//    double oneFrameTime = 1 / 50.0; // 50 fps
//    NSTimeInterval totalTime = 0;
//    NSUInteger totalFrame = 0;
//    NSUInteger gcdFrame = 0;
//    for (size_t i = 0; i < count; i++) {
//        NSTimeInterval delay = JPImageSourceGetGIFFrameDelayAtIndex(source, i);
//        totalTime += delay;
//        NSInteger frame = lrint(delay / oneFrameTime);
//        if (frame < 1) frame = 1;
//        frames[i] = frame;
//        totalFrame += frames[i];
//        if (i == 0) gcdFrame = frames[i];
//        else {
//            NSUInteger frame = frames[i], tmp;
//            if (frame < gcdFrame) {
//                tmp = frame; frame = gcdFrame; gcdFrame = tmp;
//            }
//            while (true) {
//                tmp = frame % gcdFrame;
//                if (tmp == 0) break;
//                frame = gcdFrame;
//                gcdFrame = tmp;
//            }
//        }
//    }
//    NSMutableArray *array = [NSMutableArray new];
//    for (size_t i = 0; i < count; i++) {
//        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
//        if (!imageRef) {
//            CFRelease(source);
//            return nil;
//        }
//        size_t width = CGImageGetWidth(imageRef);
//        size_t height = CGImageGetHeight(imageRef);
//        if (width == 0 || height == 0) {
//            CFRelease(source);
//            CFRelease(imageRef);
//            return nil;
//        }
//        
//        BOOL hasAlpha = JPIsHasAlpha(imageRef);
//        // BGRA8888 (premultiplied) or BGRX8888
//        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
//        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
//        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
//        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
//        CGColorSpaceRelease(space);
//        if (!context) {
//            CFRelease(source);
//            CFRelease(imageRef);
//            return nil;
//        }
//        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
//        CGImageRef decoded = CGBitmapContextCreateImage(context);
}

@end
