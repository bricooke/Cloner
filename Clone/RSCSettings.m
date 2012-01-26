

#import "RSCSettings.h"

#define USER_DEFAULTS ([NSUserDefaults standardUserDefaults])
#define kRSCDestinationPathSetting (@"RSCDestinationPathSetting")
#define kRSCIsFirstLaunchSetting   (@"RSCIsFirstLaunchSetting")

@implementation RSCSettings

+ (void) initialize
{
    NSError *error = nil;
                  
    NSString *downloadDir = [[[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error] path];
    [USER_DEFAULTS registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                     downloadDir, kRSCDestinationPathSetting,
                                     [NSNumber numberWithBool:YES], kRSCIsFirstLaunchSetting,
                                     nil]];
}

- (NSString *)destinationPath
{
    return [USER_DEFAULTS objectForKey:kRSCDestinationPathSetting];
}

- (void) setDestinationPath:(NSString *)destinationPath
{
    [USER_DEFAULTS setObject:destinationPath forKey:kRSCDestinationPathSetting];
    [USER_DEFAULTS synchronize];
}

- (BOOL) isFirstLaunch
{
    return [USER_DEFAULTS boolForKey:kRSCIsFirstLaunchSetting];
}

- (void) setIsFirstLaunch:(BOOL)isFirstLaunch
{
    [USER_DEFAULTS setBool:isFirstLaunch forKey:kRSCIsFirstLaunchSetting];
    [USER_DEFAULTS synchronize];
}


@end
