

#import "RSCAppDelegate.h"
#import "RSCGitCloner.h"
#import "RSCSettings.h"


@implementation RSCAppDelegate

@synthesize window = _window;
@synthesize cloneURLTextField = _cloneURLTextField;
@synthesize progressBar = _progressBar;
@synthesize cloneButton = _cloneButton;
@synthesize destinationLabel = _destinationLabel;
@synthesize cloneOnActivate = _cloneOnActivate;

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    //
    // bookmarklet handler
    //
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(cloneUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    
    // 
    // drop on dock icon handler
    //
    [NSApp setServicesProvider:self];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    if (RSC_SETTINGS.destinationIsDownloads) {
        self.destinationLabel.stringValue = @"Downloads";
    } else {
        self.destinationLabel.stringValue = RSC_SETTINGS.destinationPath;
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.cloneOnActivate) {
        // don't interrupt it!
        self.cloneOnActivate = NO;
        return;
    }
    
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
    RSCGitCloner *cloner = [[RSCGitCloner alloc] initWithRepositoryURL:repoURL];
   
    void (^cloneProgressBlock)(NSInteger progress) = ^(NSInteger progress) {
        DLog(@"Progress!: %lu", progress);
        
        [self.progressBar setIndeterminate:NO];
        [self.progressBar setDoubleValue:progress];
    };
    
    void (^cloneCompletionBlock)(NSInteger responseCode) = ^(NSInteger responseCode) {
        DLog(@"Completion block...");
        [self.progressBar setDoubleValue:0.0];
        [self.progressBar stopAnimation:self];
        
        if (responseCode == kRSCGitClonerErrorNone) {
            [[NSWorkspace sharedWorkspace] openFile:cloner.destinationPath withApplication:@"Finder"];
        } else if (responseCode == kRSCGitClonerErrorAuthenticationRequired) {
            DLog(@"Prompt for username and password!");
            
            // just nuke the destination path.
            // TODO: Make sure it's empty?
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:cloner.destinationPath error:&error];

            // try again with username and password set in the URL
            // TODO: Ask for the username and password.
            cloner.repositoryURL = @"https://USERNAME:PASSWORD@github...";
            [cloner clone];
        }
    };    
    
    [cloner cloneWithProgressBlock:cloneProgressBlock andCompletionBlock:cloneCompletionBlock];
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
    openPanel.canCreateDirectories = YES;
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        RSC_SETTINGS.destinationPath = [[[openPanel URLs] objectAtIndex:0] path];
        RSC_SETTINGS.destinationIsDownloads = NO;
        self.destinationLabel.stringValue = RSC_SETTINGS.destinationPath;
    }
}


#pragma mark - bookmarklet
- (void)cloneUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    self.cloneOnActivate = YES;
    
    NSString *urlAsString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlAsString];
    self.cloneURLTextField.stringValue = [url host];
    [self clone:self];
}



#pragma mark - drop on dock icon handling
-(void)cloneFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error 
{
    self.cloneOnActivate = YES;
    
    NSString *urlToClone = [pboard stringForType:NSStringPboardType];
    self.cloneURLTextField.stringValue = urlToClone;
    [self clone:self];
}



@end
