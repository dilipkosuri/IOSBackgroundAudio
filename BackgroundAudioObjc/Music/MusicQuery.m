

#import "MusicQuery.h"
@interface MusicQuery()
@end

@implementation MusicQuery

-(void) queryForSongs:(void (^)(NSDictionary* result))completion {
    completion([self songQuery]);
}

-(void)queryForSongWithId:(NSNumber *)songPersistenceId completion:(void(^)(MPMediaItem * item))completion;
{
    MPMediaPropertyPredicate *mediaItemPersistenceIdPredicate =
    [MPMediaPropertyPredicate predicateWithValue: songPersistenceId
                                     forProperty: MPMediaItemPropertyPersistentID];
    
    MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
    [songQuery addFilterPredicate: mediaItemPersistenceIdPredicate];
    
    completion([[songQuery items] lastObject]);
}

#pragma mark - private methods

-(NSDictionary*)songQuery
{
    MPMediaQuery *query = [MPMediaQuery artistsQuery];
    //groups all songs by artist, ordered by song name (across albums)
    NSArray *songsByArtist = [query collections];
    int songCount = 0;
    NSMutableArray *artists = [NSMutableArray array];
    NSMutableDictionary *albumSortingDictionary = [NSMutableDictionary dictionary];
    for (MPMediaItemCollection *album in songsByArtist) {
        NSArray *albumSongs = [album items];
        for (MPMediaItem *songMediumItem in albumSongs) {
            NSString *artistName = [songMediumItem valueForProperty: MPMediaItemPropertyArtist] ? [songMediumItem valueForProperty: MPMediaItemPropertyArtist] : @"";
            NSString *songTitle =  [songMediumItem valueForProperty: MPMediaItemPropertyTitle];
            NSNumber *persistentSongItemId = [songMediumItem valueForProperty:MPMediaItemPropertyPersistentID];
            
            NSString *albumName = [songMediumItem valueForProperty: MPMediaItemPropertyAlbumTitle] ? [songMediumItem valueForProperty: MPMediaItemPropertyAlbumTitle] : @"";
            
            NSDictionary *artistAlbum = albumSortingDictionary[albumName];
            if (!artistAlbum) {
                NSMutableArray *songs = [NSMutableArray array];
                artistAlbum = [NSDictionary dictionaryWithObjects:@[artistName,albumName,songs]
                                                                        forKeys:@[@"artist",@"album", @"songs"]];
                albumSortingDictionary[albumName] =  artistAlbum;
            }
            
            NSDictionary *song = [NSDictionary dictionaryWithObjects:@[songTitle,persistentSongItemId]
                                                             forKeys:@[@"title",@"songId"]];
            [artistAlbum[@"songs"] addObject:song];
            songCount++;
        }
        
        NSArray *albumKeys = [albumSortingDictionary keysSortedByValueUsingComparator:^(id obj1, id obj2) {
            NSDictionary *one = (NSDictionary*)obj1;
            NSDictionary *two = (NSDictionary*)obj2;
            return [one[@"album"] localizedCaseInsensitiveCompare:two[@"album"]];
        }];
        
        for (NSString *albumKey in albumKeys) {
            [artists addObject:albumSortingDictionary[albumKey]];
        }
        
        [albumSortingDictionary removeAllObjects];
    }
    
    return @{@"artists": artists, @"songCount": [NSNumber numberWithInt:songCount]};
}

@end
