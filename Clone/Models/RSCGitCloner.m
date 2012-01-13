

#import "RSCGitCloner.h"

@implementation RSCGitCloner

@synthesize repositoryURL   = _repositoryURL;
@synthesize destinationPath = _destinationPath;


- (id) initWithRepositoryURL:(NSString *)aRepositoryURL andDestinationPath:(NSString *)aFilePath
{
    if ((self = [super init])) {
        self.repositoryURL      = aRepositoryURL;
        self.destinationPath    = aFilePath;
    }
    
    return self;
}


- (void) main
{
    NSLog(@"Cloning %@ to %@", self.repositoryURL, self.destinationPath);
    
    __block NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" 
                                                    arguments:[NSArray arrayWithObjects:
                                                               @"clone",
                                                               self.repositoryURL,
                                                               self.destinationPath, 
                                                               nil]];
    
    task.terminationHandler = ^(NSTask *theTask) {
        NSLog(@"Finished! %d", theTask.terminationStatus);
    };
}

@end
