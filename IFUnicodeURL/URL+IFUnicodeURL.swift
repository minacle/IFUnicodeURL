#if SWIFT_PACKAGE
import Foundation
import _IFUnicodeURL
#endif

extension URL {

    public struct IFUnicodeURL {

        internal let url: URL

        fileprivate init(_ url: URL) {
            self.url = url
        }

        fileprivate init?(_ url: URL?) {
            guard let url = url
            else {
                return nil
            }
            self.init(url)
        }

        public static func `init`(unicodeString: String) -> URL? {
            return Self(NSURL(unicodeString: unicodeString) as URL?)?.url
        }

        public static func `init`(unicodeString: String, relativeTo url: URL) -> URL? {
            return Self(NSURL(unicodeString: unicodeString, relativeTo: url) as URL?)?.url
        }

        public var unicodeAbsoluteString: String? {
            return (self.url as NSURL).unicodeAbsoluteString()
        }

        public var unicodeHost: String? {
            return (self.url as NSURL).unicodeHost()
        }
    }

    public var IFUnicodeURL: IFUnicodeURL {
        return .init(self)
    }
}
