
@interface NSDate(Format)

+(NSDateFormatter*) rfc822Formatter;
+(NSDate*) dateFromRFC822:(NSString*)date;

+(NSDate *) dateFromRFC1123String: (NSString *) dateString;

-(NSString*) descriptionWithFormat:(NSString*)stringFormat timeZone:(NSString*)aZone locale:(NSString*)aLocale;
-(NSString*) descriptionWithFormat:(NSString *)stringFormat;
-(NSString*) consoleDateString;
-(NSString*) rfc822DateString;

@end
