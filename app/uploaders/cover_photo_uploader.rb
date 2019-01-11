class CoverPhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  # def default_url(*args)
  #    ActionController::Base.helpers.asset_path("default-profile-set/" + [model.default_profile_photo_id, ".jpg"].compact.join)
  #  end

  def store_dir
    "app/#{Rails.env}/users/cover-photo/#{model.id}"
  end

  version :desktop do
    process resize_to_fill: [1140, 220]

    def store_dir
      "app/#{Rails.env}/users/cover-photo/desktop/#{model.id}"
    end
  end

  version :mobile do
    process resize_to_fill: [750, 250]

    def store_dir
      "app/#{Rails.env}/users/cover-photo/mobile/#{model.id}"
    end
  end
end
