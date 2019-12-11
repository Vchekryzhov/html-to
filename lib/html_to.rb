module HtmlTo
  extend ActiveSupport::Concern
  require 'html_to/html_headless.rb'
  require 'html_to/sharing_image_generate.rb'
  included do
    after_commit :share_image_generate
  end

  def share_image_generate
    SharingImageGenerate.perform_async(id, self.class.to_s)
  end

end
