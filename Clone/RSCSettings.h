
#import <Foundation/Foundation.h>

#define RSC_SETTINGS ([[RSCSettings alloc] init])

@interface RSCSettings : NSObject
@property (nonatomic, assign) NSString *destinationPath;
@end
