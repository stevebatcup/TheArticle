module Admin
  class QuarantinedThirdPartySharesController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = QuarantinedThirdPartyShare.pending.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   QuarantinedThirdPartyShare.find_by!(slug: param)
    # end

    def scoped_resource
      QuarantinedThirdPartyShare.pending.
      page(params[:page]).
      per(10)
    end

    def approve
      respond_to do |format|
        format.json do
          share = QuarantinedThirdPartyShare.find(params[:id])
          if share.update_attribute(:status, :approved)
            ThirdPartyArticleService.add_domain_from_url(share.url)
            @status = :success
          else
            @status = :error
            @message = share.errors.full_messages.first
          end
        end
      end
    end

    def reject
      respond_to do |format|
        format.json do
          share = QuarantinedThirdPartyShare.find(params[:id])
          if share.update_attribute(:status, :rejected)
            NoticeMailer.reject_third_party_share(share).deliver_now
            if share.user.has_reached_rejected_post_limit?
              share.user.delete_account
            end
            @status = :success
          else
            @status = :error
            @message = share.errors.full_messages.first
          end
        end
      end
    end

    def delete
      respond_to do |format|
        format.json do
          share = QuarantinedThirdPartyShare.find(params[:id])
          if share.update_attribute(:status, :rejected)
            share.user.delete_account
            @status = :success
          else
            @status = :error
            @message = share.errors.full_messages.first
          end
        end
      end
    end


  end
end
