#import "RSCGitCloner.h"
#import "RSCSettings.h"

@interface RSCGitCloner()

@property(nonatomic,strong) NSString *branch;
@property(nonatomic,copy) RSCCloneCompletionBlock completionBlock;
@property(nonatomic,assign) BOOL didTerminate;
@property(nonatomic,copy) RSCCloneProgressBlock progressBlock;

@end

@implementation RSCGitCloner

#pragma mark - Lifecycle

- (id)initWithRepositoryURL:(NSString *)aRepositoryURL
{
    if ((self = [super init])) {
        self.repositoryURL = aRepositoryURL;
        self.didTerminate = NO;
    }
    
    return self;
}

#pragma mark - Methods

- (void)checkoutBranch
{
    NSTask *task = [[NSTask alloc] init];
    task.currentDirectoryPath = self.destinationPath;
    task.launchPath = @"/usr/bin/git";
    task.arguments  = @[ @"checkout", self.branch];

    [task setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    [task setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
    [task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];

    [task launch];

    [task waitUntilExit];
}

- (void)clone
{
    self.didTerminate = NO;
    [self translateRepositoryURLFromGithubURL];
    NSString *repoName = [[self.repositoryURL lastPathComponent] stringByDeletingPathExtension];
    self.destinationPath = [NSString stringWithFormat:@"%@/%@", [[RSCSettings sharedSettings] destinationPath], repoName];
    
    DLog(@"Cloning %@ to %@", self.repositoryURL, self.destinationPath);
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/git";
    task.arguments  = @[ @"clone", @"--progress", self.repositoryURL, self.destinationPath ];
    
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
            if (theTask.terminationStatus == 0 && self.branch) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self checkoutBranch];
                });
            }

            self.completionBlock(theTask.terminationStatus == 0 ? kRSCGitClonerErrorNone : kRSCGitClonerErrorCloning);
        }
    };
}

- (void)cloneWithProgressBlock:(RSCCloneProgressBlock)aProgressBlock completionBlock:(RSCCloneCompletionBlock)aCompletionBlock
{
    self.progressBlock = aProgressBlock;
    self.completionBlock = aCompletionBlock;

    [self clone];
}

- (void)translateRepositoryURLFromGithubURL
{
    // 1st, is this necessary?
    if ([self.repositoryURL rangeOfString:@"https://github.com/"].location == NSNotFound)
        return;

    NSArray *comps = [self.repositoryURL pathComponents];
    if (comps.count > 4) {
        self.repositoryURL = [NSString stringWithFormat:@"%@//%@.git", comps[0], [[comps subarrayWithRange:NSMakeRange(1, 3)] componentsJoinedByString:@"/"]];
    }

    if (comps.count >= 6) {
        if ([comps[4] isEqualToString:@"tree"]) {
            self.branch = comps[5];
        }
    }
}

@end
