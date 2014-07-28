Pod::Spec.new do |s|
  s.name         = "MPGNotification"
  s.version      = "1.1.1"
  s.summary      = "MPGNotifications is an iOS control that allows you to display customizable in-app interactive notifications."
  s.homepage     = "https://github.com/MPGNotification/MPGNotification"
  s.screenshots  = "https://s3.amazonaws.com/evilapples/stash/MPGNotification.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { 'Sean Conrad' => 'toblerpwn@gmail.com', 'Gaurav Wadhwani' => 'http://gww.mappgic.com/' }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/MPGNotification/MPGNotification.git", :tag => 1.1.1 }
  s.source_files  = "Objective-C/MPGNotification/*"
  s.requires_arc = true
end
