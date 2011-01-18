//
//  itunescontrol.m
//  iTunesRemote-Server
//
//  This class interfaces with iTunes.

#import "itunescontrol.h"

#define OSASCRIPT @"/usr/bin/osascript"

// AppleScript codes

#define AS_TELL \
  @"tell application \"iTunes\"\n" \
   "set the text item delimiters of applescript to \"\\n\"\n" \
   "%@\n" \
   "end tell" 
   
#define AS_GET \
  @"tell application \"iTunes\"\n" \
   "set the text item delimiters of applescript to \"\\n\"\n" \
   "get %@ of tracks of view of browser window 1 as string\n" \
   "end tell"


@implementation itunescontrol

- (id)init {
    [super init];
    // init everything to nil
    playlists=nil;
    titles=nil;
    durations=nil;
    ratings=nil;
    artists=nil;
    times_played=nil;
    volume=nil;
    // get initial values
    [self update];
    return self;
}

// This function will execute a command and return its output.
- (NSString*)runCommand: (NSString*)command withArguments:(NSArray*)args {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    NSData *inData;
    NSString *tempString;
    [task setCurrentDirectoryPath:NSHomeDirectory()];
    [task setLaunchPath:command];
    [task setArguments:args];
    [task setStandardOutput:newPipe];
    [task setStandardError:newPipe];
    [task launch];
    inData = [readHandle readDataToEndOfFile];
    tempString = [[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding];
    [task release];
    //[tempString autorelease];
    return tempString;
}

// This function will update the contents of the variables to match iTunes' data.
- (void)update {
    NSAutoreleasePool *apool;
    apool =  [[NSAutoreleasePool alloc] init];
    
    // remove previous ones first, if possible
    if (playlists!=nil) { // if one is initialised, all are.
        [playlists release];
        [titles release];
        [durations release];
        [ratings release];
        [artists release];
        [times_played release];
    }
 
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject: @"-e"]; // for osascript
 
    /* Note that I'm using \n as a separator now. Let's see you put THAT one in a song name! */
 
    // playlists
    [temp addObject:[[NSString alloc] initWithFormat:AS_TELL, @"get name of every user playlist as string"]];
    playlists = [[[self runCommand:OSASCRIPT withArguments:temp] componentsSeparatedByString:@"\n"] retain];
    [temp removeLastObject];
 
    // titles
    [temp addObject:[[NSString alloc] initWithFormat:AS_GET, @"name"]];
    titles = [[[self runCommand:OSASCRIPT withArguments:temp] componentsSeparatedByString:@"\n"] retain];
    [temp removeLastObject];
 
    // durations
    [temp addObject:[[NSString alloc] initWithFormat:AS_GET,@"time"]];
    durations = [[[self runCommand:OSASCRIPT withArguments:temp] componentsSeparatedByString:@"\n"] retain];
    [temp removeLastObject];
 
    // ratings
    [temp addObject:[[NSString alloc] initWithFormat:AS_GET,@"rating"]];
    ratings = [[[self runCommand:OSASCRIPT withArguments:temp] componentsSeparatedByString:@"\n"] retain];
    [temp removeLastObject];
 
    // artists
    [temp addObject:[[NSString alloc] initWithFormat:AS_GET,@"artist"]];
    artists = [[[self runCommand:OSASCRIPT withArguments:temp] componentsSeparatedByString:@"\n"] retain];
    [temp removeLastObject];
 
    // times played
    [temp addObject:[[NSString alloc] initWithFormat:AS_GET,@"played count"]];
    times_played = [[[self runCommand:OSASCRIPT withArguments:temp] componentsSeparatedByString:@"\n"] retain];
    [temp removeLastObject];
 
    // volume
    [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"sound volume"]];
    volume = [[self runCommand:OSASCRIPT withArguments:temp] intValue];
    [temp removeLastObject];
 
   // [apool release];
    
}

// send values

- (NSArray*)getPlaylists {return playlists;}
- (NSArray*)getTitles {return titles;}
- (NSArray*)getDurations {return durations;}
- (NSArray*)getRatings {return ratings;}
- (NSArray*)getTimesPlayed {return times_played;}
- (NSArray*)getArtists {return artists;}

- (int)getVolume {return volume;}

// do stuff

#define VOLUME 1
#define PLAYLIST 2
#define PLAYSONG 3

#define PREV 1
#define NEXT 2
#define REW 3
#define FFWD 4
#define NORMAL 5
#define STOP 6
#define PPAU 7
#define LIB 8

// argumentless actions
- (void)action:(int)a {
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:@"-e"];
 

    switch(a) {
        case PREV: [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"back track"]];break;
        case NEXT: [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"next track"]];break;
        case REW: [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"rewind"]];break;
        case FFWD: [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"fast forward"]];break;
        case NORMAL: [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"resume"]];break;
        case STOP: [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"stop"]];break;
        case PPAU: [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"playpause"]];break;
        case LIB: 
            
            // Apple decided with iTunes 7.1 to break all previously existing scripts and introduce a new way to refer to
            // the library playlist. So now, we have to do two different things depending on which version of iTunes we're
            // controlling.
            
          //  [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,@"set view of front browser window to library playlist 1"]];
            
            [temp addObject:[[NSString alloc] initWithString:
                @" tell application \"iTunes\"                                                    \n\
                       if (get version) as string < \"7.1\" then                                  \n\
                           set Master_Playlist to library playlist 1                              \n\
                       else                                                                       \n\
                           set Master_Playlist to first playlist whose special kind is Music      \n\
                       end if                                                                     \n\
                       set view of browser window 1 to Master_Playlist                            \n\
                   end tell                                                                       \n\
                 "]]; 
            
            break;
    }
 
    [self runCommand:OSASCRIPT withArguments:temp];
}

// number-argument actions

- (void)action:(int)a withInt:(int)b {
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:@"-e"];
   
    switch(a) {
        case VOLUME:
            [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,
                            [NSString stringWithFormat:@"set sound volume to %d",b]]];
            break;
        case PLAYLIST:
            [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,
                            [NSString stringWithFormat:
                            @"set view of front browser window to user playlist (get name of user playlist %d as string)"
                            ,b]]];
            break;
        case PLAYSONG:
            [temp addObject:[[NSString alloc] initWithFormat:AS_TELL,
                            [NSString stringWithFormat:@"play track %d of view of browser window 1", b]]];
            break;
    }
 
    [self runCommand:OSASCRIPT withArguments:temp];
}

// methods

- (void)previous { [self action:PREV]; }
- (void)next { [self action:NEXT]; }
- (void)rewind { [self action:REW]; }
- (void)ffwd { [self action:FFWD]; }
- (void)normalspeed { [self action:NORMAL]; }
- (void)stop { [self action:STOP]; }
- (void)playpause { [self action:PPAU]; }
- (void)library {
    [self action:LIB];
    [self update];
}

- (void)playSong:(int)trackNo { [self action:PLAYSONG withInt:trackNo]; }

- (void)setVolume:(int)vol {
    // some error checking
    if (vol>=0 && vol<=100) {
        [self action:VOLUME withInt:vol];
        volume = vol; // so we don't need to update it any further
    }
}

- (void)setPlaylist:(int)playlistn { 
    [self action:PLAYLIST withInt:playlistn]; 
    [self update]; // switching playlists means new song lists, so update
}

- (void)setPlaylistByName:(NSString*)playlist {
    /* I cannot believe I used to set the playlist by name. It causes unbelievable problems,
       ranging from encoding problems to the simple matter of the command terminator string
       being in the playlist's name. That's why it is now set by index number (with the
       setPlaylist: function). This is only a legacy function for older clients that cannot
       use the index numbers. It is probably incredibly buggy, and I'm not going to do
       anything to fix it as all the bugs it creates can be easily circumvented by using
       index numbers, which is what new clients do anyway.
    */
 
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:@"-e"];
    [temp addObject:[[NSString alloc] initWithFormat:AS_TELL, 
        [NSString stringWithFormat:@"set view of front browser window to user playlist %s",playlist]]];
                    
    [self runCommand:OSASCRIPT withArguments:temp];
    [self update];
}
 
@end
