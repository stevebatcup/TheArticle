class AuthorImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  version :listing do
    process resize_to_fill: [212, 238]

    def store_dir
      "app/#{Rails.env}/authors/#{model.id}"
    end
  end

  version :detail do
    process resize_to_fill: [180, 180]

    def store_dir
      "app/#{Rails.env}/authors/#{model.id}"
    end
  end

  def store_dir
    "app/#{Rails.env}/authors/#{model.id}"
  end
end
