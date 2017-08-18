//
//  TestIFUnicodeURL.m
//  KSFileUtilities
//
//  Created by Mike Abdullah on 12/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSURL+IFUnicodeURL.h"

@interface TestIFUnicodeURL : XCTestCase

@end

@implementation TestIFUnicodeURL

- (void)testUnicodeString:(NSString *)urlString equalsNormalisedString:(NSString *)expectedResult
{
    NSURL *URL = [NSURL URLWithUnicodeString:urlString];
    XCTAssertEqualObjects([URL absoluteString], expectedResult);
    URL = [[NSURL alloc] initWithUnicodeString:urlString];
    XCTAssertEqualObjects([URL absoluteString], expectedResult);
}

- (void) testURL:(NSURL*) URL withRelativeUnicodeUrlString:(NSString*) relativeUnicodeUrlString hasNormalisedString:(NSString*) expectedResult {
    NSURL* resultURL = [NSURL URLWithUnicodeString:relativeUnicodeUrlString relativeToURL:URL];
    NSString* resultURLString = [resultURL absoluteString];
    XCTAssertEqualObjects(resultURLString, expectedResult);
    resultURL = [[NSURL alloc] initWithUnicodeString:relativeUnicodeUrlString relativeToURL:URL];
    resultURLString = [resultURL absoluteString];
    XCTAssertEqualObjects(resultURLString, expectedResult);
}

- (void)testNormalisedString:(NSString *)urlString equalsUnicodeString:(NSString *)expectedResult
{
    NSURL *URL = [NSURL URLWithUnicodeString:urlString];
    XCTAssertEqualObjects([URL unicodeAbsoluteString], expectedResult);
}

- (void)testUnicodeToNormalised
{
    [self testUnicodeString:@"http://exämple.com" equalsNormalisedString:@"http://xn--exmple-cua.com"];
    [self testUnicodeString:@"http://exämple.com/?#" equalsNormalisedString:@"http://xn--exmple-cua.com/?#"];
    [self testUnicodeString:@"http://exämple.com/?" equalsNormalisedString:@"http://xn--exmple-cua.com/?"];
    [self testUnicodeString:@"http://exämple.com?" equalsNormalisedString:@"http://xn--exmple-cua.com?"];
    [self testUnicodeString:@"http://exämple.com#" equalsNormalisedString:@"http://xn--exmple-cua.com#"];
    [self testUnicodeString:@"http://a:b@exämple.com#" equalsNormalisedString:@"http://a:b@xn--exmple-cua.com#"];
    [self testUnicodeString:@"http://a@exämple.com#" equalsNormalisedString:@"http://a@xn--exmple-cua.com#"];
    [self testUnicodeString:@"http://💩:💩@exämple.com#" equalsNormalisedString:@"http://%F0%9F%92%A9:%F0%9F%92%A9@xn--exmple-cua.com#"];
    [self testUnicodeString:@"http://%61:%61@exämple.com#" equalsNormalisedString:@"http://a:a@xn--exmple-cua.com#"];
}

- (void)testNormalisedToUnicode
{
    [self testNormalisedString:@"http://xn--exmple-cua.com/" equalsUnicodeString:@"http://exämple.com/"];
    [self testNormalisedString:@"http://example.com/" equalsUnicodeString:@"http://example.com/"];
    [self testNormalisedString:@"http://xn--exmple-cub.com/" equalsUnicodeString:@"http://xn--exmple-cub.com/"];
    [self testNormalisedString:@"http://www.xn--exmple-cua.com/" equalsUnicodeString:@"http://www.exämple.com/"];
    [self testNormalisedString:@"http://www.xn--exmple-cub.com/" equalsUnicodeString:@"http://www.xn--exmple-cub.com/"];

    NSURL* url = [NSURL URLWithUnicodeString:@"https://myusername:mypassword@www.jb💩.tk:92/%3F%F0%9F%92%A9💩%F0%9F%92%A9/abc/💩/abc?💩=%F0%9F%92%A9&%3F=c"];
    XCTAssertEqualObjects(@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%3F%F0%9F%92%A9%F0%9F%92%A9%F0%9F%92%A9/abc/%F0%9F%92%A9/abc?%F0%9F%92%A9=%F0%9F%92%A9&?=c", [url absoluteString]);
    
    url = [NSURL URLWithUnicodeString:@"https://myusername:mypassword@www.jb💩.tk:92/💩=💩%20%2F%20%3F%20%23?💩=💩+%2F+%3F+%23#💩=💩+%2F+%3F+%23"];
    
    XCTAssertNotNil(url);
    XCTAssertEqual(url.port.integerValue, 92);
    XCTAssertEqualObjects(url.path, @"/💩=💩 / ? #");
    XCTAssertEqualObjects(url.query, @"%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23");
    XCTAssertEqualObjects(@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9=%F0%9F%92%A9%20/%20%3F%20%23?%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23#%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23", [url absoluteString]);
}

- (void) testRelativeURLs {
    NSURL* url = [NSURL URLWithUnicodeString:@"https://myusername:mypassword@www.jb💩.tk:92/💩/💩/💩/💩/=💩%20%2F%20%3F%20%23?💩=💩+%2F+%3F+%23#💩=💩+%2F+%3F+%23"];
    XCTAssertNotNil(url);
    XCTAssertEqualObjects(url.scheme, @"https");
    XCTAssertEqualObjects(url.user, @"myusername");
    XCTAssertEqualObjects(url.password, @"mypassword");
    XCTAssertEqualObjects(url.host, @"www.xn--jb-9t72a.tk");
    XCTAssertEqual(url.port.integerValue, 92);
    XCTAssertEqualObjects(url.path, @"/💩/💩/💩/💩/=💩 / ? #");
    XCTAssertEqualObjects(url.query, @"%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23");
    XCTAssertEqualObjects(url.fragment, @"%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23");
    
    XCTAssertEqualObjects([url absoluteString], @"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/=%F0%9F%92%A9%20/%20%3F%20%23?%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23#%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23");
    
    // Tests that do not require unicode in place.
    [self testURL:url withRelativeUnicodeUrlString:@"/foo/bar" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/foo/bar"];
    [self testURL:url withRelativeUnicodeUrlString:@"//www.goldenhillsoftware.com/a/b" hasNormalisedString:@"https://www.goldenhillsoftware.com/a/b"];
    [self testURL:url withRelativeUnicodeUrlString:@"http://www.goldenhillsoftware.com/a/b" hasNormalisedString:@"http://www.goldenhillsoftware.com/a/b"];
    [self testURL:url withRelativeUnicodeUrlString:@"../../foo/bar" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/foo/bar"];
    [self testURL:url withRelativeUnicodeUrlString:@"../../foo/bar?abc#def" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/foo/bar?abc#def"];
    [self testURL:url withRelativeUnicodeUrlString:@"?abc#def" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/=%F0%9F%92%A9%20/%20%3F%20%23?abc#def"];
    [self testURL:url withRelativeUnicodeUrlString:@"#xyz" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/=%F0%9F%92%A9%20/%20%3F%20%23?%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23#xyz"];

    [self testURL:url withRelativeUnicodeUrlString:@"/👍/bar" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%91%8D/bar"];

    [self testURL:url withRelativeUnicodeUrlString:@"//www.goldenhillsoftware.com/👍/b" hasNormalisedString:@"https://www.goldenhillsoftware.com/%F0%9F%91%8D/b"];
    [self testURL:url withRelativeUnicodeUrlString:@"//www.goldenhillsoftware.com:42/👍/b" hasNormalisedString:@"https://www.goldenhillsoftware.com:42/%F0%9F%91%8D/b"];
    [self testURL:url withRelativeUnicodeUrlString:@"//www.👍.com/👍/b" hasNormalisedString:@"https://www.xn--yp8h.com/%F0%9F%91%8D/b"];

    [self testURL:url withRelativeUnicodeUrlString:@"http://www.👍.com/👍/b" hasNormalisedString:@"http://www.xn--yp8h.com/%F0%9F%91%8D/b"];
    [self testURL:url withRelativeUnicodeUrlString:@"//👍👍:👍👍👍@www.goldenhillsoftware.com/👍/b" hasNormalisedString:@"https://%F0%9F%91%8D%F0%9F%91%8D:%F0%9F%91%8D%F0%9F%91%8D%F0%9F%91%8D@www.goldenhillsoftware.com/%F0%9F%91%8D/b"];
    [self testURL:url withRelativeUnicodeUrlString:@"//👍👍:👍👍👍@www.goldenhillsoftware.com:85/👍/b" hasNormalisedString:@"https://%F0%9F%91%8D%F0%9F%91%8D:%F0%9F%91%8D%F0%9F%91%8D%F0%9F%91%8D@www.goldenhillsoftware.com:85/%F0%9F%91%8D/b"];
    
    [self testURL:url withRelativeUnicodeUrlString:@"../../👍/bar" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%91%8D/bar"];
    [self testURL:url withRelativeUnicodeUrlString:@"../../foo/bar?👍#👍👍" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/foo/bar?%F0%9F%91%8D#%F0%9F%91%8D%F0%9F%91%8D"];
    [self testURL:url withRelativeUnicodeUrlString:@"?👍#👍👍" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/=%F0%9F%92%A9%20/%20%3F%20%23?%F0%9F%91%8D#%F0%9F%91%8D%F0%9F%91%8D"];
    [self testURL:url withRelativeUnicodeUrlString:@"#👍👍" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/=%F0%9F%92%A9%20/%20%3F%20%23?%F0%9F%92%A9=%F0%9F%92%A9+/+?+%23#%F0%9F%91%8D%F0%9F%91%8D"];

    [self testURL:url withRelativeUnicodeUrlString:@"👍👍" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/=%F0%9F%92%A9%20/%F0%9F%91%8D%F0%9F%91%8D"];
    [self testURL:url withRelativeUnicodeUrlString:@"👍👍/👍👍" hasNormalisedString:@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/%F0%9F%92%A9/=%F0%9F%92%A9%20/%F0%9F%91%8D%F0%9F%91%8D/%F0%9F%91%8D%F0%9F%91%8D"];

}

- (void) testJavaScriptUrl {
    NSURL* url = [NSURL URLWithString:@"https://m.youtube.com/watch?v=-yhs8sIF-8s"];
    [self testURL:url withRelativeUnicodeUrlString:@"javascript:\"\"" hasNormalisedString:@"javascript:%22%22"];
    [self testURL:url withRelativeUnicodeUrlString:@"javascript:" hasNormalisedString:@"javascript:"];
    [self testURL:url withRelativeUnicodeUrlString:@"javascript" hasNormalisedString:@"https://m.youtube.com/javascript"];
}

- (void)testNil {
    NSLog(@"encoded: %@", [@"a" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet controlCharacterSet]]);

}


@end
