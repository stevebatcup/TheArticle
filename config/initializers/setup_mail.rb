# ActionMailer::Base.smtp_settings = {
#   address: "smtp.gmail.com",
#   user_name: "steve.batcup@gmail.com",
#   password: "sonmi451%",
# 	domain: 'gmail.com',
#   authentication: 'plain',
#   enable_starttls_auto: true,
#   port: 587
# }

# class DevelopmentMailInterceptor
#   def self.delivering_email(message)
#     message.subject = "#{message.subject}"
#     message.to = "steve.batcup@gmail.com"
#   end
# end

# if Rails.env.development?
#   ActionMailer::Base.default_url_options[:host] = "localhost:3000"
#   Mail.register_interceptor(DevelopmentMailInterceptor)
# else
#   ActionMailer::Base.default_url_options[:host] = "www.thearticle.com"
# end