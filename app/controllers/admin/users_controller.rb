module Admin
  class UsersController < Admin::ApplicationController

    def index
      @search_term = params[:search].to_s.strip
      @users = User.where(search_query, *search_terms)
                    .order(order_clause)
                    .page(params[:page])
                    .per(records_per_page)
      # foo
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
          render :index
        end
      end
    end

    def add_to_blacklist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_blacklist("Blacklisted from admin", current_user, user.email)
            user.delete_account("Admin deleted account", true)
            @status = :success
          else
            @status = :error
          end
        end
      end
    end

    def add_to_watchlist
      respond_to do |format|
        format.json do
          if user = User.find_by(id: params[:user_id])
            user.add_to_watchlist("Added from admin", current_user)
            @status = :success
          else
            @status = :error
          end
        end
      end
    end

    def deactivate
      if user = User.find_by(id: params[:user_id])
        user.deactivate
        @status = :success
      else
        @status = :error
      end
    end

    def reactivate
      if user = User.find_by(id: params[:user_id])
        user.reactivate
        @status = :success
      else
        @status = :error
      end
    end

    def destroy
      if user = User.find_by(id: params[:user_id])
        user.delete_account("Admin deleted account", true)
        @status = :success
        if params[:destroy]
          user.destroy
          redirect_to "/admin/users"
        end
      else
        @status = :error
      end
    end

    def records_per_page
      params[:per_page] || cookies.permanent[:admin_user_records_per_page] || 50
    end

    def set_records_per_page
      respond_to do |format|
        format.json do
          cookies.permanent[:admin_user_records_per_page] = params[:per_page]
        end
      end
    end

  private

    def search_query
      query = "(" + search_attributes.map do |attr|
        table_name = "users"
        "LOWER(CAST(#{table_name}.#{attr} AS CHAR(256))) LIKE ?"
      end.join(" OR ") + ")"

      if params[:date_from] && params[:date_to]
        query += " AND created_at >= '#{params[:date_from]}' AND created_at <= '#{params[:date_to]}'"
      end

      if params[:refiner]
        query += " AND "
        case params[:refiner]
          when 'active'
            query += "status = #{User.statuses[:active]}"
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
      ["%#{@search_term.mb_chars.downcase}%"] * search_attributes.count
    end

    def search_attributes
      [:username, :display_name, :email]
    end

    def order_clause
      dir = :desc
      if params[:user]
        dir = params.fetch(:user).fetch(:direction)
        if params.fetch(:user).fetch(:order) == 'full_name'
          "first_name #{dir}, last_name #{dir}"
        elsif params.fetch(:user).fetch(:order) == 'human_created_at'
          "created_at #{dir}"
        elsif params.fetch(:user).fetch(:order) == 'admin_account_status'
          "status #{dir}"
        elsif params.fetch(:user).fetch(:order) == 'admin_profile_status'
          "IF(status = 2, 1,(IF(has_completed_wizard = 1, (IF(status=1, 0, 3)), 2))) #{dir}"
        end
      else
        "id #{dir}"
      end
    end
  end
end
