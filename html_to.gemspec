require File.expand_path('lib/html_to/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'html_to'
  s.required_ruby_version = '>= 2.7'
  s.version = HtmlTo::VERSION
  s.summary = 'Html-To transforms html to image'
  s.description = 'Simple gem for transforms html page through chromium headless to image.'
  s.author = 'Chekryzhov Viktor'
  s.email = 'vchekryzhov@ya.ru'
  s.homepage = 'https://github.com/Vchekryzhov/html-to'
  s.license = 'MIT'
  s.files = Dir['README.md', 'LICENSE',
                'CHANGELOG.md', 'lib/**/*.rb',
                'lib/**/*.html.erb',
                'html_to.gemspec', '.github/*.md',
                'Gemfile', 'Rakefile']
  s.extra_rdoc_files = ['README.md']

  s.add_dependency 'activejob', '>= 5'
  s.add_dependency 'activestorage', '>= 5'
  s.add_dependency 'english'
  s.add_dependency 'erb'

  if ENV['TEST_RAILS_VERSION'].nil?
    s.add_development_dependency 'rails', '~> 7.0.6'
  else
    s.add_development_dependency 'rails', ENV['TEST_RAILS_VERSION'].to_s
  end
  s.metadata['rubygems_mfa_required'] = 'true'
end
