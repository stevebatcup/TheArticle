class ProfilePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

  def default_url(*args)
     ActionController::Base.helpers.asset_path("default-profile-set/" + [model.default_profile_photo_id, ".jpg"].compact.join)
   end

  def store_dir
    "app/#{Rails.env}/users/profile-photo/original/#{model.id}"
  end

  version :square do
    process resize_to_fill: [150, 150]

    def store_dir
      "app/#{Rails.env}/users/profile-photo/square/#{model.id}"
    end
  end
end