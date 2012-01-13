

#import <Cocoa/Cocoa.h>

@interface RSCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *cloneURLTextField;

- (IBAction)clone:(id)sender;

@end
