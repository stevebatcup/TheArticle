CarrierWave.configure do |config|
  config.ignore_processing_errors = true
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     Rails.application.credentials.aws[:access_key_id],
    aws_secret_access_key: Rails.application.credentials.aws[:secret_access_key],
    region:                'eu-west-2',
	  host:										's3-eu-west-2.amazonaws.com',
	  endpoint:								'https://s3-eu-west-2.amazonaws.com',
    path_style: 						true
  }
  config.fog_directory  = 'photos.thearticle.com'
end