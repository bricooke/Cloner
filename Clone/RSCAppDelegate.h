

#import <Cocoa/Cocoa.h>

@interface RSCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *cloneURLTextField;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSButton *cloneButton;

- (IBAction)clone:(id)sender;
- (IBAction)cloneViaKeyboard:(id)sender;

@end
