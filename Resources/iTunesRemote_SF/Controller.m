#import "Controller.h"

#define REPLACESTR(x,y,z) [x replaceOccurrencesOfString:y withString:z options:nil range:NSMakeRange(0, [x length])]


// this returns the local IP address if possible, or nil on error
NSString* getLocalIP() {
    char hostname[100];
    char ip[13];
    if (gethostname(hostname, 100) == -1) return nil;
    
    struct hostent *h;
    h = gethostbyname(hostname);
    if (!h) return nil;
    sprintf(ip, "%s", inet_ntoa(*((struct in_addr*) h->h_addr)));
    
    return [NSString stringWithCString:ip];
}
    

// this returns the default CSS template, with the user's colors filled in
NSString* getDefaultCSSWithColors(
    NSString* pagbg,
    NSString* titlebg,
    NSString* textcolor,
    NSString* buttonbg,
    NSString* buttonbgh,
    NSString* listbg,
    NSString* listbgh,
    NSString* listfg,
    NSString* listfgh,
    NSString* headerbg,
    NSString* headerfg,
    NSString* bordercolor) {
    
    NSMutableString* css_template = [[NSMutableString alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"template" ofType:@"css"]];
  //  NSLog(@"L:%d",[css_template length]);
    
  
    REPLACESTR(css_template,@"{pagbg}",pagbg);
    REPLACESTR(css_template,@"{titlebg}",titlebg);
    REPLACESTR(css_template,@"{textcolor}",textcolor);
    REPLACESTR(css_template,@"{buttonbg}",buttonbg);
    REPLACESTR(css_template,@"{buttonbgh}",buttonbgh);
    REPLACESTR(css_template,@"{listbg}",listbg);
    REPLACESTR(css_template,@"{listbgh}",listbgh);
    REPLACESTR(css_template,@"{listfg}",listfg);
    REPLACESTR(css_template,@"{listfgh}",listfgh);
    REPLACESTR(css_template,@"{headerbg}",headerbg);
    REPLACESTR(css_template,@"{headerfg}",headerfg);
    REPLACESTR(css_template,@"{bordercolor}",bordercolor);
    

    return [NSString stringWithString:css_template];
}

@implementation Controller

// default settings
// to ease typing:
#define SB(x) [NSNumber numberWithBool:x]
#define SI(x) [NSNumber numberWithInt:x]
#define SS(x) [NSString stringWithString:x]
#define SETTING(x) [settings objectForKey:x]

#define MAKERED(x) [x setCriticalValue:1.]; [x setWarningValue:0.]; [x setDoubleValue:1.]
#define MAKEGREEN(x) [x setCriticalValue:0.]; [x setWarningValue:0.]; [x setDoubleValue:1.]
#define MAKEGRAY(x) [x setCriticalValue:0.]; [x setWarningValue:0.]; [x setDoubleValue:0.]
#define MAKEORANGE(x) [x setCriticalValue:0.]; [x setWarningValue:1.]; [x setDoubleValue:1.]
// it seemed best to put this in a separate function because it's rather large
- (NSMutableDictionary*) defaultSettings {
   return
   [NSMutableDictionary dictionaryWithObjectsAndKeys:
            SI(9166),      @"itrport",
            SI(8080),      @"webport",
            SB(YES),       @"itrallowed",
            SB(YES),       @"weballowed",
            SS(@""),       @"displayname",
            SS(@"5295FC"), @"pagbg",
            SS(@"D4D4D4"), @"titlebg",
            SS(@"262626"), @"textcolor",
            SS(@"A8A8A8"), @"buttonbg",
            SS(@"D4D4D4"), @"buttonbgh",
            SS(@"FFFFFF"), @"listbg",
            SS(@"5295FC"), @"listbgh",
            SS(@"000000"), @"listfg",
            SS(@"FFFFFF"), @"listfgh",
            SS(@"2838FB"), @"headerbg",
            SS(@"FFFFFF"), @"headerfg",
            SS(@"000000"), @"bordercolor",
            SS(@""),       @"csspath",
            SI(0),         @"appearancetab",
            nil];
}

// hex values to NSColor

- (NSColor*)colorFromHexString:(NSString*)string {

    
    if ([string length] < 6) return nil;
    const char *cs = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    // I know there's a better way, I'm just too lazy to change it
    int r=0, g=0, b=0;
    if (cs[0]>='a' && cs[0]<='f') r += (cs[0]-'a'+10)*16;
    else if (cs[0]>='A' && cs[0]<='F') r += (cs[0]-'A'+10)*16;
    else if (cs[0]>='0' && cs[0]<='9') r += (cs[0]-'0')*16;

    if (cs[1]>='a' && cs[1]<='f') r += (cs[1]-'a'+10);
    else if (cs[1]>='A' && cs[1]<='F') r += (cs[1]-'A'+10);
    else if (cs[1]>='0' && cs[1]<='9') r += (cs[1]-'0');
   
    if (cs[2]>='a' && cs[2]<='f') g += (cs[2]-'a'+10)*16;
    else if (cs[2]>='A' && cs[2]<='F') g += (cs[2]-'A'+10)*16;
    else if (cs[2]>='0' && cs[2]<='9') g += (cs[2]-'0')*16;
    
    if (cs[3]>='a' && cs[3]<='f') g += (cs[3]-'a'+10);
    else if (cs[3]>='A' && cs[3]<='F') g += (cs[3]-'A'+10);
    else if (cs[3]>='0' && cs[3]<='9') g += (cs[3]-'0');  
    
    if (cs[4]>='a' && cs[4]<='f') b += (cs[4]-'a'+10)*16;
    else if (cs[4]>='A' && cs[4]<='F') b += (cs[4]-'A'+10)*16;
    else if (cs[4]>='0' && cs[4]<='9') b += (cs[4]-'0')*16;
    
    if (cs[5]>='a' && cs[5]<='f') b += (cs[5]-'a'+10);
    else if (cs[5]>='A' && cs[5]<='F') b += (cs[5]-'A'+10);
    else if (cs[5]>='0' && cs[5]<='9') b += (cs[5]-'0');
    
    
    
    double rr, gg, bb;
    
    rr = ((double)r/255.);
    gg = ((double)g/255.);
    bb = ((double)b/255.);
    
    
    return [NSColor colorWithCalibratedRed:rr green:gg blue:bb alpha:1.];
}

// NSColor to hex values

- (NSString*)hexStringFromNSColor:(NSColor*)color {
    float r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    int rr,gg,bb;
    rr = (int)(r*255.);
    gg = (int)(g*255.);
    bb = (int)(b*255.);
    
    char cs[7] = {'0', '0', '0', '0', '0', '0', 0};
    sprintf(cs, "%2x%2x%2x", rr, gg, bb);
    int foo;
    for (foo=0;foo<6;foo++) if (cs[foo]==' ') cs[foo]='0';
    
    return [NSString stringWithCString:cs encoding:NSUTF8StringEncoding];
}
    
- (void)awakeFromNib {
    // try to restore settings from file
    BOOL noSettingsFile = NO;
    settings = [NSMutableDictionary dictionaryWithContentsOfFile:
                    [@"~/Library/Preferences/net.sourceforge.itunesremote.iTunesRemote_server"
                                stringByStandardizingPath]];
    if (settings == nil) {
        settings = [NSMutableDictionary dictionaryWithDictionary:[self defaultSettings]];
        noSettingsFile = YES;
    }
    
    [settings retain];
    NSLog(@"Got settings");
    iTunes = nil;
    // we'll do the rest of the initialisation in another thread so the app won't hang while initialising
    
    itr_s = nil;
    web_s = nil;
    
    [NSThread detachNewThreadSelector:@selector(initthread) toTarget:self withObject:nil];
    
    
    
    
    
    
    
    NSLog(@"Awake");
}

- (void)applicationWillQuit:(id)sender {
    if (itr_s != nil) {
        if ([itr_s isListening]) [itr_s stopListening];
        [itr_s release];
    }
    
    if (web_s != nil) {
        if ([web_s isListening]) [web_s stopListening];
        [web_s release];
    }
    
}

- (void)initthread {
    NSAutoreleasePool *apool;
    apool = [[NSAutoreleasePool alloc] init];
    NSLog(@"In Thread");
    NSString *temp;
    //canReinitialize = NO; // we wouldn't want two initialization threads running at the same time
    [generalStatus setStringValue:@"Connecting to iTunes..."];
    [generalStatus display];
    
    NSLog(@"itunes");
    iTunes = [[[itunescontrol alloc] init] retain];
    
    if (itr_s != nil) {
        [itr_s stopListening];
        [itr_s release];
    }
    
    NSLog(@"itrs");
    [generalStatus setStringValue: @"Starting network services..."];
    if ([[settings objectForKey:@"itrallowed"] boolValue]) {   
        [itrStatus setStringValue:@"Initializing..."];
        MAKEORANGE(itrStatusIndicator);
        itr_s = [[[itrserver alloc] initWithPort: [[settings objectForKey:@"itrport"] intValue]
                                           title: [settings objectForKey:@"displayname"]
                                iTunesController: iTunes] retain];
        if (itr_s==nil) {
        
            [itrStatus setStringValue:@"Cannot allocate object. Memory problems?"];
            [itrStatus display];
            MAKERED(itrStatusIndicator);
            [itrStatusIndicator display];
        } else {
            [itrStatus setStringValue:@"Connecting..."];
            if ([itr_s startListening]) {
                temp = getLocalIP();
                if (temp==nil) [itrStatus setStringValue:@"Accepting connections."];
                else [itrStatus setStringValue:[NSString stringWithFormat:
                        @"Accepting connections.\nIP Address:%@\nPort: %d",
                        temp, [SETTING(@"itrport") intValue]]];
                [itrStatus display];
                MAKEGREEN(itrStatusIndicator);
                [itrStatusIndicator display];
            } else {
                [itrStatus setStringValue:@"Cannot listen. The socket may be in use, or your firewall is blocking."];
                [itrStatus display];
                MAKERED(itrStatusIndicator);
                [itrStatusIndicator display];
            }
            
        }
    } else {
        [itrStatus setStringValue:@"Disabled. You can turn this on in Preferences."];
        [itrStatus display];
        MAKEGRAY(itrStatusIndicator);
        [itrStatusIndicator display];
    }
    
    NSLog(@"webs");
    if ([[settings objectForKey:@"weballowed"] boolValue]) {
        [webStatus setStringValue:@"Initializing..."];
        web_s = [[[webserver alloc] initWithPort: [[settings objectForKey:@"webport"] intValue]
                                           title: [settings objectForKey:@"displayname"]
                                iTunesController: iTunes
                                             CSS:
                                                 ([[settings objectForKey:@"appearanceTab"] intValue]==0)?
                                                    [[NSString alloc] initWithString:getDefaultCSSWithColors
                                                            ( SETTING(@"pagbg"), SETTING(@"titlebg"), SETTING(@"textcolor"),
                                                              SETTING(@"buttonbg"), SETTING(@"buttonbgh"), SETTING(@"listbg"),
                                                              SETTING(@"listbgh"), SETTING(@"listfg"), SETTING(@"listfgh"),
                                                              SETTING(@"headerbg"), SETTING(@"headerfg"), SETTING(@"bordercolor"))]
                                                        :
                                                    [[NSString alloc] initWithContentsOfFile:SETTING(@"csspath")]] retain];
        if (web_s==nil) {
            [webStatus setStringValue:@"Cannot allocate object. Memory problems?"];
            MAKERED(webStatusIndicator);
        } else {
            NSLog(@"web_s made");
            [webStatus setStringValue:@"Connecting..."];
            if ([web_s startListening]) {
                temp = getLocalIP();
                if (temp==nil) [webStatus setStringValue:@"Accepting connections."];
                else [webStatus setStringValue:[NSString stringWithFormat:
                        @"Accepting connections.\nAddress: http://%@:%d/",
                        temp, [SETTING(@"webport") intValue]]];
                [webStatus display];
                MAKEGREEN(webStatusIndicator);
            } else {
                [webStatus setStringValue:@"Cannot listen. The socket may be in use, or your firewall is blocking."];
                MAKERED(webStatusIndicator);
            }
        }
    } else {
        [webStatus setStringValue:@"Disabled. You can turn this on in Preferences."];
        MAKEGRAY(webStatusIndicator);
    }
    
    [itrStatus display];
    [itrStatusIndicator display];
    [webStatus display];
    [webStatusIndicator display];
    [generalStatus setStringValue:@"Ready."];
    [generalStatus display];

    NSLog(@"eos");
    
    [apool release];
}
-(id)valueForUndefinedKey:(id)key { return @""; } // quick and dirty

- (IBAction)showPrefs:(id)sender {
    // make sure the fields in the preference window correspond with the settings
    [itrPort setIntValue:[[settings objectForKey:@"itrport"] intValue]];
    [webPort setIntValue:[[settings objectForKey:@"webport"] intValue]];
    [allowITR setState:[[settings objectForKey:@"itrallowed"] boolValue]];
    [allowWeb setState:[[settings objectForKey:@"weballowed"] boolValue]];
    [dispName setStringValue:[settings objectForKey:@"displayname"]];
    [pagbg setColor:[self colorFromHexString:[settings objectForKey:@"pagbg"]]];
    [titlebg setColor:[self colorFromHexString:[settings objectForKey:@"titlebg"]]];
    [textcolor setColor:[self colorFromHexString:[settings objectForKey:@"textcolor"]]];
    [buttonbg setColor:[self colorFromHexString:[settings objectForKey:@"buttonbg"]]];
    [buttonbgh setColor:[self colorFromHexString:[settings objectForKey:@"buttonbgh"]]];
    [listbg setColor:[self colorFromHexString:[settings objectForKey:@"listbg"]]];
    [listbgh setColor:[self colorFromHexString:[settings objectForKey:@"listbgh"]]];
    [listfg setColor:[self colorFromHexString:[settings objectForKey:@"listfg"]]];
    [listfgh setColor:[self colorFromHexString:[settings objectForKey:@"listfgh"]]];
    [headerbg setColor:[self colorFromHexString:[settings objectForKey:@"headerbg"]]];
    [headerfg setColor:[self colorFromHexString:[settings objectForKey:@"headerfg"]]];
    [bordercolor setColor:[self colorFromHexString:[settings objectForKey:@"bordercolor"]]];
    [cssPath setStringValue:[settings objectForKey:@"csspath"]];
    [appearanceTab selectTabViewItemAtIndex:[[settings objectForKey:@"appearancetab"] intValue]];
    // show preferences window
    [prefsWindow makeKeyAndOrderFront:self];
    
}
    
- (IBAction)applysettings:(id)sender {
    // set settings to fields
    // we can dispose of the old object now
    [settings release];
    settings = [[[NSMutableDictionary alloc] init] retain];
    [settings setObject:SI([itrPort intValue]) forKey:@"itrport"];
    [settings setObject:SI([webPort intValue]) forKey:@"webport"];
    [settings setObject:SB([allowITR state]) forKey:@"itrallowed"];
    [settings setObject:SB([allowWeb state]) forKey:@"weballowed"];
    [settings setObject:[dispName stringValue] forKey:@"displayname"];
    [settings setObject:[self hexStringFromNSColor:[pagbg color]] forKey:@"pagbg"];
    [settings setObject:[self hexStringFromNSColor:[titlebg color]] forKey:@"titlebg"];
    [settings setObject:[self hexStringFromNSColor:[textcolor color]] forKey:@"textcolor"];
    [settings setObject:[self hexStringFromNSColor:[buttonbg color]] forKey:@"buttonbg"];
    [settings setObject:[self hexStringFromNSColor:[buttonbgh color]] forKey:@"buttonbgh"];
    [settings setObject:[self hexStringFromNSColor:[listbg color]] forKey:@"listbg"];
    [settings setObject:[self hexStringFromNSColor:[listbgh color]] forKey:@"listbgh"];
    [settings setObject:[self hexStringFromNSColor:[listfg color]] forKey:@"listfg"];
    [settings setObject:[self hexStringFromNSColor:[listfgh color]] forKey:@"listfgh"];
    [settings setObject:[self hexStringFromNSColor:[headerbg color]] forKey:@"headerbg"];
    [settings setObject:[self hexStringFromNSColor:[headerfg color]] forKey:@"headerfg"];
    [settings setObject:[self hexStringFromNSColor:[bordercolor color]] forKey:@"bordercolor"];
    [settings setObject:[cssPath stringValue] forKey:@"csspath"];
    if ([appearanceTab indexOfTabViewItem:[appearanceTab selectedTabViewItem]]==1) {
        if ([NSString stringWithContentsOfFile:[cssPath stringValue]] == nil) {
            NSRunAlertPanel(@"File error", @"You have set a custom CSS file, but I cannot open it.\n"
                                            "I'll default to the color set.\n", @"OK", nil, nil);
            [settings setObject:SI(0) forKey:@"appearancetab"];
        } else [settings setObject:SI(1) forKey:@"appearancetab"];
    } else [settings setObject:SI(0) forKey:@"appearancetab"];
    
    // apply settings
    if (itr_s != nil) [itr_s setTitle:[dispName stringValue]];
    if (web_s != nil) {
        [web_s setTitle:[dispName stringValue]];
        if ([[settings objectForKey:@"appearancetab"] intValue]==0) {
            [web_s setCSS:[[NSString alloc] initWithString:getDefaultCSSWithColors
                                          (SETTING(@"pagbg"), SETTING(@"titlebg"), SETTING(@"textcolor"),
                                           SETTING(@"buttonbg"), SETTING(@"buttonbgh"), SETTING(@"listbg"),
                                           SETTING(@"listbgh"), SETTING(@"listfg"), SETTING(@"listfgh"),
                                           SETTING(@"headerbg"), SETTING(@"headerfg"), SETTING(@"bordercolor"))]];
        } else {
            [web_s setCSS:[NSString stringWithContentsOfFile:SETTING(@"csspath")]];
        } 
    }
    // save settings
    
    if (![settings writeToFile:[@"~/Library/Preferences/net.sourceforge.itunesremote.iTunesRemote_server"
                                stringByStandardizingPath] atomically:YES]) {
        NSRunAlertPanel(@"Error", @"An error has occured while saving the settings.\n", @"Too bad", nil, nil);
    }
    
    // close preferences window
    [prefsWindow close];
    
}

- (IBAction)browsefiles:(id)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    if ([panel runModalForDirectory:nil file:nil types:nil] == NSOKButton) {
        [cssPath setStringValue:[panel filename]];
    }
}

- (IBAction)restart:(id)sender
{
}

@end
