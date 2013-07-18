
#import "RSCSettings.h"

static NSString *kRSCDestinationPathSetting = @"RSCDestinationPathSetting";
static NSString *kRSCIsFirstLaunchSetting   = @"RSCIsFirstLaunchSetting";

@implementation RSCSettings

#pragma mark - Class methods

+ (void) initialize
{
    NSError *error = nil;

    NSString *downloadDir = [[[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error] path];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             downloadDir, kRSCDestinationPathSetting,
                                                             [NSNumber numberWithBool:YES], kRSCIsFirstLaunchSetting,
                                                             nil]];
}

+ (RSCSettings *)sharedSettings
{
    static RSCSettings *_instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[RSCSettings alloc] init];
    });

    return _instance;
}

#pragma mark - Methods

- (NSString *)destinationPath
{
    return [self.userDefaults objectForKey:kRSCDestinationPathSetting];
}

- (BOOL) isFirstLaunch
{
    return [self.userDefaults boolForKey:kRSCIsFirstLaunchSetting];
}

- (void)setBool:(BOOL)aBool forKey:(NSString *)key
{
    [self.userDefaults setBool:aBool forKey:key];
    [self.userDefaults synchronize];
}

- (void) setDestinationPath:(NSString *)destinationPath
{
    [self setValue:destinationPath forKey:kRSCDestinationPathSetting];
}

- (void) setIsFirstLaunch:(BOOL)isFirstLaunch
{
    [self setBool:isFirstLaunch forKey:kRSCIsFirstLaunchSetting];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [self.userDefaults setValue:value forKey:key];
    [self.userDefaults synchronize];
}

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}


@end
