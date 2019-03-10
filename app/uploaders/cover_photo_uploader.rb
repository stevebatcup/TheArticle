class CoverPhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  def filename
    "#{secure_token(10)}.jpg" if original_filename.present?
  end

  def store_dir
    "app/#{Rails.env}/users/cover-photo/#{model.id}"
  end

  version :desktop do
    process resize_to_fill: [1140, 228]

    def store_dir
      "app/#{Rails.env}/users/cover-photo/desktop/#{model.id}"
    end
  end

  version :mobile do
    process resize_to_fill: [750, 150]

    def store_dir
      "app/#{Rails.env}/users/cover-photo/mobile/#{model.id}"
    end
  end


  def fix_exif_rotation
    manipulate! do |img|
      img.tap(&:auto_orient)
    end
  end
  process :fix_exif_rotation

protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
end