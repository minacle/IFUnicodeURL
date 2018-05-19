//  Created by Sean Heber on 4/22/10.
#import "NSURL+IFUnicodeURL.h"
#import "IDNSDK/xcode.h"

@implementation NSString (IFUnicodeURLHelpers)
- (NSArray *)IFUnicodeURL_splitAfterString:(NSString *)string
{
	NSString *firstPart;
	NSString *secondPart;
	NSRange range = [self rangeOfString:string];
	
	if (range.location != NSNotFound) {
		NSUInteger index = range.location+range.length;
		firstPart = [self substringToIndex:index];
		secondPart = [self substringFromIndex:index];
	} else {
		firstPart = @"";
		secondPart = self;
	}
	
	return [NSArray arrayWithObjects:firstPart, secondPart, nil];
}

- (NSArray *)IFUnicodeURL_splitBeforeString:(NSString *)string
{
    NSString *firstPart;
    NSString *secondPart;
    NSRange range = [self rangeOfString:string];
    
    if (range.location != NSNotFound) {
        NSUInteger index = range.location;
        firstPart = [self substringToIndex:index];
        secondPart = [self substringFromIndex:index];
    } else {
        firstPart = self;
        secondPart = @"";
    }
    
    return [NSArray arrayWithObjects:firstPart, secondPart, nil];
}
@end

static NSString *ConvertUnicodeDomainString(NSString *hostname, BOOL toAscii)
{
	const UTF16CHAR *inputString = (const UTF16CHAR *)[hostname cStringUsingEncoding:NSUTF16StringEncoding];
	int inputLength = (int)([hostname lengthOfBytesUsingEncoding:NSUTF16StringEncoding] / sizeof(UTF16CHAR));
	
	if (toAscii) {
		int outputLength = MAX_DOMAIN_SIZE_8;
		UCHAR8 outputString[outputLength];
		
		if (XCODE_SUCCESS == Xcode_DomainToASCII(inputString, inputLength, outputString, &outputLength)) {
			hostname = [[NSString alloc] initWithBytes:outputString length:outputLength encoding:NSASCIIStringEncoding];
		}
	} else {
		int outputLength = MAX_DOMAIN_SIZE_16;
		UTF16CHAR outputString[outputLength];
		if (XCODE_SUCCESS == Xcode_DomainToUnicode16(inputString, inputLength, outputString, &outputLength)) {
			hostname = [[NSString alloc] initWithCharacters:outputString length:outputLength];
		}
	}
	
	return hostname;
}

/*
    Percent-encodes string using the specified allowedCharacterSet. Assumes that the first character is a
    one-character long delimiter and does not encode that. Returns the original string if it is blank or 
    one character long.
 */
static NSString* reencode(NSString* string, NSCharacterSet* allowedCharacterSet) {
    if ([string length] < 2) {
        return string;
    }
    NSString* toEncode = [[string substringFromIndex:1] stringByRemovingPercentEncoding];
    NSString* encoded = [toEncode stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    return [NSString stringWithFormat:@"%@%@", [string substringToIndex:1], encoded];
}

static NSString *ConvertUnicodeURLString(NSString *str)
{
    BOOL hasHost = NO;
    
	NSString *hostname = nil;
	NSArray *parts = nil;
    
    NSString* schemeAndColonComponent = @"";
    NSString* slashSlashComponent = @"";
    NSString* pathComponent = @"";
    NSString* queryComponent = @"";
    NSString* fragmentComponent = @"";
    NSString* usernameComponent = @"";
    NSString* passwordComponent = @"";
    NSString* atAfterUsernamePasswordComponent = @"";
    NSString* portNumberComponent = @"";
    
	
	parts = [str IFUnicodeURL_splitAfterString:@":"];
    if ([parts[0] isEqualToString:@"javascript:"]) {
        NSString* remainder = [[parts[1] stringByRemovingPercentEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        return [NSString stringWithFormat:@"javascript:%@", remainder];
    }
    if ([parts[1] rangeOfString:@"//"].location == 0) {
        hostname = [parts objectAtIndex:1];
        schemeAndColonComponent = [parts objectAtIndex:0];
    } else {
        hostname = str;
    }
	
    if ([hostname rangeOfString:@"//"].location == 0) {
        hasHost = YES;
    }
    
    if (hasHost) {
        parts = [hostname IFUnicodeURL_splitAfterString:@"//"];
        hostname = [parts objectAtIndex:1];
        slashSlashComponent = [parts objectAtIndex:0];
        
        parts = [hostname IFUnicodeURL_splitAfterString:@"@"];
        hostname = [parts objectAtIndex:1];
        NSString* usernameAndPasswordComponent = [parts objectAtIndex:0];
        if ([usernameAndPasswordComponent length] > 0) {
            usernameAndPasswordComponent = [usernameAndPasswordComponent substringToIndex:[usernameAndPasswordComponent length]-1];
            atAfterUsernamePasswordComponent = @"@";
            parts = [usernameAndPasswordComponent IFUnicodeURL_splitBeforeString:@":"];
            // I don't call reencode(...) on the username because it does not include its preceding delimiter
            usernameComponent = [[parts[0] stringByRemovingPercentEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
            passwordComponent = reencode(parts[1], [NSCharacterSet URLPasswordAllowedCharacterSet]);
        }
    }

    parts = [hostname IFUnicodeURL_splitBeforeString:@"#"];
	hostname = [parts objectAtIndex:0];
    fragmentComponent = reencode(parts[1], [NSCharacterSet URLFragmentAllowedCharacterSet]);
    
    parts = [hostname IFUnicodeURL_splitBeforeString:@"?"];
    hostname = [parts objectAtIndex:0];
    queryComponent = reencode(parts[1], [NSCharacterSet URLQueryAllowedCharacterSet]);
    
    if (hasHost) {
        parts = [hostname IFUnicodeURL_splitBeforeString:@"/"];
        hostname = [parts objectAtIndex:0];
        pathComponent = reencode(parts[1], [NSCharacterSet URLPathAllowedCharacterSet]);
        
        parts = [hostname IFUnicodeURL_splitBeforeString:@":"];
        hostname = [parts objectAtIndex:0];
        portNumberComponent = [parts objectAtIndex:1];
    } else {
        NSString* hostnameWithoutPercentEncoding = [hostname stringByRemovingPercentEncoding];
        if (!hostnameWithoutPercentEncoding) {
            hostnameWithoutPercentEncoding = hostname;
        }
        pathComponent = [hostnameWithoutPercentEncoding stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        hostname = @"";
    }
	
	// Now that we have isolated just the hostname, do the magic decoding...
	hostname = ConvertUnicodeDomainString(hostname, YES);
		
	// Now recreate the URL safely with the new hostname (if it was successful) instead...
	NSArray *reconstructedArray = @[schemeAndColonComponent, slashSlashComponent, usernameComponent, passwordComponent, atAfterUsernamePasswordComponent, hostname, portNumberComponent, pathComponent, queryComponent, fragmentComponent];
	NSString *reconstructedURLString = [reconstructedArray componentsJoinedByString:@""];

	return reconstructedURLString;
}



@implementation NSURL (IFUnicodeURL)
+ (nullable NSURL *)URLWithUnicodeString:(nonnull NSString *)str
{
    if (!str) return nil;   // mimic +URLWithString:'s present behaviour
	return [[self alloc] initWithUnicodeString:str];
}

- (nullable instancetype)initWithUnicodeString:(nonnull NSString *)str
{
	return [self initWithString:ConvertUnicodeURLString(str)];
}

- (nullable instancetype)initWithUnicodeString:(nonnull NSString *)URLString relativeToURL:(nonnull NSURL *)baseURL {
    return [self initWithString:ConvertUnicodeURLString(URLString) relativeToURL:baseURL];
}

+ (nullable instancetype)URLWithUnicodeString:(nonnull NSString *)URLString relativeToURL:(nonnull NSURL *)baseURL {
    return [[NSURL alloc] initWithUnicodeString:ConvertUnicodeURLString(URLString) relativeToURL:baseURL];
}


- (NSString *)unicodeAbsoluteString
{
    // Make sure we're working with an absolute URL
    CFURLRef absoluteURL = CFURLCopyAbsoluteURL((CFURLRef)self);
    
    // Can bail out early if there's no hostname to decode
    CFRange hostRange = CFURLGetByteRangeForComponent(absoluteURL, kCFURLComponentHost, NULL);
    if (hostRange.location == kCFNotFound)
    {
        CFRelease(absoluteURL);
        return [self absoluteString];
    }
    
    // Grab the raw URL data
    CFIndex length = CFURLGetBytes(absoluteURL, NULL, 0);
    NSMutableData *buffer = [[NSMutableData alloc] initWithLength:length];
    CFURLGetBytes(absoluteURL, [buffer mutableBytes], length);
    CFRelease(absoluteURL);
    
    // Grab the host
    NSString *host = [[NSString alloc] initWithBytes:([buffer bytes] + hostRange.location)
                                              length:hostRange.length
                                            encoding:NSUTF8StringEncoding];
    
    // Decode it
    NSString *unicodeHost = ConvertUnicodeDomainString(host, NO);
    
    // Swap in the decoded data
    if (![unicodeHost isEqualToString:host])
    {
        NSData *unicodeHostData = [unicodeHost dataUsingEncoding:NSUTF8StringEncoding];
        
        [buffer replaceBytesInRange:NSMakeRange(hostRange.location, hostRange.length)
                          withBytes:[unicodeHostData bytes]
                             length:[unicodeHostData length]];
    }
    
    // Bundle the result up as a string to finish
    NSString *result = [[NSString alloc] initWithBytes:[buffer bytes] length:[buffer length] encoding:NSUTF8StringEncoding];
    return result;
}

- (NSString *)unicodeHost
{
	return ConvertUnicodeDomainString([self host], NO);
}

@end
