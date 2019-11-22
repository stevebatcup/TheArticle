module Admin
  class QuarantinedThirdPartySharesController < Admin::ApplicationController

    before_action :authenticate_super_admin

    def valid_action?(name, resource = resource_class)
     %w[edit new destroy].exclude?(name.to_s) && super
    end

    def scoped_resource
      QuarantinedThirdPartyShare.pending.
      page(params[:page]).
      per(10)
    end

    def approve
      respond_to do |format|
        format.json do
          share = QuarantinedThirdPartyShare.find(params[:id])
          if share.update_attributes({status: :approved, handled_by_admin_user_id: current_user.id})
            ThirdPartyArticleService.add_domain_from_url(share.url) if params[:whitelist_domain]
            ThirdPartyArticleService.approve_quarantined_share(share)
            NoticeMailer.approve_third_party_share(share).deliver_now
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
          if share.update_attributes({status: :rejected, handled_by_admin_user_id: current_user.id})
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
