

#import "RSCSettings.h"

#define USER_DEFAULTS ([NSUserDefaults standardUserDefaults])
#define kRSCDestinationPathSetting (@"RSCDestinationPathSetting")

@implementation RSCSettings

- (NSString *)destinationPath
{
    return [USER_DEFAULTS objectForKey:kRSCDestinationPathSetting];
}

- (void) setDestinationPath:(NSString *)destinationPath
{
    [USER_DEFAULTS setObject:destinationPath forKey:kRSCDestinationPathSetting];
}

@end
