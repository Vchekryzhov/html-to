class HtmlTo::ShareUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  def store_dir
    "storage/#{model.class.base_class.name.underscore}/#{model.id}/share"
  end
  process resize_to_limit: [1200, 630]
end
