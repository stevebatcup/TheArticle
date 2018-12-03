class ExchangeImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  version :listing do
    process resize_to_fill: [283, 212]

    def store_dir
      "app/#{Rails.env}/exchanges/#{model.id}"
    end
  end

  version :detail do
    process resize_to_fill: [180, 180]

    def store_dir
      "app/#{Rails.env}/exchanges/#{model.id}"
    end
  end

  def store_dir
    "app/#{Rails.env}/exchanges/#{model.id}"
  end
end
