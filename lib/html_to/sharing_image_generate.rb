class HtmlTo::SharingImageGenerate
  require 'erb'
  require 'sidekiq'
  include Sidekiq::Worker
  sidekiq_options queue: 'default'
  def perform(id, class_name)
    @obj = class_name.constantize.find(id)
    HtmlTo::HtmlHeadless.new.to_image(@obj)
  end
end
