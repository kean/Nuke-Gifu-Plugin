Pod::Spec.new do |s|
    s.name             = 'Nuke-Gifu-Plugin'
    s.version          = '3.0'
    s.summary          = 'Gifu plugin for Nuke that allows you to load and display animated GIFs'

    s.homepage         = 'https://github.com/kean/Nuke-Gifu-Plugin'
    s.license          = 'MIT'
    s.author           = 'Alexander Grebenyuk'
    s.source           = { :git => 'https://github.com/kean/Nuke-Gifu-Plugin.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/a_grebenyuk'

    s.ios.deployment_target = '9.0'

    s.module_name      = "NukeGifuPlugin"

    s.dependency 'Nuke', '~> 6.0'
    s.dependency 'Gifu', '~> 3.0'

    s.source_files  = 'Source/**/*'
end
