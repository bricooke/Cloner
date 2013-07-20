#import "RSCAppDelegate.h"
#import "RSCGitCloner.h"
#import "RSCSettings.h"
#import "RSCPreferencesController.h"

@implementation RSCAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    // bookmarklet handler

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(cloneUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    
    // drop on dock icon handler

    [NSApp setServicesProvider:self];
}

#pragma mark - Methods

- (void)cloneUrl:(NSString *)repoURL
{
    DLog(@"Cloning: %@", repoURL);
    
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator startAnimation:self];
    
    RSCGitCloner *cloner = [[RSCGitCloner alloc] initWithRepositoryURL:repoURL];
   
    RSCCloneProgressBlock cloneProgressBlock = ^(NSInteger progress) {
        DLog(@"Progress!: %ld", (long)progress);
        
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setDoubleValue:progress];
    };
    
    RSCCloneCompletionBlock cloneCompletionBlock = ^(kRSCGitClonerErrors responseCode) {
        DLog(@"Completion block...");
        [self.progressIndicator setDoubleValue:0.0];
        [self.progressIndicator stopAnimation:self];
        
        if (responseCode == kRSCGitClonerErrorNone) {
            [[NSWorkspace sharedWorkspace] openFile:cloner.destinationPath withApplication:@"Finder"];
            
            // we no longer have a reason to live. We'll be called upon again by the bookmarklet when needed.
            [NSApp terminate:self];
        } else if (responseCode == kRSCGitClonerErrorCloning) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Unable to clone" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"git clone %@ failed.\n\nMake sure you were on a valid github URL and try again.", cloner.repositoryURL];
            [alert runModal];
            [NSApp terminate:self];
        } else if (responseCode == kRSCGitClonerErrorAuthenticationRequired) {
            DLog(@"Prompt for username and password!");
            
            // just nuke the destination path.
            // TODO: Make sure it's empty?
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:cloner.destinationPath error:&error];

            // try again with username and password set in the URL
            // TODO: Ask for the username and password.
            // cloner.repositoryURL = @"https://USERNAME:PASSWORD@github...";
            // [cloner clone];
        }
    };    
    
    [cloner cloneWithProgressBlock:cloneProgressBlock completionBlock:cloneCompletionBlock];
}

-(void)cloneFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error
{
    NSString *urlToClone = [pboard stringForType:NSStringPboardType];
    [self cloneUrl:urlToClone];
}

- (void)cloneUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlAsString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlAsString];
    [self cloneUrl:[url host]];
}

- (RSCPreferencesController *)preferencesController
{
    if (_preferencesController != nil) {
        return _preferencesController;
    }

    _preferencesController = [[RSCPreferencesController alloc] init];
    return _preferencesController;
}

- (IBAction)showPreferences:(id)sender
{
    NSNib *preferencesNib = [[NSNib alloc] initWithNibNamed:@"RSCPreferencesView" bundle:nil];
    [preferencesNib instantiateWithOwner:self.preferencesController topLevelObjects:nil];
}

@end
