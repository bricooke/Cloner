

#import "RSCAppDelegate.h"

@implementation RSCAppDelegate

@synthesize window = _window;
@synthesize cloneURLTextField = _cloneURLTextField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (IBAction)clone:(id)sender 
{
    NSLog(@"Cloning: %@", self.cloneURLTextField.stringValue);
}

@end
