//  Created by Sean Heber on 4/22/10.
#import <Foundation/Foundation.h>

@interface NSURL (IFUnicodeURL)

// These two take a normal NSString that may (or may not) contain a URL with a non-ASCII host name.
// Normally NSURL doesn't work with these kinds of URLs (at least on iPhoneOS as of 3.2).
// This will decode them according to the various RFCs into the ASCII host name and return a normal NSURL
// object instance made with the converted host string in place of the unicode one.
// NOTE: These methods also sanitize the path/query by decoding and re-encoding any percent escaped stuff.
// NSURL doesn't normally do anything like that, but I found it handy to have.
+ (nullable NSURL *)URLWithUnicodeString:(nonnull NSString *)str;
- (nullable instancetype)initWithUnicodeString:(nonnull NSString *)str;

- (nullable instancetype)initWithUnicodeString:(nonnull NSString *)URLString relativeToURL:(nonnull NSURL *)baseURL;
+ (nullable instancetype)URLWithUnicodeString:(nonnull NSString *)URLString relativeToURL:(nonnull NSURL *)baseURL;


// This will return the same thing as NSURL's absoluteString method, but it converts the domain back into
// the unicode characters that a user would expect to see in a UI, etc.
- (nullable NSString *)unicodeAbsoluteString;

// Returns the same as NSURL's host method, but will convert it back into the unicode characters if possible.
- (nullable NSString *)unicodeHost;

@end
