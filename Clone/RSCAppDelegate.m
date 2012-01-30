

#import "RSCAppDelegate.h"
#import "RSCGitCloner.h"
#import "RSCSettings.h"
#import "RSCPreferencesController.h"


@implementation RSCAppDelegate
@synthesize progressIndicator;
@synthesize preferencesController = _preferencesController;


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
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
}


#pragma mark - actions
- (IBAction)showPreferences:(id)sender 
{
    [NSBundle loadNibNamed:@"RSCPreferencesView" owner:self.preferencesController];
}



- (void)cloneUrl:(NSString *)repoURL
{
    DLog(@"Cloning: %@", repoURL);
    
    RSCGitCloner *cloner = [[RSCGitCloner alloc] initWithRepositoryURL:repoURL];
   
    void (^cloneProgressBlock)(NSInteger progress) = ^(NSInteger progress) {
        DLog(@"Progress!: %lu", progress);
        
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setDoubleValue:progress];
    };
    
    void (^cloneCompletionBlock)(NSInteger responseCode) = ^(NSInteger responseCode) {
        DLog(@"Completion block...");
        [self.progressIndicator setDoubleValue:0.0];
        [self.progressIndicator stopAnimation:self];
        
        if (responseCode == kRSCGitClonerErrorNone) {
            [[NSWorkspace sharedWorkspace] openFile:cloner.destinationPath withApplication:@"Finder"];
            
            // we no longer have a reason to live. We'll be called upon again by the bookmarklet when needed.
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
    
    [cloner cloneWithProgressBlock:cloneProgressBlock andCompletionBlock:cloneCompletionBlock];
}


#pragma mark - bookmarklet
- (void)cloneUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlAsString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlAsString];
    [self cloneUrl:[url host]];
}



#pragma mark - drop on dock icon handling
-(void)cloneFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error 
{
    NSString *urlToClone = [pboard stringForType:NSStringPboardType];
    [self cloneUrl:urlToClone];
}


#pragma mark - getter
- (RSCPreferencesController *)preferencesController
{
    if (_preferencesController != nil) {
        return _preferencesController;
    }
    
    _preferencesController = [[RSCPreferencesController alloc] init];
    return _preferencesController;
}


@end
