module HtmlTo
  extend ActiveSupport::Concern
  require 'carrierwave'
  require 'html_to/html_headless.rb'
  require 'html_to/sharing_image_generate.rb'
  require 'html_to/share_uploader.rb'
  included do
    after_commit :share_image_generate, unless: :skip_share_image_generate
    attr_accessor :skip_share_image_generate
    mount_uploader class_variable_get(:@@share_uploader), HtmlTo::ShareUploader
  end

  def share_image_generate
    SharingImageGenerate.perform_async(id, self.class.to_s)
  end

end
