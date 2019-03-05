class ProfilePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog
  process :auto_orient

  def auto_orient
    manipulate! do |img|
      img.tap(&:strip)
      img.tap(&:auto_orient)
    end
  end

  def default_url(*args)
    ActionController::Base.helpers.asset_path("default-profile-set/" + [model.default_profile_photo_id, ".jpg"].compact.join)
  end

  def store_dir
    "app/#{Rails.env}/users/profile-photo/original/#{model.id}"
  end

  version :square do
    process :auto_orient
    process resize_to_fill: [150, 150]

    def store_dir
      "app/#{Rails.env}/users/profile-photo/square/#{model.id}"
    end
  end

end
