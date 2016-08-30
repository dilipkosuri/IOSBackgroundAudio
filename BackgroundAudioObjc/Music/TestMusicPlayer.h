
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface TestMusicPlayer : NSObject

//initialize the audio session
+(void) initSession;
-(void) playSongWithId:(NSNumber*)songId songTitle:(NSString*)songTitle artist:(NSString*)artist;
-(void) pause;
-(void) play;
-(void) clear;
-(void) remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;
@end
