Pod::Spec.new do |s|
  s.name         = "AgoraSignalSDK"
  s.version      = "1.1.1.2"
  s.summary      = "AgoraSignalSDK."
  s.description  = <<-DESC
  声网agora.io信令 SDK 
                   DESC
  s.homepage     = "https://www.agora.io"
  s.license      = "MIT"
  s.author       = { "自娱自乐" => "wapznw@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "http://github.com/wapznw/AgoraSignalSDK.git", :tag => "v#{s.version}" }
  s.source_files  = "AgoraSignalSDK/signal/*.{h,m}"
  s.library   = "c++"
  s.vendored_library = "AgoraSignalSDK/signal/libagora_fat.a"
end
