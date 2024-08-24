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
        _seconds = CMTimeGetSeconds(asset.duration);
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        _videoSize = videoTrack.naturalSize;
    }
    return self;
}

- (CMTimeScale)timescale {
    return _asset.duration.timescale;
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
