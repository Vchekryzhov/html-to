class HtmlTo::ShareUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  version :regular do
    process resize_to_limit: [1200, 630]
  end
end
