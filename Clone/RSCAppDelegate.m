

#import "RSCAppDelegate.h"
#import "RSCGitCloner.h"

@implementation RSCAppDelegate

@synthesize window = _window;
@synthesize cloneURLTextField = _cloneURLTextField;
@synthesize progressBar = _progressBar;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    void (^progressReportBlock)(NSNotification *note) = ^(NSNotification *note) {
        [self.progressBar setIndeterminate:NO];
        [self.progressBar setDoubleValue:[note.object doubleValue]];
    };
    
    void (^cloneFinishedBlock)(NSNotification *note) = ^(NSNotification *note) {
        [self.progressBar setDoubleValue:0.0];
        [self.progressBar stopAnimation:self];
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kRSCProgressReport
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:progressReportBlock];

    [[NSNotificationCenter defaultCenter] addObserverForName:kRSCCloneFinished
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:cloneFinishedBlock];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSArray *classes        = [[NSArray alloc] initWithObjects:[NSString class], nil];
    NSDictionary *options   = [NSDictionary dictionary];
    NSArray *copiedItems    = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:options];

    if ([copiedItems count] == 0)
        return; // ignore contents.
    
    NSString *clipboard = [copiedItems objectAtIndex:0];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\S*$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([regex numberOfMatchesInString:clipboard
                               options:0
                                 range:NSMakeRange(0, [clipboard length])] > 0) {
        // a match.
        self.cloneURLTextField.stringValue = clipboard;
        [[self.cloneURLTextField currentEditor] setSelectedRange:NSMakeRange(0, [clipboard length])];
    }
}

- (IBAction)clone:(id)sender 
{
    [self.progressBar setIndeterminate:YES];
    [self.progressBar startAnimation:self];

    RSCGitCloner *cloner = [[RSCGitCloner alloc] initWithRepositoryURL:self.cloneURLTextField.stringValue andDestinationPath:@"/Users/bcooke/Downloads/foo"];
    [[NSOperationQueue mainQueue] addOperation:cloner];
}

@end
