class ContributorsController < ApplicationController
	def index
		# $post_count = count_user_posts($journalist->id);
		# $title = get_the_author_meta('title', $journalist->id);
		# $blurb = get_the_author_meta('blurb', $journalist->id);
		# $hasAvatar = has_wp_user_avatar($journalist->id);
		# $hasCompleteProfile = !empty($journalist->display_name) && !empty($blurb) && $hasAvatar;
		@contributors = Author.order(:display_name)
	end

	def show
		@contributor = Author.find_by(slug: params[:slug])
	end
end
