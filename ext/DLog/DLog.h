
#ifndef Ringtones_DLog_h
#define Ringtones_DLog_h

#import "NSDate+Format.h"

#define CLog(...) (void)printf("%s %s\n", [[[NSDate date] consoleDateString] UTF8String], [[NSString stringWithFormat:__VA_ARGS__] UTF8String])

// Almost a drop-in replacement for NSLog
// DLog();
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); 
// You have to do this instead DLog(@"%@", aStringVariable);
#ifdef DEBUG
#define DLog(fmt, ...) CLog((@"%s Line %d: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define ALog(fmt, ...) CLog((@"%s Line %d: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...) // ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s[%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DAlert(...)
#define NS_BLOCK_ASSERTIONS // Don't raise assertions in production
#endif

#endif
