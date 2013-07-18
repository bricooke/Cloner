
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kRSCGitClonerErrors) {
    kRSCGitClonerErrorNone = 0,
    kRSCGitClonerErrorAuthenticationRequired,
    kRSCGitClonerErrorCloning
};

typedef void (^RSCCloneProgressBlock)(NSInteger);
typedef void (^RSCCloneCompletionBlock)(kRSCGitClonerErrors);

@interface RSCGitCloner : NSObject

@property (nonatomic,strong) NSString *repositoryURL;
@property (nonatomic,strong) NSString *destinationPath;

- (id)initWithRepositoryURL:(NSString *)aRepositoryURL;
- (void)clone;
- (void)cloneWithProgressBlock:(RSCCloneProgressBlock)progressBlock completionBlock:(RSCCloneCompletionBlock)completionBlock;

@end
