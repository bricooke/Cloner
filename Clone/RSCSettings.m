

#import "RSCSettings.h"

#define USER_DEFAULTS ([NSUserDefaults standardUserDefaults])
#define kRSCDestinationPathSetting (@"RSCDestinationPathSetting")
#define kRSCDestinationIsDownloads (@"RSCDestinationIsDownloads")

@implementation RSCSettings

+ (void) initialize
{
    NSError *error = nil;
                  
    NSString *downloadDir = [[[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error] path];
    [USER_DEFAULTS registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                     downloadDir, kRSCDestinationPathSetting,
                                     [NSNumber numberWithBool:YES], kRSCDestinationIsDownloads,
                                     nil]];
}

- (NSString *)destinationPath
{
    return [USER_DEFAULTS objectForKey:kRSCDestinationPathSetting];
}

- (void) setDestinationPath:(NSString *)destinationPath
{
    [USER_DEFAULTS setObject:destinationPath forKey:kRSCDestinationPathSetting];
}

- (BOOL) destinationIsDownloads
{
    return [USER_DEFAULTS boolForKey:kRSCDestinationIsDownloads];
}

- (void) setDestinationIsDownloads:(BOOL)destinationIsDownloads
{
    [USER_DEFAULTS setBool:destinationIsDownloads forKey:kRSCDestinationIsDownloads];
}

@end
