//
//  VideoPlayer.m
//  negotiator
//
//  Created by aplome on 24/08/2017.
//
//

#import "VideoPlayer.h"

static VideoPlayer *kVideoPlayer;

@interface VideoPlayer()

@property (strong, nonatomic) DidFinishPlayingCompletion completion;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) BOOL videoLoaded;

@end

@implementation VideoPlayer

+ (VideoPlayer *)sharedInstance {
    
    
    if (nil == kVideoPlayer) {
        kVideoPlayer = [[VideoPlayer alloc] init];
    }
    
    return kVideoPlayer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)playVideoWithURL:(NSURL *)videoURL startTime:(NSTimeInterval)startTime completion:(DidFinishPlayingCompletion)completion {

    self.startTime = startTime;
    self.videoLoaded = NO;
    self.completion = completion;

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    
    self.avPlayer = [AVPlayer playerWithURL:videoURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [self.avPlayer seekToTime:CMTimeMake(self.startTime, 1)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
    
    
    
    self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    
    CGRect windowFrame = [UIApplication.mainWindow bounds];
    self.videoLayer.frame = CGRectMake(0, 20, windowFrame.size.width, windowFrame.size.height - 20);
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [UIApplication.mainWindow.layer addSublayer:self.videoLayer];
    
    [self.avPlayer play];

#else
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    self.moviePlayer.view.frame = [UIApplication.mainWindow bounds];
    self.moviePlayer.view.backgroundColor = [UIColor clearColor];
    self.moviePlayer.shouldAutoplay = YES;
    self.moviePlayer.fullscreen = YES;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    

    [self.moviePlayer play];
    [UIApplication.mainWindow addSubview:[self.moviePlayer view]];
    [UIApplication.mainWindow bringSubviewToFront:[self.moviePlayer view]];
#endif
    
    
    UIView *mask = [[UIView alloc]initWithFrame:[UIApplication.mainWindow bounds]];
    [mask setBackgroundColor:[UIColor clearColor]];
    [mask setTag:-999];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedGestureHandle:)];
    [tapGesture setNumberOfTouchesRequired:1];
    [mask addGestureRecognizer:tapGesture];
    
    [UIApplication.mainWindow addSubview:mask];
    [UIApplication.mainWindow bringSubviewToFront:mask];
    
}

+ (void)playVideoWithURL:(NSURL *)videoURL startTime:(NSTimeInterval)startTime completion:(DidFinishPlayingCompletion)completion {
    
    [[VideoPlayer sharedInstance] playVideoWithURL:videoURL startTime:startTime completion:completion];
}

+ (void)playVideo:(NSTimeInterval)startTime completion:(DidFinishPlayingCompletion)completion {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"nego" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:path];
    
    [VideoPlayer playVideoWithURL:movieURL startTime:startTime completion:completion];
}

+ (void)stopVideo {
    
    [[VideoPlayer sharedInstance] stopVideo];
}

- (void)stopVideo {

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    
    [self itemDidFinishPlaying:nil];
#else
    
    [self moviePlayBackDidFinish:nil];
    
#endif
    
}

- (void)dealloc {
    [super dealloc];
}

-(void)tappedGestureHandle:(UITapGestureRecognizer *)gesture
{
    
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Skip Video?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Skip" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self itemDidFinishPlaying:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    
    [alertController addAction:okayAction];
    [alertController addAction:cancelAction];
    
    [alertController show];
    
#else
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:@"Skip Video?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Skip", nil];
    [av setTag:-655];
    [av show];
#endif
}

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
#else
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == -655)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            
            [VideoPlayer stopVideo];
            
        }
    }
}
#endif

#pragma mark - notification

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (void)itemDidFinishPlaying:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self.avPlayer pause];
    [self.avPlayer seekToTime:CMTimeMake(0, 1)];
    [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    
    [self.videoLayer removeFromSuperlayer];

    [self removeAndCallCompletionHandler:YES];
}
#else
-(void)moviePlayBackDidFinish:(NSNotification *)param
{
    [self.moviePlayer stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.moviePlayer.view removeFromSuperview];
    
    [self removeAndCallCompletionHandler:YES];
    
}

- (void)movieLoadStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerController *player = notification.object;
    MPMovieLoadState loadState = player.loadState;
    
    /* Enough data has been buffered for playback to continue uninterrupted. */
    if (loadState & MPMovieLoadStatePlaythroughOK)
    {
        //should be called only once , so using self.videoLoaded - only for  first time  movie loaded , if required. This function wil be called multiple times after stalled
        if(!self.videoLoaded)
        {
            self.moviePlayer.currentPlaybackTime = self.startTime;
            self.videoLoaded = YES;
        }
    }
}
#endif

- (void)removeAndCallCompletionHandler:(BOOL)isFinished {

    [[UIApplication.mainWindow viewWithTag:-999] removeFromSuperview];
    //movie finished, lets see where we were
    
    self.completion(isFinished, nil);
}

@end
