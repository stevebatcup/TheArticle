require 'fcm'
module PushService
	class << self
		def send(user, title, body, click_url='')
			if user.push_tokens.any?
				fcm = FCM.new(firebase_credentials[:messaging_server_key])
				message = {
					notification: {
						title: title,
						body: body,
						badge: user.notification_counter_cache,
						icon: "https://www.thearticle.com/firebase-logo.png",
						click_action: click_url
					},
					data: {
						uri: click_url,
						click_action: 'FLUTTER_NOTIFICATION_CLICK'
					}
				}
				user.push_tokens.each do |push_token|
					response = fcm.send([push_token.token], message)
					response_body = JSON.parse(response[:body])
					status = response_body["success"].to_i == 1 ? :success : :fail
					push_token.destroy if status == :fail
					ApiLog.request({
						user_id: user.id,
			  		service: 'Firebase cloud messaging',
			  		request_method: :send_push,
			  		request_data: { push_id: push_token.id, message: message },
			  		response: { status: status, response: response_body },
					})
				end
			end
		end

		def firebase_credentials
			Rails.application.credentials.firebase[Rails.env.to_sym]
		end
	end
end