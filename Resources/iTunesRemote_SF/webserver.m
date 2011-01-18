//
//  webserver.m
//  iTunesRemote-Server
//
//  Created by Marinus Oosters on 6-1-07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  This class implements a tiny webserver to allow access to iTunes via a browser

#import "webserver.h"


@implementation webserver
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

- (id)initWithPort:(int)port_ title:(NSString*)title_ iTunesController:(itunescontrol*)itc CSS:(NSString*)css_ { 
    [super init];
    listening_socket = 0;
    should_listen = NO;
    listening = NO;
 
    port = port_;
    iTunes = [itc retain];
    title = [[NSString stringWithString:title_] retain];
    css = [[NSString stringWithString:css_] retain];
    return self;
}

- (void)dealloc {  
    [self stopListening];
    if (iTunes!=nil) [iTunes release];
    if (title!=nil) [title release];
    if (css!=nil) [css release];
    
    [super dealloc];
    
}
// write a string to a socket
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

- (void)setCSS:(NSString*)css_ {
    if (css!=nil) [css release];
    css = [[NSString stringWithString:css_] retain];
}

- (NSString*)html_encode:(NSString*)string {
    unichar c;
    int l = [string length];
    int foo;
    NSMutableString *newstr = [[NSMutableString alloc] init];
    unichar cc[2];
    for (foo=0; foo<l; foo++) {
        c = [string characterAtIndex:foo];
        
        // check if it's a web safe character
        if ( 
             ( c>='0' && c<='9' ) ||
             ( c>='A' && c<='Z' ) ||
             ( c>='a' && c<='z' ) ||
             c==' ' || c==',' || c==';' || c==':'
           ) {
           // it is, just append it
           cc[0] = c;
           [newstr appendString:[NSString stringWithCharacters:cc length:1]];
        } else {
           // if not, encode it
           [newstr appendFormat:@"&#%d;", c];
        }
        
    }
    // return a NSString
    return [NSString stringWithString:newstr];
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
    
 //   [apool release];
}

- (void)clientThread:(NSNumber*)sock {    
    NSAutoreleasePool *apool;
    apool = [[NSAutoreleasePool alloc] init];

    int socket,n;
    socket = [sock intValue];
    
    char buf[8192], *b;
    char bb[2];
    bzero(buf,8192);
    int br;
    BOOL shouldStop = NO;
    BOOL sendDefaultPage;
    NSArray *lines;
    NSString *cmd, *file, *page; 
    NSString *answer;
    NSRange foobar;
    
    NS_DURING
    
    while (!shouldStop) {
        // read a HTTP request 
        bzero(buf,8192);
        b=buf; 
        br=0;
        while(1) {
            n = read(socket,bb,1);
            if (n<0) {
                close(socket);
                shouldStop=YES;
                break;
            }
            *b = bb[0];
            br++;
            if (b[-2] == '\n' && b[0] == '\n' && b[-1] == '\r') break; // got one
            b++;
        }
        
        // parse the HTTP request
        NSLog(@"parsing HTTP");
        lines = [[NSString stringWithCString:buf] componentsSeparatedByString:@"\n"];
        
        NSLog([lines objectAtIndex:0]);
        if ([[[lines objectAtIndex:0] componentsSeparatedByString:@" "] count] < 2 ) break;
        
        cmd = [NSString stringWithString:[[[lines objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:0]];
        file = [NSString stringWithString:[[[lines objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:1]];
        
        sendDefaultPage = YES;
        
        NSLog(@"exec command");
        
        if ([file compare:@"/prevtrk"]==NSOrderedSame) [iTunes previous];
        if ([file compare:@"/rewind"]==NSOrderedSame) [iTunes rewind];
        if ([file compare:@"/playpau"]==NSOrderedSame) [iTunes playpause];
        if ([file compare:@"/ffwd"]==NSOrderedSame) [iTunes ffwd];
        if ([file compare:@"/nexttrk"]==NSOrderedSame) [iTunes next];
        if ([file compare:@"/normal"]==NSOrderedSame) [iTunes normalspeed];
        if ([file compare:@"/vol/" options:nil range:NSMakeRange(0,5)]==NSOrderedSame) 
                        [iTunes setVolume:[[file substringFromIndex:5] intValue]];
        if ([file compare:@"/library"]==NSOrderedSame) [iTunes library];
        if ([file compare:@"/plist/" options:nil range:NSMakeRange(0,7)]==NSOrderedSame)
                        [iTunes setPlaylist:[[file substringFromIndex:7] intValue]];
        if ([file compare:@"/play/" options:nil range:NSMakeRange(0,6)]==NSOrderedSame)
                        [iTunes playSong:[[file substringFromIndex:6] intValue]];
        if ([file compare:@"/style.css"] == NSOrderedSame) {
            sendDefaultPage = NO;
            page = [NSString stringWithString:css];
        }
        
        NSLog(@"send page");
        if (sendDefaultPage) page = [self createPage];
        
        if ([[cmd uppercaseString] compare:@"HEAD"] == NSOrderedSame) {
            answer = [NSString stringWithFormat:
                @"HTTP/1.0 200 OK\r\n"
                 "Content-Type: %@\r\n"
                 "Content-Length: %d\r\n"
                 "\r\n"
                 ,(([file compare:@"/style.css"]==NSOrderedSame)?@"text/css":@"text/html"),
                 [page length]];
        } else { // we'll just assume it's GET.
            answer = [NSString stringWithFormat:
                @"HTTP/1.0 200 OK\r\n"
                 "Content-Type: %@\r\n"
                 "Content-Length: %d\r\n"
                 "\r\n%@"
                 , (([file compare:@"/style.css"]==NSOrderedSame)?@"text/css":@"text/html"),
                [page length],page];
        }
        
        [self writeString:answer toSocket:socket];
        foobar = [[[NSString stringWithCString:buf] uppercaseString] rangeOfString:@"KEEP-ALIVE"];
  //      shouldStop = (foobar.location == NSNotFound);
        shouldStop = YES; // fixes a problem for now
    }
    
    NS_HANDLER
    // simply ignore invalid requests
    NS_ENDHANDLER
    
   // [apool release];
    close(socket);
}

- (BOOL)isListening {return listening; }

- (NSString*)createPage {
    // generate webpage
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendFormat:
        @"<html> <head> <title>%@</title> <link rel='stylesheet' type='text/css' "
         "href='/style.css'> </head> <body>"
         "<div class='title'>%@</div>"
         // buttons
         "<div class='commandbar'>"
         "<a href='/prevtrk' id='prv' class='btn'>&lArr;</a>"
         "<a href='/rewind' id='rew' class='btn'>&larr;</a>"
         "<a href='/playpau' id='ppa' class='btn'>&rArr;/||</a>"
         "<a href='/ffwd' id='ffw' class='btn'>&rarr;</a>"
         "<a href='/nexttrk' id='nex' class='btn'>&rArr;</a>"
         "<a href='/normal' id='nrm' class='btn'>&rarr;</a>"
         "<a href='/stop' id='sto' class='btn'>Stop</a>"
         "</div>"
    ,[self html_encode:title],[self html_encode:title]];
    
    int foo;
    // volume
    [str appendString:@"<div class=volumebar>"];
    for (foo=0;foo<101;foo+=10)
        [str appendFormat:@"<a href='/vol/%d' id='vol' class='btn'>%d</a>", foo, foo];
    [str appendString:@"</div>"];
    // playlists
    NSArray *arr = [iTunes getPlaylists];
    foo=0;
    [str appendString:
        @"<div class='playlists'><div class='header'>Playlists</div>"
         "<a href='/library' id='lib' class='btn'><div class='listitem'>Library</div></a>"];
    for (foo=0;foo<[arr count]-1;foo++) 
        [str appendFormat:
            @"<a href='/plist/%d' id='pla' class='btn'><div class='listitem'>%@</div></a>"
            ,foo+1,[self html_encode:[arr objectAtIndex:foo]]];
    [str appendString:@"</div>"];
    
    //songs
    [str appendString:
        @"<div class='songs'><table valign=top cellspacing=0 cellpadding=0 width='100%'>"
         "<tr><td id='track' class='cm'><div class=header>Track</div></td><td id='art' c"
         "lass='cm'><div class='header'>Artist</div></td><td id='dur' class='cm'><div cl"
         "ass='header'>Duration</div></td><td id='rat' class='cm'><div class='header'>Ra"
         "ting</div></td></tr>"];
    
    NSArray *titles = [iTunes getTitles], 
            *artists = [iTunes getArtists],
            *durations = [iTunes getDurations],
            *ratings = [iTunes getRatings];
    
    int bar;
    for (foo=0; foo<[titles count]-1; foo++) {
        bar = [[ratings objectAtIndex:foo] intValue];
        [str appendFormat:
            @"<tr><td id='track' class='cm'><a href='/play/%d'><div class='listitem'>%@</"
             "div></a></td><td id='art' class='cm'><div class='nlistitem'>%@</div></td><t"
             "d id='dur' class='cm'><div class='nlistitem'>%@</div></td><td id='rat' clas"
             "s='cm'>%@</td></tr>", foo+1,
             [self html_encode:[titles objectAtIndex:foo]],
             [self html_encode:[artists objectAtIndex:foo]],
             [self html_encode:[durations objectAtIndex:foo]],
             
             (bar>80)?@"&#9733;&#9733;&#9733;&#9733;&#9733;":
             (bar>60)?@"&#9733;&#9733;&#9733;&#9733;":
             (bar>40)?@"&#9733;&#9733;&#9733;":
             (bar>20)?@"&#9733;&#9733;":
             (bar>0) ?@"&#9733;":
                      @""];
    };
    [str appendString:@"</table></div></body></html>"];
    return [NSString stringWithString:str];
}
        
        
    
@end
