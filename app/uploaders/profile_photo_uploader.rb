class ProfilePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog
  # process :auto_orient

  def auto_orient
    manipulate! do |img|
      img = img.strip
      img = img.auto_orient
      img
    end
  end

  def default_url(*args)
    ActionController::Base.helpers.asset_path("default-profile-set/" + [model.default_profile_photo_id, ".jpg"].compact.join)
  end

  def store_dir
    "app/#{Rails.env}/users/profile-photo/original/#{model.id}"
  end

  version :square do
    process resize_to_fill: [150, 150]
    process :auto_orient

    def store_dir
      "app/#{Rails.env}/users/profile-photo/square/#{model.id}"
    end
  end

end
