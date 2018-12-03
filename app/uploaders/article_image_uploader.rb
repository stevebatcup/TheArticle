class ArticleImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  version :carousel do
    process resize_to_fill: [590, 490]

    def store_dir
      "app/#{Rails.env}/articles/#{model.id}"
    end
  end

  version :listing_desktop do
    process resize_to_fill: [385, 190]

    def store_dir
      "app/#{Rails.env}/articles/#{model.id}"
    end
  end

  version :cover_desktop do
    process resize_to_fill: [910, 546]

    def store_dir
      "app/#{Rails.env}/articles/#{model.id}"
    end
  end

  version :inline_desktop do
    process resize_to_fill: [795, 540]

    def store_dir
      "app/#{Rails.env}/articles/#{model.id}"
    end
  end

  version :cover_mobile do
    process resize_to_fill: [700, 500]

    def store_dir
      "app/#{Rails.env}/articles/#{model.id}"
    end
  end

  version :listing_mobile do
    process resize_to_fill: [250, 250]

    def store_dir
      "app/#{Rails.env}/articles/#{model.id}"
    end
  end

  def store_dir
    "app/#{Rails.env}/articles/#{model.id}"
  end
end
