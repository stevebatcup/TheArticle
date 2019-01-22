class AccountSettingsController < ApplicationController
	before_action :authenticate_user!

	def edit
		respond_to do |format|
			format.html do
				sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.trending.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, sponsored_picks.first) if Author.sponsors.any?
			end
			format.json
		end
	end

	def update
		send_username_changed_email = (user_params[:username] != current_user.username)
		current_user.update(user_params)
		if current_user.save
			@status = :success
			UserMailer.username_updated(current_user).deliver_now if send_username_changed_email
		else
			@status = :error
			@message = current_user.errors.full_messages.first
		end
	end

	def update_password

		# sign_in(current_user, :bypass => true)
	end

	def update_email

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

	def user_params
		params.require(:user).permit(:title, :first_name, :last_name, :username)
	end
end