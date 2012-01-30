

#import "RSCGitCloner.h"
#import "RSCSettings.h"

@implementation RSCGitCloner

@synthesize repositoryURL   = _repositoryURL;
@synthesize destinationPath = _destinationPath;
@synthesize didTerminate = _didTerminate;
@synthesize progressBlock = _progressBlock;
@synthesize completionBlock = _completionBlock;


- (id) initWithRepositoryURL:(NSString *)aRepositoryURL
{
    if ((self = [super init])) {
        self.repositoryURL = aRepositoryURL;
        self.didTerminate = NO;
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


- (void) cloneWithProgressBlock:(RSCCloneBlock)aProgressBlock andCompletionBlock:(RSCCloneBlock)aCompletionBlock
{
    self.progressBlock = aProgressBlock;
    self.completionBlock = aCompletionBlock;
    [self clone];
}

- (void) clone 
{
    self.didTerminate = NO;
    [self translateRepositoryURLFromGithubURL];
    NSString *repoName = [[self.repositoryURL lastPathComponent] stringByDeletingPathExtension];
    self.destinationPath = [NSString stringWithFormat:@"%@/%@", [RSC_SETTINGS destinationPath], repoName];
    
    DLog(@"Cloning %@ to %@", self.repositoryURL, self.destinationPath);
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/git";
    task.arguments  = [NSArray arrayWithObjects:@"clone",
                       @"--progress",
                       self.repositoryURL,
                       self.destinationPath, 
                       nil];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardError:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
    
    [task launch];    

    NSError *error = nil;
    NSRegularExpression *usernameRegex = [NSRegularExpression regularExpressionWithPattern:@"Username:" options:0 error:&error];
    NSRegularExpression *progressRegex = [NSRegularExpression regularExpressionWithPattern:@"Receiving objects:\\s*(\\d+)%" options:NSRegularExpressionCaseInsensitive error:&error];

    // process stdout when ready
    void (^dataReadyBlock)(NSNotification *note) = ^(NSNotification *note) {
        NSData *readData = [file availableData];
        NSString *response = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        
        DLog(@"%@", response);
        
        // check for username prompt
        NSUInteger numberOfMatches = [usernameRegex numberOfMatchesInString:response options:0 range:NSMakeRange(0, [response length])];
        
        if (numberOfMatches > 0) {
            // prompting for username and password - kill the task and prompt the user
            self.didTerminate = YES;
            [task terminate];
            [task waitUntilExit];
            self.completionBlock(kRSCGitClonerErrorAuthenticationRequired);
            return;
        }
        
        // check for progress
        NSArray *matches = [progressRegex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
        NSTextCheckingResult *result = [matches lastObject];
        
        if (result) {
            NSString *reportAsString = [response substringWithRange:[result rangeAtIndex:1]]; // match '1' will be the (\\d)
            NSInteger progress = [reportAsString integerValue];
            self.progressBlock(progress);
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
        if (self.didTerminate == NO) {
            self.completionBlock(theTask.terminationStatus == 0 ? kRSCGitClonerErrorNone : kRSCGitClonerErrorCloning);
        }
    };
}

@end
