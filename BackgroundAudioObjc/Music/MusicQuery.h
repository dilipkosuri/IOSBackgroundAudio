

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicQuery : NSObject

/**
 *  Query for songs
 *  @param completion completion block with result as an NSDictionary
 */
-(void) queryForSongs:(void (^)(NSDictionary* result))completion;

/**
 *  Query for a song
 *
 *  @param songPersistenceId unique identifier for the song
 *  @param completion        completion block with MPMediaItem
 */
-(void)queryForSongWithId:(NSNumber *)songPersistenceId completion:(void(^)(MPMediaItem * item))completion;

@end
