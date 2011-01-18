//
//  itrserver.h
//  iTunesRemote-Server
//
//  Created by Marinus Oosters on 5-1-07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//  This class implements the iTunesRemote server 

#import <Cocoa/Cocoa.h>
#import "itunescontrol.h"

// socket headers
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>


@interface itrserver : NSObject {
   int listening_socket; // socket descriptor of listening socket
   BOOL should_listen;   // whether it should be listening now or not
   BOOL listening;       // whether it is actually listening
 
   int port;   // port
   itunescontrol *iTunes; // the iTunes controller
   NSString *title; // title
 
}

- (id)initWithPort:(int)port_ title:(NSString*)title_ iTunesController:(itunescontrol*)itc;
- (void)setTitle:(NSString*)title_;
- (void)setPort:(int)port_;
- (void)setControlObject:(itunescontrol*)itc;

- (void)dealloc;

- (BOOL)startListening;
- (void)stopListening;
- (BOOL)isListening;

@end
