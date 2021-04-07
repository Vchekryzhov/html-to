module HtmlTo
  extend ActiveSupport::Concern
  require 'carrierwave'
  require 'html_to/html_headless.rb'
  require 'html_to/sharing_image_generate.rb'
  require 'html_to/share_uploader.rb'
  included do
    after_commit :share_image_generate, unless: :skip_share_image_generate
    attr_accessor :skip_share_image_generate


    raise 'Message from html_to: @@share_uploader not present' if class_variable_get(:@@share_uploader).nil?
    raise 'Message from html_to: @@share_template not present' if class_variable_get(:@@share_template).nil?
    raise "Message from html_to: share template file #{Rails.root.join('app/views').join(class_variable_get(:@@share_template)+'.html.erb')} not exist" if !File.exist?(Rails.root.join('app/views').join(class_variable_get(:@@share_template)+".html.erb"))
    mount_uploader class_variable_get(:@@share_uploader), -> { class_variable_get(:@@override_uploader) rescue HtmlTo::ShareUploader }.call
  end

  def share_image_generate
    SharingImageGenerate.perform_async(id, self.class.to_s)
  end

end
