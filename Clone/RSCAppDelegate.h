#import <Cocoa/Cocoa.h>

@class RSCPreferencesController;

@interface RSCAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) RSCPreferencesController *preferencesController;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end
