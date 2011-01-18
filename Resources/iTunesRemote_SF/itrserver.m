//
//  itrserver.m
//  iTunesRemote-Server
//
//  Created by Marinus Oosters on 5-1-07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  implements the iTunesRemote server

#import "itrserver.h"

// #define MIN(x,y) (((x)<(y))?(x):(y))

void dummy() {} // this shuts up the compiler somewhere

@implementation itrserver

- (id)init {
    [super init];
    listening_socket = 0;
    should_listen = NO;
    listening = NO;
 
    port = 0;
    iTunes = nil;
    title = nil;
    return self;
}

- (id)initWithPort:(int)port_ title:(NSString*)title_ iTunesController:(itunescontrol*)itc { 
    [super init];
    listening_socket = 0;
    should_listen = NO;
    listening = NO;
 
    port = port_;
    iTunes = [itc retain];
    title = [[NSString stringWithString:title_] retain];
    return self;
}

- (void)dealloc {  
    [self stopListening];
    if (iTunes!=nil) [iTunes release];
    if (title!=nil) [title release];
    
    [super dealloc];
    
}

- (void)setTitle:(NSString*)title_ {
    if (title!=nil) [title release];
    title = [[NSString stringWithString:title_] retain];
}

- (void)setPort:(int)port_ { port=port_; }
- (void)setControlObject:(itunescontrol*)itc  {
    if (iTunes!=nil) [iTunes release];
    iTunes = [itc retain];
}

// write a string to a socket, adding a terminating zero
- (void)writeString:(NSString*)string toSocket:(int)socket {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    const char *b;
    b = [data bytes];
    int s=0, l = [data length];
    while (l>0) {
        s = send(socket, b, l, 0);
        if (s<0) break;
        b += s;
        l -= s;
    }
    char z[] = {0};
    send(socket, z, 1, 0);
}
        
// returns YES on success and NO on failure
- (BOOL)startListening { 
    // kill socket if one already exists
    if (listening) [self stopListening];
 
    // initialize socket
    struct sockaddr_in serv_addr;
    listening_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (listening_socket<0) {
        return NO;
    }
    bzero((char*)&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    if (bind(listening_socket, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
        return NO;
    }
    
    should_listen = YES;
    
    // We now have a bound socket. The actual listening has to be done in another thread,
    // so it doesn't block the program.
    
    [NSThread detachNewThreadSelector:@selector(listenThread) toTarget:self withObject:nil];
 
    return YES;
}

- (void)stopListening {
    should_listen = NO;
    close(listening_socket);
}

- (void)listenThread {
    NSAutoreleasePool *apool;
    apool = [[NSAutoreleasePool alloc] init];

    unsigned int clilen;
    int newsock;
    struct sockaddr_in cli_addr;
    
    listen(listening_socket, 5);
    listening = YES;
    
    clilen = sizeof(cli_addr);
    while (should_listen) {
        newsock = accept(listening_socket, (struct sockaddr*)&cli_addr, &clilen);
        if (newsock >= 0) { // i.e. if it succeeded
            // start yet another thread for handling this particular client
            [NSThread detachNewThreadSelector:@selector(clientThread:) 
                    toTarget:self withObject:[NSNumber numberWithInt:newsock]];
        }
        // we'll silently discard failed attempts
    }
    
    // it should no longer listen, so close the listening socket (or we'll have trouble)
    close(listening_socket);
    should_listen = NO;
    listening = NO;
    
    //[apool release];
}

- (void)clientThread:(NSNumber*)sock {    
    NSAutoreleasePool *apool;
    apool = [[NSAutoreleasePool alloc] init];

    int socket,n;
    socket = [sock intValue];
    char buf[256];
    char b[2];
    int p=0;
    
    char foo[256];
    bzero(buf,256);
    BOOL stop=NO;
    
    while(!stop) {
        if (p>=254) p=0; // just loop around, if it's >254 it's fucked up anyway. leave the last bit 0.
        n = read(socket, b, 1);
        if (n<0) { // read error
            close(socket);
            stop=YES;
            break;
        }
        if (b[0] != '$') buf[p++] = b[0];
        else {
            // we have a command.
            switch(buf[0]) {
                case 'p': [iTunes playpause]; break;
                case 'P': [iTunes playSong:strtol(&buf[1],NULL,10)]; break;
                case 'b': [iTunes previous]; break;
                case 'n': [iTunes next]; break;
                case 'r': [iTunes rewind]; break;
                case 'f': [iTunes ffwd]; break;
                case 's': [iTunes stop]; break;
                case 'e': [iTunes normalspeed]; break;
                case 'v': [iTunes setVolume:strtol(&buf[1],NULL,10)]; break;
                case '@': [iTunes setPlaylist:strtol(&buf[1],NULL,10)]; break;
                case 'l': [iTunes library]; break;
                case 'D': 
                    close(socket);
                    stop=YES;
                    break;
                case 't': [self writeString:@"ok" toSocket:socket]; break;
                case 'K': [self writeString:[[iTunes getTitles] componentsJoinedByString:@"\n"] toSocket:socket]; break;
                case 'd': [self writeString:[[iTunes getDurations] componentsJoinedByString:@"\n"] toSocket:socket]; break;
                case '?': [self writeString:[[iTunes getRatings] componentsJoinedByString:@"\n"] toSocket:socket]; break;
                case 'E': [self writeString:[[iTunes getArtists] componentsJoinedByString:@"\n"] toSocket:socket]; break;
                case '#': [self writeString:[[iTunes getTimesPlayed] componentsJoinedByString:@"\n"] toSocket:socket]; break;
                case 'L': [self writeString:[[iTunes getPlaylists] componentsJoinedByString:@"\n"] toSocket:socket]; break;
                case 'V': [self writeString:[NSString stringWithFormat:@"%d",[iTunes getVolume]] toSocket:socket]; break;
                
                case '^': [self writeString:title toSocket:socket]; break;
                
                /** the following are legacy commands **/
                
                case 'N': [self writeString:[[iTunes getTitles] componentsJoinedByString:@"::"] toSocket:socket]; break;
                case 'T': [self writeString:[[iTunes getDurations] componentsJoinedByString:@"::"] toSocket:socket]; break;
                case 'R': [self writeString:[[iTunes getRatings] componentsJoinedByString:@"::"] toSocket:socket]; break;
                case 'A': [self writeString:[[iTunes getArtists] componentsJoinedByString:@"::"] toSocket:socket]; break;
                case 'C': [self writeString:[[iTunes getTimesPlayed] componentsJoinedByString:@"::"] toSocket:socket]; break;
                case 'G': [self writeString:[[iTunes getPlaylists] componentsJoinedByString:@"::"] toSocket:socket]; break;
                case 'g':
                    bzero(foo,256);
                    strncpy(foo, &buf[1], MIN(p-1,256));
                    [iTunes setPlaylistByName:[NSString stringWithCString:foo]];
                    break;
            }
            p=0;
            bzero(buf,256);
        }
    }
    close(socket);
    
  //  [apool release];
}

- (BOOL)isListening {return listening; }

        
                    
@end
