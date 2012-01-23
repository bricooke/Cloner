// 
// Extention to allow simple date formatting for 
// applications such as printing to the console.
//
// Formatting References:
// http://developer.apple.com/documentation/Darwin/Reference/ManPages/man3/strftime.3.html
// http://www.stepcase.com/blog/2008/12/02/format-string-for-the-iphone-nsdateformatter/
//

#import "NSDate+Format.h"

static NSDateFormatter *__rfc822Formatter = nil;
static NSDateFormatter *__rfc1123Formatter = nil;


@implementation NSDate (Format)

+(NSDateFormatter*) rfc822Formatter 
{
    if (!__rfc822Formatter) {
        __rfc822Formatter = [[NSDateFormatter alloc] init];
        NSLocale *enUS = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        [__rfc822Formatter setLocale: enUS];
        [__rfc822Formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    }
    return __rfc822Formatter;
}


+(NSDate*) dateFromRFC822:(NSString*)date 
{
    return [[self rfc822Formatter] dateFromString: date];
}


+(NSDateFormatter *) rfc1123Formatter
{
    if (!__rfc1123Formatter) {
        __rfc1123Formatter = [[NSDateFormatter alloc] init];
        NSLocale *enUS = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        [__rfc1123Formatter setLocale: enUS];
        [__rfc1123Formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    }
    return __rfc1123Formatter;
}


+(NSDate *) dateFromRFC1123String: (NSString *) string
{
    NSDateFormatter *formatter = [self rfc1123Formatter];
    
	// Does the string include a week day?
	NSString *day = @"";
	if ([string rangeOfString:@","].location != NSNotFound) {
		day = @"EEE, ";
	}
	// Does the string include seconds?
	NSString *seconds = @"";
	if ([[string componentsSeparatedByString:@":"] count] == 3) {
		seconds = @":ss";
	}
	[formatter setDateFormat:[NSString stringWithFormat:@"%@dd MMM yyyy HH:mm%@ z",day,seconds]];
	return [formatter dateFromString:string];
}


-(NSString*) descriptionWithFormat:(NSString*)stringFormat timeZone:(NSString*)aZone locale:(NSString*)aLocale 
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:stringFormat];
    return [formatter stringFromDate:self];
}


-(NSString*) descriptionWithFormat:(NSString *)stringFormat
{
  return [self descriptionWithFormat:stringFormat timeZone:nil locale:nil];
}


-(NSString*) rfc822DateString
{
  return [self descriptionWithFormat:@"dd MMM yyyy HH:mm:ss z" timeZone:nil locale:nil];
}


-(NSString*) consoleDateString
{
  return [self descriptionWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS" timeZone:nil locale:nil];
}

@end