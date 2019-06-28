require 'fcm'
module PushService
	class << self
		def send(user, title, body)
			if user.push_tokens.any?
				fcm = FCM.new("AAAAp136_-k:APA91bGQptDu33k_9T9St5BEvgmAlGPIsmvJU0zil-pK-ZSEN_xsWYCkSwRu3TcV78Fo9HPVUsTvLEETQeN8fSC4XYIIyli0be1bj09-XvuCnZ0M2ae8BUcrJ9sBboatA88Q9Eiv-2-e")
				message = {
					"notification": {
						"title": title,
						"body": body
					}
				}
				user.push_tokens.each do |push_token|
					response = fcm.send([push_token.token], message)
					response_body = JSON.parse(response[:body])
					status = response_body["success"].to_i == 1 ? :success : :fail
					push_token.destroy if status == :fail
					ApiLog.request({
						user_id: user.id,
			  		service: 'Firebase cloud message',
			  		request_method: :send_push,
			  		request_data: { push_id: push_token.id, message: message },
			  		response: { status: status, response: response_body },
					})
				end
			end
		end
	end
end