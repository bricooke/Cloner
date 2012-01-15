

#import "RSCGitCloner.h"
#import "RSCSettings.h"

@implementation RSCGitCloner

@synthesize repositoryURL   = _repositoryURL;
@synthesize destinationPath = _destinationPath;


- (id) initWithRepositoryURL:(NSString *)aRepositoryURL
{
    if ((self = [super init])) {
        self.repositoryURL = aRepositoryURL;
    }
    
    return self;
}


- (void) translateRepositoryURLFromGithubURL
{
    // 1st, is this necessary?
    if ([self.repositoryURL rangeOfString:@"https://github.com/"].location == NSNotFound)
        return;
    
    NSArray *comps = [self.repositoryURL pathComponents];
    if ([comps count] > 4) {
        self.repositoryURL = [NSString stringWithFormat:@"%@//%@/%@/%@.git", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2], [comps objectAtIndex:3]];
    }
}


- (void) main
{
    [self translateRepositoryURLFromGithubURL];
    NSString *repoName = [[self.repositoryURL lastPathComponent] stringByDeletingPathExtension];
    self.destinationPath = [NSString stringWithFormat:@"%@/%@", [RSC_SETTINGS destinationPath], repoName];
    
    NSLog(@"Cloning %@ to %@", self.repositoryURL, self.destinationPath);

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/git";
    task.arguments  = [NSArray arrayWithObjects:@"clone",
                       @"--progress",
                       self.repositoryURL,
                       self.destinationPath, 
                       nil];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardError:pipe];
    
    [task launch];
    
    NSFileHandle *file  = [pipe fileHandleForReading];
    // process stdout when ready
    void (^dataReadyBlock)(NSNotification *note) = ^(NSNotification *note) {
        NSData *readData = [file availableData];
        NSString *response = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"Receiving objects:\\s*(\\d+)%"
                                                                          options:NSRegularExpressionCaseInsensitive
                                                                            error:&error];
        
        NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
        NSTextCheckingResult *result = [matches lastObject];
        
        if (result) {
            NSString *reportAsString = [response substringWithRange:[result rangeAtIndex:1]]; // match '1' will be the (\\d)
            NSNumber *progress = [NSNumber numberWithInteger:[reportAsString integerValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRSCProgressReport object:progress];
        }
        
        if ([task isRunning]) {
            [file waitForDataInBackgroundAndNotify];
        }
    };

    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
                                                      object:file 
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:dataReadyBlock];
    
    [file waitForDataInBackgroundAndNotify];
    
    task.terminationHandler = ^(NSTask *theTask) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRSCCloneFinished 
                                                            object:self.destinationPath];
    };
}

@end
