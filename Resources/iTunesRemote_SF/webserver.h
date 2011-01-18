//
//  webserver.h
//  iTunesRemote-Server
//
//  Created by Marinus Oosters on 6-1-07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  This class implements a tiny webserver to allow access to iTunes via a browser

#import <Cocoa/Cocoa.h>
#import "itunescontrol.h"

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface webserver : NSObject {
    int listening_socket;
    BOOL should_listen;
    BOOL listening;
    
    int port;
    itunescontrol *iTunes;
    NSString *title;
    NSString *css;
}

- (id)initWithPort:(int)port_ title:(NSString*)title_ iTunesController:(itunescontrol*)itc CSS:(NSString*)css_;
- (void)setTitle:(NSString*)title_;
- (void)setPort:(int)port_;
- (void)setControlObject:(itunescontrol*)itc;
- (void)setCSS:(NSString*)css_;
- (NSString*)createPage;

- (BOOL)startListening;
- (void)stopListening;
- (BOOL)isListening;

@end
