module Admin
  class UsersController < Admin::ApplicationController

    before_action :authenticate_super_admin, only: [:index, :show]

    def index
      set_records_per_page if params[:per_page]
      @search_term = params[:search].to_s.strip
      @users = User.where(search_query, *search_terms)
                    .order(order_clause)
                    .page(params[:page])
                    .per(records_per_page)
      respond_to do |format|
        format.html do
          page = Administrate::Page::Collection.new(dashboard, order: order)
          @search_start_date = "2019-03-13"
          @search_end_date = Date.today.strftime("%Y-%m-%d")
          render locals: {
            resources: @users,
            search_term: @search_term,
            page: page
          }
        end
        format.json do
          if params[:page].to_i == 1
            @total_records = User.where(search_query, *search_terms).length
            @total_pages = (@total_records.to_f / records_per_page.to_f).ceil
          end
          render :index
        end
      end
    end

    def show
      @full_details = params[:full_details].present?
      if @full_details
        @user = User.includes(:notification_settings)
                    .references(:notification_settings)
                    .find(params[:id])
      else
        @user = User.find(params[:id])
      end
    end

    def create_page
      session["account_pages"] = [] if !session["account_pages"]
      user = User.find(params[:user_id])
      session["account_pages"].push({ id: user.id, name: user.full_name })
      @status = :success
    end

    def get_open_pages
      respond_to do |format|
        format.json do
          @pages = session["account_pages"]
        end
      end
    end

    def close_page
      session["account_pages"] = session["account_pages"].select do |item|
        item["id"].to_i != params[:user_id].to_i
      end
      @status = :success
    end

    def add_to_blacklist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_blacklist("Blacklisted from admin", current_user, user.email)
            user.delete_account("Admin deleted account", true)
            render json: { status: :success }
          else
            render json: { status: :error }
          end
        end
      end
    end

    def add_to_watchlist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_watchlist("Added from admin", current_user)
            render json: { status: :success }
          else
            render json: { status: :error }
          end
        end
      end
    end

    def deactivate
      if user = User.find_by(id: params[:user_id])
        user.deactivate
        render json: { status: :success }
      else
        render json: { status: :error }
      end
    end

    def reactivate
      if user = User.find_by(id: params[:user_id])
        user.reactivate
        render json: { status: :success }
      else
        render json: { status: :error }
      end
    end

    def destroy
      if user = User.find_by(id: params[:user_id])
        user.delete_account("Admin deleted account", true)
        if params[:destroy]
          user.destroy
          redirect_to "/admin/users"
        end
        render json: { status: :success }
      else
        render json: { status: :error }
      end
    end

    def records_per_page
      @records_per_page ||= (cookies.permanent[:admin_user_records_per_page] || 50)
    end

    def set_records_per_page
      cookies.permanent[:admin_user_records_per_page] = params[:per_page]
    end

    def available_authors
      @authors = Author.with_complete_profile.order(display_name: :asc).to_a
      used_author_ids = User.where.not(author_id: nil).map(&:author_id)
      user = User.find(params[:user_id])
      @authors.select! do |author|
        used_author_ids.exclude?(author.id)
      end
      if user.author_id.present?
        @authors << Author.find(user.author_id)
      end
      @authors.sort_by! {|author| author.display_name}
    end

    def set_author_for_user
      user = User.find(params[:user_id])
      user.update_attribute(:author_id, params[:author_id])
      render json: { status: :success }
    end

    def set_genuine_verified_for_user
      user = User.find(params[:user_id])
      user.update_attribute(:verified_as_genuine, params[:genuine_verified])
      render json: { status: :success }
    end

    def add_additional_email
      user = User.find(params[:user_id])
      if @additional_email = AdditionalEmail.create({user_id: user.id, text: params[:email]})
        @status = :success
      else
        @status = :error
        @message = better_model_error_messages(@additional_email)
      end
    end

    def delete_additional_email
      user = User.find(params[:user_id])
      if additional_email = user.additional_emails.find_by(id: params[:email_id])
        additional_email.destroy
        @status = :success
      else
        @status = :error
      end
      render json: { status: @status }
    end

    def add_linked_account
      user = User.find(params[:user_id])
      if other_user = User.find_by(id: params[:linked_account])
        if @linked_account = LinkedAccount.create({user_id: user.id, linked_account: other_user})
          @status = :success
        else
          @status = :error
          @message = better_model_error_messages(@linked_account)
        end
      else
        @status = :error
        @message = "Cannot find a user with id #{params[:linked_account]}"
      end
    end

    def delete_linked_account
      user = User.find(params[:user_id])
      if linked_account = user.linked_accounts.find_by(linked_account_id: params[:linked_account_id])
        linked_account.destroy
        @status = :success
      else
        @status = :error
      end
      render json: { status: @status }
    end

    def update_bio
      if user = User.find(params[:user_id])
        user.bio = params[:bio]
        if user.save
          render json: { status: :success }
          AdminEmailUserBioUpdatedJob.perform_later(user) if params[:send_alert]
        else
          render json: { status: :error, message: better_model_error_messages(user) }
        end
      else
        render json: { status: :error, message: "User not found" }
      end
    end

  private

    def query_is_digits_only?
      (@search_term.length > 1) && (@search_term.scan(/\D/).empty?)
    end

    def search_query
      if query_is_digits_only?
        query = "( id LIKE ? )"
      else
        query = "(" + search_attributes.map do |attr|
          "LOWER(CAST(#{attr} AS CHAR(256))) LIKE ?"
        end.join(" OR ") + ")"
      end

      if params[:date_from] && params[:date_to]
        query += " AND DATE(created_at) >= '#{params[:date_from]}' AND DATE(created_at) <= '#{params[:date_to]}'"
      end

      if params[:refiner]
        query += " AND "
        case params[:refiner]
          when 'active'
            query += "status = #{User.statuses[:active]}"
          when 'incomplete'
            query += "has_completed_wizard = 0"
          when 'deactivated'
            query += "status = #{User.statuses[:deactivated]}"
          when 'verified'
            query += "confirmed_at IS NOT NULL"
          when 'watchlisted'
            query += "EXISTS(SELECT * FROM watch_list_users w WHERE w.user_id = users.id)"
          when 'blacklisted'
            query += "EXISTS(SELECT * FROM black_list_users b WHERE b.user_id = users.id)"
        end
      end

      query
    end

    def search_terms
      if query_is_digits_only?
        ["#{@search_term}%"]
      else
        ["%#{@search_term.mb_chars.downcase}%"] * search_attributes.count
      end
    end

    def search_attributes
      ["CONCAT(first_name, ' ', last_name)", :username, :display_name, :email]
    end

    def order_clause
      dir = params[:dir] || :desc
      if params[:sort]
        if params[:sort] == 'full_name'
          "first_name #{dir}, last_name #{dir}"
        elsif params[:sort] == 'human_created_at'
          "created_at #{dir}"
        elsif params[:sort] == 'admin_account_status'
          "status #{dir}"
        elsif params[:sort] == 'admin_profile_status'
          "IF(status = 2, 1,(IF(has_completed_wizard = 1, (IF(status=1, 0, 3)), 2))) #{dir}"
        else
          "#{params[:sort]} #{dir}"
        end
      else
        "id #{dir}"
      end
    end
  end
end
