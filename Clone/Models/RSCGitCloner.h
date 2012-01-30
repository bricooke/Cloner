
#import <Foundation/Foundation.h>

typedef enum {
    kRSCGitClonerErrorNone = 0,
    kRSCGitClonerErrorAuthenticationRequired,
    kRSCGitClonerErrorCloning
} kRSCGitClonerErrors;

typedef void (^RSCCloneBlock)(NSInteger);

@interface RSCGitCloner : NSObject

@property (nonatomic, strong) NSString *repositoryURL;
@property (nonatomic, strong) NSString *destinationPath;
@property (nonatomic, assign) BOOL didTerminate;
@property (nonatomic, copy) RSCCloneBlock progressBlock;
@property (nonatomic, copy) RSCCloneBlock completionBlock;


- (id) initWithRepositoryURL:(NSString *)aRepositoryURL;
- (void) cloneWithProgressBlock:(RSCCloneBlock)progressBlock andCompletionBlock:(RSCCloneBlock)completionBlock;
- (void) clone;

@end
