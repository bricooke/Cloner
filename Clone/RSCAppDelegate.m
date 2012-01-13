

#import "RSCAppDelegate.h"
#import "RSCGitCloner.h"

@implementation RSCAppDelegate

@synthesize window = _window;
@synthesize cloneURLTextField = _cloneURLTextField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (IBAction)clone:(id)sender 
{
    NSLog(@"Cloning: %@", self.cloneURLTextField.stringValue);
    
    RSCGitCloner *cloner = [[RSCGitCloner alloc] initWithRepositoryURL:self.cloneURLTextField.stringValue andDestinationPath:@"/Users/bcooke/Downloads/foo"];
    [[NSOperationQueue mainQueue] addOperation:cloner];
}

@end
