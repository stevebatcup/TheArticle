class ProfilePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

  def default_url(*args)
     ActionController::Base.helpers.asset_path("default-profile-set/" + [model.default_profile_photo_id, ".jpg"].compact.join)
   end

  def store_dir
    "app/#{Rails.env}/users/profile-photo/#{model.id}"
  end

  version :square do
    process resize_to_fill: [120, 120]

    def store_dir
      "app/#{Rails.env}/users/profile-photo/#{model.id}"
    end
  end
end
