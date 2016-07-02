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
    NSLog(@"** %@", URL);
    XCTAssertEqualObjects([URL absoluteString], expectedResult);
}

- (void)testNormalisedString:(NSString *)urlString equalsUnicodeString:(NSString *)expectedResult
{
    NSURL *URL = [NSURL URLWithUnicodeString:urlString];
    XCTAssertEqualObjects([URL unicodeAbsoluteString], expectedResult);
}

- (void)testUnicodeToNormalised
{
    [self testUnicodeString:@"http://exämple.com" equalsNormalisedString:@"http://xn--exmple-cua.com"];
    [self testUnicodeString:@"exämple.com" equalsNormalisedString:@"xn--exmple-cua.com"];
    [self testUnicodeString:@"exämple" equalsNormalisedString:@"xn--exmple-cua"];
}

- (void)testNormalisedToUnicode
{
    [self testNormalisedString:@"http://xn--exmple-cua.com/" equalsUnicodeString:@"http://exämple.com/"];
    [self testNormalisedString:@"http://example.com/" equalsUnicodeString:@"http://example.com/"];
    [self testNormalisedString:@"http://xn--exmple-cub.com/" equalsUnicodeString:@"http://xn--exmple-cub.com/"];
    [self testNormalisedString:@"http://www.xn--exmple-cua.com/" equalsUnicodeString:@"http://www.exämple.com/"];
    [self testNormalisedString:@"http://www.xn--exmple-cub.com/" equalsUnicodeString:@"http://www.xn--exmple-cub.com/"];

    NSURL* url = [NSURL URLWithUnicodeString:@"https://myusername:mypassword@www.jb💩.tk:92/%F0%9F%92%A9💩%F0%9F%92%A9/abc/💩/abc?💩=%F0%9F%92%A9&b=c"];
    XCTAssertEqualObjects(@"https://myusername:mypassword@www.xn--jb-9t72a.tk:92/%F0%9F%92%A9%F0%9F%92%A9%F0%9F%92%A9/abc/%F0%9F%92%A9/abc?%F0%9F%92%A9=%F0%9F%92%A9&b=c", [url absoluteString]);
}

- (void)testNil
{
    XCTAssertNil([NSURL URLWithUnicodeString:nil]);
    XCTAssertThrows([[NSURL alloc] initWithUnicodeString:nil]);
}


@end
