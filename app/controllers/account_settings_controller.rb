class AccountSettingsController < ApplicationController
	before_action :authenticate_basic_user

	def edit
		respond_to do |format|
			format.html do
				sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 1, :random)
				@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, sponsored_picks.first) if Author.sponsors.any?
			end
			format.json
		end
	end

	def update
		send_username_changed_email = false
		params_for_update = user_params.clone.to_hash
		if user_params[:username] && (user_params[:username] != current_user.username)
			send_username_changed_email = true
			params_for_update[:slug] = user_params[:username].downcase.gsub(/@/i, '')
		end
		if current_user.update(params_for_update)
			@status = :success
			UserMailer.username_updated(current_user).deliver_now if send_username_changed_email
			MailchimperService.update_mailchimp_list(current_user, current_user.email)
		else
			@status = :error
			@message = current_user.errors.full_messages.first
		end
	end

	def update_password
		if current_user.valid_password?(user_params[:existing_password])
			if current_user.update_attribute(:password, user_params[:new_password])
				sign_in(current_user, :bypass => true)
				UserMailer.password_change_confirmed(current_user).deliver_now
				@status = :success
			else
				@status = :error
				@message = "Unknown error updating your password, please try again"
			end
		else
			@status = :error
			@message = "You have entered your existing password incorrectly, please try again"
		end
	end

	def update_email
		if current_user.email == user_params[:email]
			@status = :success
		elsif (user = User.find_by(email: user_params[:email])) && (user != current_user)
			@status = :error
			@message = "Sorry a user with that email address already exists."
		else
			if current_user.update_attribute(:email, user_params[:email])
				@status = :success
			else
				@status = :error
				@message = "Unknown error updating your email address, please try again"
			end
		end
	end

	def deactivate
		if current_user.valid_password?(params[:auth])
			current_user.deactivate
			@status = :success
		else
			@status = :error
			@message = "You have entered an incorrect password, please try again"
		end
	end

	def reactivate
		if current_user.valid_password?(params[:auth])
			current_user.reactivate
			@status = :success
		else
			@status = :error
			@message = "You have entered an incorrect password, please try again"
		end
	end

	def destroy
		if current_user.valid_password?(params[:auth])
			if current_user.delete_account
				sign_out current_user
				@status = :success
			else
				@status = :error
				@message = "An unknown error occured whilst deleting your account."
			end
		else
			@status = :error
			@message = "You have entered an incorrect password, please try again"
		end
	end

private

	def hide_footer?
		true if browser.device.mobile? && params[:action] == 'edit'
	end

	def user_params
		params.require(:user).permit(:title, :first_name, :last_name, :username, :email, :existing_password, :new_password, :gender, :age_bracket)
	end
end