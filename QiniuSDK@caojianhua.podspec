Pod::Spec.new do |s|
  s.name     = 'QiniuSDK@caojianhua'
  s.version  = '6.3.2'
  s.license  = 'MIT'
  s.summary  = 'Qiniu SDK based on for AFNetworking'
  s.homepage = 'https://github.com/caojianhua1741/ios-sdk'
  s.authors  = { 'caojianhua' => 'caojianhua1741@gmail.com' }
  s.source   = { :git => 'https://github.com/caojianhua1741/ios-sdk.git', :tag => 'v6.3.2' }
  s.source_files = 'QiniuSDK'
  s.requires_arc = true
  s.ios.deployment_target = '6.0'

  s.dependency 'AFNetworking', '~> 2.3.1'
end
