//
//  itunescontrol.h
//  iTunesRemote-Server
//
//  Created by Marinus Oosters on 5-1-07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  This class interfaces with iTunes

#import <Cocoa/Cocoa.h>


@interface itunescontrol : NSObject {
    // keep the values in arrays so we won't have to get them from iTunes every time
    NSArray *playlists, *titles, *durations, *ratings, *artists, *times_played;
    int volume;
 
}

- (NSArray*) getPlaylists;
- (NSArray*) getTitles;
- (NSArray*) getDurations;
- (NSArray*) getRatings;
- (NSArray*) getTimesPlayed;
- (NSArray*) getArtists;
- (int) getVolume;

- (void)previous;
- (void)next;
- (void)rewind;
- (void)ffwd;
- (void)normalspeed;
- (void)stop;
- (void)playpause;
- (void)setVolume: (int)vol;
- (void)setPlaylist: (int)playlistn;
- (void)setPlaylistByName: (NSString*)playlist; /* do not use! buggy & only for backwards compatibility! */
- (void)update;
- (void)library;
- (void)playSong: (int)trackNo;

@end


