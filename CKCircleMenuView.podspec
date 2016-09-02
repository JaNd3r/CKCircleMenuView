
Pod::Spec.new do |s|

  s.name         = "CKCircleMenuView"
  s.version      = "0.3.1"
  s.summary      = "An easy-to-integrate popup menu of round buttons placed on a circle."

  s.description  = <<-DESC
                   CKCircleMenuView adds an eye-catchy circle menu to your iOS app that
                   is as easy to use as an alert view. Appearance and behaviour can be
                   configured. Get notified via delegate call, which of the buttons got
                   activated.
                   DESC

  s.homepage     = "https://github.com/JaNd3r/CKCircleMenuView"
  s.screenshots  = "https://raw.githubusercontent.com/JaNd3r/CKCircleMenuView/master/CircleMenuDemo1.gif", "https://raw.githubusercontent.com/JaNd3r/CKCircleMenuView/master/CircleMenuDemo1.gif"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Christian Klaproth" => "ck@cm-works.de" }
  s.social_media_url   = "http://twitter.com/JaNd3r"

  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source       = { :git => "https://github.com/JaNd3r/CKCircleMenuView.git", :tag => "0.3.1" }

  s.source_files  = "CKCircleMenuView/*.{h,m}"

end
