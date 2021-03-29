// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "IFUnicodeURL",
    products: [
        .library(
            name: "IFUnicodeURL",
            targets: ["IFUnicodeURL"]),
    ],
    targets: [
        .target(
            name: "IFUnicodeURL",
            dependencies: ["_IFUnicodeURL"],
            path: "IFUnicodeURL",
            sources: ["URL+IFUnicodeURL.swift"]),
        .target(
            name: "_IFUnicodeURL",
            path: "IFUnicodeURL",
            sources: [
                "NSURL+IFUnicodeURL.m",
                "IDNSDK/nameprep.c",
                "IDNSDK/puny.c",
                "IDNSDK/toxxx.c",
                "IDNSDK/util.c",
            ],
            publicHeadersPath: "IFUnicodeURL")
    ]
)
