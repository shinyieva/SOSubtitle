Pod::Spec.new do |s|
    s.name         = 'SOSubtitle'
    s.version      = '0.1'
    s.license      =  {:type => 'MIT'}
    s.homepage     = 'https://github.com/shinyieva/SOSubtitle'
    s.authors      =  {'Sergio Ortega' => 'shinyieva@gmail.com'}
    s.summary      = 'SRT Subtitle parser for objective c.'

    # Source Info
    s.platform     =  :ios, '7.0'
    s.source       =  {:git => 'https://github.com/shinyieva/SOSubtitle', :tag => '0.1'}
    s.source_files = 'SOSubtitle'

    s.requires_arc = true

    # Pod Dependencies
    s.dependencies = 'OHHTTPStubs'

end