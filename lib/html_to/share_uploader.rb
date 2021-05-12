class HtmlTo::ShareUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  def store_dir
    "storage/#{model.class.base_class.name.underscore}/#{model.id}/share"
  end

  def url
    "#{Rails.application.config.asset_host}#{super}"
  end
  process resize_to_limit: [1200, 630]
end
