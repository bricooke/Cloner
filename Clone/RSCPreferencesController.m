#import "RSCPreferencesController.h"
#import "RSCSettings.h"

@implementation RSCPreferencesController

- (void) awakeFromNib
{
    [self.pathControl setURL:[NSURL fileURLWithPath:[RSCSettings sharedSettings].destinationPath]];
    
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)browseForNewPath:(id)sender 
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        [RSCSettings sharedSettings].destinationPath = [[[openPanel URLs] objectAtIndex:0] path];
        [self.pathControl setURL:[NSURL fileURLWithPath:[RSCSettings sharedSettings].destinationPath]];
    }
}

@end
