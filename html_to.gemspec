$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'html_to'
  s.version     = '0.0.2'
  s.date        = '2019-08-31'
  s.summary     = 'Html-To transforms html to other format'
  s.description = 'Simple gem for transforms html page through chromium headless.'
  s.author      = 'Chekryzhov Viktor'
  s.email       = 'chekryzhov@charmerstudio.com'
  s.homepage    = 'https://github.com/Vchekryzhov/html-to'
  s.license     = 'MIT'
  s.files       = `git ls-files`.split("\n")
  s.add_dependency 'sidekiq'
  s.add_dependency 'carrierwave'
end
