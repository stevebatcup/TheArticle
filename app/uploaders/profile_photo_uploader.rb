class ProfilePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  def filename
    "#{secure_token(10)}.jpg" if original_filename.present?
  end

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

protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
end
