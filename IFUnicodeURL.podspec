Pod::Spec.new do |spec|

  spec.name             = "IFUnicodeURL"
  spec.module_name      = "IFUnicodeURL"
  spec.version          = "0.0.1"
  spec.summary          = "IFUnicodeURL is a category for NSURL which will allow it to support Internationalized domain names in URLs."
  spec.description      = "IFUnicodeURL is a category for NSURL which will allow it to support Internationalized domain names in URLs."
  spec.homepage         = "https://github.com/jbrayton/ifunicodeurl"
  spec.license          = { :type => 'Copyright', :file => 'IFUnicodeURL-LICENSE.txt' }
  spec.authors          = [ "Sean Heber", "Karelia", "John Brayton" ]
  spec.source           = { :git => "https://github.com/jbrayton/IFUnicodeURL.git" }
  spec.platform         = :ios, 9.0
  spec.source_files     = "**/*.{c,h,m}"
  spec.frameworks       = [ 'Foundation' ]
  spec.exclude_files    = ["IFUnicodeURL/Tests", "IFUnicodeURL/UnitTests", "IDNSDK-1.1.0"]
  spec.requires_arc     = true
  spec.public_header_files   = 'IFUnicodeURL/NSURL+IFUnicodeURL.h'
end
