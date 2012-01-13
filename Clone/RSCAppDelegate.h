

#import <Cocoa/Cocoa.h>

@interface RSCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *cloneURLTextField;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

- (IBAction)clone:(id)sender;

@end
