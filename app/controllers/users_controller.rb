class UsersController < ApplicationController
	before_action :authenticate_user!, except: [:show]

	def show
		if params[:me]
			authenticate_user!
			@user = current_user
		elsif params[:identifier] == :slug
			if viewing_from_admin
				@user = User.find_by(slug: params[:slug])
			else
				@user = User.active.find_by(slug: params[:slug])
			end
		elsif params[:identifier] == :id
			if viewing_from_admin
				@user = User.find_by(id: params[:id])
			else
				@user = User.active.find_by(id: params[:id])
			end
		end

		unless viewing_from_admin
			if (@user == current_user) && !params[:me]
				return redirect_to_my_profile
			elsif @user.nil? || !@user.has_active_status?
				flash[:notice] = "That profile is unavailable"
				return redirect_to_my_profile
			end
		end

		respond_to do |format|
			format.html do
				if params[:identifier] == :id
					redirect_to profile_path(slug: @user.slug)
				else
					@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 1, :random)
					@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
					@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				end
			end
			format.json
		end
	end

	def update_photo
		if params[:mode] == 'coverPhoto'
			current_user.cover_photo = params[:photo]
			if current_user.save
				@status = :success
			else
				@status = :error
				@message = current_user.errors.full_messages.first
			end
		elsif params[:mode] == 'profilePhoto'
			current_user.profile_photo = params[:photo]
			if current_user.save
				@status = :success
			else
				@status = :error
				@message = current_user.errors.full_messages.first
			end
		end
	end

	def update
		send_username_changed_email = false
		params_for_update = params[:profile].clone
		if params[:profile][:username] && (params[:profile][:username] != current_user.username)
			send_username_changed_email = true
			params_for_update[:slug] = params[:profile][:username].downcase.gsub(/@/i, '')
		else
			params_for_update[:slug] = current_user.slug
		end
		if current_user.update_attributes({
				display_name: params_for_update[:display_name],
				username: params_for_update[:username],
				slug: params_for_update[:slug],
		    location: params_for_update[:location][:public],
		    private_location: params_for_update[:location][:private],
		    lat: params_for_update[:location][:lat],
		    lng: params_for_update[:location][:lng],
		    country_code: params_for_update[:location][:country_code],
				bio: params_for_update[:bio]
			})
			UserMailer.username_updated(current_user).deliver_now if send_username_changed_email
			@status = :success
		else
			@status = :error
			@message = current_user.errors.full_messages.first
		end
	end

	def search_by_username
		@results = User.where("username LIKE '%#{params[:username]}%'")
										.where(status: :active)
										.where(has_completed_wizard: true)
										.page(1)
										.per(6)
										.to_a
	end

private

	def redirect_to_my_profile
		redirect_to my_profile_path
	end
end