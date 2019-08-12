require "administrate/base_dashboard"

class ApprovedThirdPartyShareDashboard < QuarantinedThirdPartyShareDashboard
	ATTRIBUTE_TYPES = {
	  user: Field::BelongsTo,
	  article: Field::BelongsTo,
	  id: Field::Number,
	  url: UrlField,
	  status: Field::String.with_options(searchable: false),
	  heading: Field::String,
	  snippet: Field::Text,
	  post: Field::Text,
	  image: ImageField,
	  created_at: Field::DateTime,
	  updated_at: Field::DateTime,
	  admin_user_name: Field::String
	}.freeze

	COLLECTION_ATTRIBUTES = [
	  :user,
	  :heading,
	  :post,
	  :admin_user_name
	].freeze

  # def display_resource(comment_concern_report)
  #   "CommentConcernReport ##{comment_concern_report.id}"
  # end
end
