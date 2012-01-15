

#import "RSCAppDelegate.h"
#import "RSCGitCloner.h"
#import "RSCSettings.h"


@implementation RSCAppDelegate

@synthesize window = _window;
@synthesize cloneURLTextField = _cloneURLTextField;
@synthesize progressBar = _progressBar;
@synthesize cloneButton = _cloneButton;
@synthesize destinationLabel = _destinationLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (RSC_SETTINGS.destinationIsDownloads) {
        self.destinationLabel.stringValue = @"Downloads";
    } else {
        self.destinationLabel.stringValue = RSC_SETTINGS.destinationPath;
    }
    
    //
    // notifications
    //
    void (^progressReportBlock)(NSNotification *note) = ^(NSNotification *note) {
        [self.progressBar setIndeterminate:NO];
        [self.progressBar setDoubleValue:[note.object doubleValue]];
    };
    
    void (^cloneFinishedBlock)(NSNotification *note) = ^(NSNotification *note) {
        [self.progressBar setDoubleValue:0.0];
        [self.progressBar stopAnimation:self];
        
        [[NSWorkspace sharedWorkspace] openFile:note.object];
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

    if ([copiedItems count] == 0) {
        [self.cloneURLTextField becomeFirstResponder];
        return; // ignore contents.
    }
    
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
        [self.cloneURLTextField becomeFirstResponder];
        [[self.cloneURLTextField currentEditor] setSelectedRange:NSMakeRange(0, [self.cloneURLTextField.stringValue length])];
    } else {
        [self.cloneURLTextField becomeFirstResponder];
        [[self.cloneURLTextField currentEditor] setSelectedRange:NSMakeRange(0, [self.cloneURLTextField.stringValue length])];
    }
}


#pragma mark - actions
- (IBAction)clone:(id)sender 
{
    [self.progressBar setIndeterminate:YES];
    [self.progressBar startAnimation:self];

    NSString *repoURL = self.cloneURLTextField.stringValue;
    NSString *repoName = [[repoURL lastPathComponent] stringByDeletingPathExtension];
    NSString *destPath = [NSString stringWithFormat:@"%@/%@", [RSC_SETTINGS destinationPath], repoName];
        
    RSCGitCloner *cloner = [[RSCGitCloner alloc] initWithRepositoryURL:repoURL 
                                                    andDestinationPath:destPath];
    [[NSOperationQueue mainQueue] addOperation:cloner];
}

- (IBAction)cloneViaKeyboard:(id)sender 
{
    [self clone:self];
}

- (IBAction)browse:(id)sender 
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        RSC_SETTINGS.destinationPath = [[[openPanel URLs] objectAtIndex:0] path];
        RSC_SETTINGS.destinationIsDownloads = NO;
        self.destinationLabel.stringValue = RSC_SETTINGS.destinationPath;
    }
}



@end
