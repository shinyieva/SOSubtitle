Pod::Spec.new do |s|
  s.name         = 'SOSubtitle'
  s.version      = '0.1'
  s.license      =  :type => '<#License#>'
  s.homepage     = '<#Homepage URL#>'
  s.authors      =  'Sergio Ortega' => 'shinyieva@gmail.com'
  s.summary      = 'SRT Subtitle parser for objective c.'

# Source Info
  s.platform     =  :ios, '7.0'
  s.source       =  :git => '<#Github Repo URL#>', :tag => '<#Tag name#>'
  s.source_files = 'SOSubtitle'

  s.requires_arc = true
  
# Pod Dependencies
  s.dependencies =	pod 'OHHTTPStubs'

end