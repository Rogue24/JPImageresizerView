//
//  JPImageresizerVideoObject.m
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerVideoObject.h"

@implementation JPImageresizerVideoObject
{
    BOOL _isFixedOrientation;
}

- (instancetype)initWithAsset:(AVURLAsset *)asset isFixedOrientation:(BOOL)isFixedOrientation {
    if (self = [super init]) {
        _asset = asset;
        _isFixedOrientation = isFixedOrientation;
        
        _seconds = CMTimeGetSeconds(_asset.duration);
        _timescale = _asset.duration.timescale;
        _timeRange = CMTimeRangeMake(kCMTimeZero, _asset.duration);
        _toleranceTime = CMTimeMake(0, _timescale);
        
        AVAssetTrack *videoTrack = [_asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        _frameDuration = CMTimeMakeWithSeconds(1.0 / videoTrack.nominalFrameRate, _timescale);
        _videoSize = videoTrack.naturalSize;
    }
    return self;
}

- (void)dealloc {
    if (_isFixedOrientation) {
        NSURL *tmpURL = self.asset.URL;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
        });
    }
}

@end

@implementation JPPlayerView
+ (Class)layerClass {
    return AVPlayerLayer.class;
}
- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}
- (instancetype)initWithVideoObj:(JPImageresizerVideoObject *)videoObj {
    if (self = [super init]) {
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoObj = videoObj;
    }
    return self;
}
- (void)setVideoObj:(JPImageresizerVideoObject *)videoObj {
    _videoObj = videoObj;
    _item = videoObj ? [AVPlayerItem playerItemWithAsset:videoObj.asset] : nil;
    if (_player) {
        [_player replaceCurrentItemWithPlayerItem:_item];
    } else if (videoObj) {
        _player = [[AVPlayer alloc] initWithPlayerItem:_item];
        _player.rate = 0;
        _player.volume = 0;
        self.playerLayer.player = _player;
    }
}
@end
