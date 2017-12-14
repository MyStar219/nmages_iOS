//
//  VideoPlayer.h
//  negotiator
//
//  Created by aplome on 24/08/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVPlayerItem.h>
#else
#import <MediaPlayer/MediaPlayer.h>
#endif

typedef void(^DidFinishPlayingCompletion)(BOOL isFinished, NSError * _Nullable error);

@interface VideoPlayer : NSObject

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
@property (nonatomic, strong) AVPlayer * _Nonnull avPlayer;
@property (nonatomic, strong) AVPlayerLayer * _Nonnull videoLayer;
#else
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
#endif

//+ (VideoPlayer *)sharedInstance;

+ (void)playVideoWithURL:(NSURL *_Nonnull)videoURL startTime:(NSTimeInterval)startTime completion:(DidFinishPlayingCompletion _Nonnull )completion;
+ (void)playVideo:(NSTimeInterval)startTime completion:(DidFinishPlayingCompletion _Nonnull )completion;
+ (void)stopVideo;

@end
