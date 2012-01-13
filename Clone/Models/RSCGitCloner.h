
#import <Foundation/Foundation.h>

@interface RSCGitCloner : NSOperation

@property (nonatomic, strong) NSString *repositoryURL;
@property (nonatomic, strong) NSString *destinationPath;

- (id) initWithRepositoryURL:(NSString *)aRepositoryURL andDestinationPath:(NSString *)aFilePath;

@end
