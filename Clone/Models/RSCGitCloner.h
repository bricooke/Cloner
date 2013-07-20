
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kRSCGitClonerErrors) {
    kRSCGitClonerErrorNone = 0,
    kRSCGitClonerErrorAuthenticationRequired,
    kRSCGitClonerErrorCloning
};

typedef void (^RSCCloneProgressBlock)(NSInteger progress);
typedef void (^RSCCloneCompletionBlock)(NSString *repositoryURL, NSString *destinationPath, kRSCGitClonerErrors errorCode);

@interface RSCGitCloner : NSObject

- (id)initWithRepositoryURL:(NSString *)aRepositoryURL;
- (void)cloneWithProgressBlock:(RSCCloneProgressBlock)progressBlock completionBlock:(RSCCloneCompletionBlock)completionBlock;

@end
