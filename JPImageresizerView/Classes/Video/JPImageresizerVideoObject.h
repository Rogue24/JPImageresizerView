//
//  JPImageresizerVideoObject.h
//  JPImageresizerView
//
//  Created by 周健平 on 2020/7/4.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface JPImageresizerVideoObject : NSObject
- (instancetype)initWithAsset:(AVURLAsset *)asset isFixedOrientation:(BOOL)isFixedOrientation;
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, assign, readonly) NSTimeInterval seconds;
@property (nonatomic, assign, readonly) CMTimeScale timescale;
@property (nonatomic, assign, readonly) CMTimeRange timeRange;
@property (nonatomic, assign, readonly) CMTime toleranceTime;
@property (nonatomic, assign, readonly) CMTime frameDuration;
@property (nonatomic, assign, readonly) CGSize videoSize;
@end

@interface JPPlayerView : UIView
- (instancetype)initWithVideoObj:(JPImageresizerVideoObject *)videoObj;
- (AVPlayerLayer *)playerLayer;
@property (nonatomic, weak) JPImageresizerVideoObject *videoObj;
@property (nonatomic, strong, readonly) AVPlayerItem *item;
@property (nonatomic, strong, readonly) AVPlayer *player;
@end
