

#import "RSCPreferencesController.h"
#import "RSCSettings.h"


@implementation RSCPreferencesController
@synthesize window;
@synthesize pathControl;

- (void) awakeFromNib
{
    [self.pathControl setURL:[NSURL fileURLWithPath:RSC_SETTINGS.destinationPath]];
    
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)browseForNewPath:(id)sender 
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        RSC_SETTINGS.destinationPath = [[[openPanel URLs] objectAtIndex:0] path];
        [self.pathControl setURL:[NSURL fileURLWithPath:RSC_SETTINGS.destinationPath]];
    }
}

@end
