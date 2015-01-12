Pod::Spec.new do |s|
    s.name         = 'SOSubtitle'
    s.version      = '0.6'
    s.license      =  { :type => "Affero GNU GPL v3", :file => "LICENSE.txt" }
    s.homepage     = 'http://github.com/shinyieva/SOSubtitle'
    s.authors      =  {'Sergio Ortega' => 'shinyieva@gmail.com'}
    s.summary      = 'SRT Subtitle parser for objective c.'

    # Source Info
    s.platform     =  :ios, '7.0'
    s.source       =  {:git => 'https://github.com/shinyieva/SOSubtitle.git', :tag => '0.6'}
    s.source_files = 'SOSubtitle'

    s.requires_arc = true

    s.dependency 'MMMarkdown', '~> 0.4'
    s.dependency 'Bolts', '~> 1.0'
end