/* Controller */

#import <Cocoa/Cocoa.h>
#import "itrserver.h"
#import "webserver.h"
#import "itunescontrol.h"

#include <unistd.h>
#include <netdb.h>
@interface Controller : NSObject
{
    IBOutlet NSButton *allowITR;
    IBOutlet NSButton *allowWeb;
    IBOutlet NSTabView *appearanceTab;
    IBOutlet NSColorWell *bordercolor;
    IBOutlet NSColorWell *buttonbg;
    IBOutlet NSColorWell *buttonbgh;
    IBOutlet NSTextField *cssPath;
    IBOutlet NSTextField *dispName;
    IBOutlet NSTextField *generalStatus;
    IBOutlet NSColorWell *headerbg;
    IBOutlet NSColorWell *headerbgh;
    IBOutlet NSColorWell *headerfg;
    IBOutlet NSColorWell *headerfgh;
    IBOutlet NSTextField *itrPort;
    IBOutlet NSTextField *itrStatus;
    IBOutlet NSLevelIndicator *itrStatusIndicator;
    IBOutlet NSColorWell *listbg;
    IBOutlet NSColorWell *listbgh;
    IBOutlet NSColorWell *listfg;
    IBOutlet NSColorWell *listfgh;
    IBOutlet NSColorWell *pagbg;
    IBOutlet NSWindow *prefsWindow;
    IBOutlet NSWindow *statusWindow;
    IBOutlet NSColorWell *textcolor;
    IBOutlet NSColorWell *titlebg;
    IBOutlet NSTextField *webPort;
    IBOutlet NSTextField *webStatus;
    IBOutlet NSLevelIndicator *webStatusIndicator;
    
    itunescontrol *iTunes;
    itrserver *itr_s;
    webserver *web_s;
    NSMutableDictionary *settings;
}
- (IBAction)applysettings:(id)sender;
- (IBAction)browsefiles:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)showPrefs:(id)sender;
@end
