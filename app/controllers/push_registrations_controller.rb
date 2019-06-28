class PushRegistrationsController < ApplicationController
  def create
  	unless current_user.push_tokens.find_by(token: params[:subscription])
	    current_user.push_tokens << PushToken.new({
	    	token: params[:subscription],
	    	device: browser.device.name,
	    	browser: browser.name,
	    	created_at: Time.now
	    })
	    current_user.save
	  end
  end
end