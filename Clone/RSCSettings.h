
#import <Foundation/Foundation.h>

@interface RSCSettings : NSObject

@property (nonatomic,assign) NSString *destinationPath;
@property (nonatomic,assign) BOOL isFirstLaunch;

+ (RSCSettings *)sharedSettings;

@end
