

#import "TestMusicPlayer.h"
#import "MusicQuery.h"
#import <AVFoundation/AVFoundation.h>

@interface TestMusicPlayer()
@property(nonatomic,strong) AVQueuePlayer *avQueuePlayer;
@end

@implementation TestMusicPlayer
+(void)initSession
{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:    @selector(audioSessionInterrupted:)
                                                 name:        AVAudioSessionInterruptionNotification
                                               object:      [AVAudioSession sharedInstance]]; 

    
    //set audio category with options - for this demo we'll do playback only
    NSError *categoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&categoryError];
    
    if (categoryError) {
        NSLog(@"Error setting category! %@", [categoryError description]);
    }
    
    //activation of audio session
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!success) {
        if (activationError) {
            NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
        } else {
            NSLog(@"audio session could not be activated!");
        }
    }
    
}

-(AVPlayer *)avQueuePlayer
{
    if (!_avQueuePlayer) {
        _avQueuePlayer = [[AVQueuePlayer alloc]init];
    }
    
    return _avQueuePlayer;
}

-(void) playSongWithId:(NSNumber*)songId songTitle:(NSString*)songTitle artist:(NSString*)artist
{
    [[MusicQuery new] queryForSongWithId:songId completion:^(MPMediaItem *item) {
        if (item) {
            NSURL *assetUrl = [item valueForProperty: MPMediaItemPropertyAssetURL];
            AVPlayerItem *avSongItem = [[AVPlayerItem alloc] initWithURL:assetUrl];
            if (avSongItem) {
                [[self avQueuePlayer] insertItem:avSongItem afterItem:nil];
                [self play];
                [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{MPMediaItemPropertyTitle: songTitle, MPMediaItemPropertyArtist: artist};

            }
        }
    }];
}

#pragma mark - notifications
-(void)audioSessionInterrupted:(NSNotification*)interruptionNotification
{
    NSLog(@"interruption received: %@", interruptionNotification);
}

#pragma mark - player actions
-(void) pause
{
    [[self avQueuePlayer] pause];
}

-(void) play
{
    [[self avQueuePlayer] play];
}


-(void) clear
{
    [[self avQueuePlayer] removeAllItems];
}

#pragma mark - remote control events
     
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    NSLog(@"received event!");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                if ([self avQueuePlayer].rate > 0.0) {
                    [[self avQueuePlayer] pause];
                } else {
                    [[self avQueuePlayer] play];
                }

                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                [[self avQueuePlayer] play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [[self avQueuePlayer] pause];
                break;
            }
            default:
                break;
        }
    }
}

@end
