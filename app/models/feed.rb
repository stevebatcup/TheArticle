class Feed < ApplicationRecord
	belongs_to	:user
	has_and_belongs_to_many	:feed_user, dependent: :destroy
	has_and_belongs_to_many	:notifications
	belongs_to	:actionable, polymorphic: true

	def self.pagination_by_hours
		6
	end

	def self.types_for_followings
		['Share']
	end

	def self.latest_activity_time_for_user(current_user, offset=nil)
		items = []
		latest_feed = self.fetch_for_followings_of_user(current_user, true, offset).first
		items << latest_feed.updated_at unless latest_feed.nil?
		latest_feed_user_feed = self.fetch_feed_user_feeds(current_user, true, offset).first
		items << latest_feed_user_feed.updated_at unless latest_feed_user_feed.nil?
		latest_categorisation = self.fetch_categorisations_for_user(current_user, true, offset).first
		items << latest_categorisation.published_at unless latest_categorisation.nil?
		if items.any?
			items.sort.reverse.first
		else
			nil
		end
	end

	def self.fetch_for_followings_of_user(current_user, count_only=false, last_activity_time=nil)
		pagination_clause = ""
		if last_activity_time.present?
			last_activity_date = DateTime.strptime(last_activity_time.to_s,'%s')
			start_time = last_activity_date.strftime("%Y-%m-%d %H:%M:%S")
			if !count_only
				pagination_clause = " AND (feeds.updated_at >= DATE_SUB('#{start_time}', INTERVAL #{pagination_by_hours} HOUR) AND feeds.updated_at <= '#{start_time}')"
			else
				pagination_clause = " AND feeds.updated_at <= '#{start_time}'"
			end
		end
		sql = "SELECT feeds.* FROM `follows`
						LEFT JOIN `users` ON `users`.`id` = `follows`.`followed_id`
						LEFT  JOIN `feeds` ON `feeds`.`user_id` = `users`.`id`
						WHERE follows.user_id = #{current_user.id} AND
						feeds.actionable_type IN (\"#{self.types_for_followings.join('", "')}\") AND
						followed_id NOT IN ('#{current_user.muted_id_list.join('\', \'')}') AND
						followed_id NOT IN ('#{current_user.blocked_id_list.join('\', \'')}')
						#{pagination_clause}
					GROUP BY feeds.actionable_id
					ORDER BY updated_at DESC
				"
		self.find_by_sql(sql)
	end

	def self.fetch_feed_user_feeds(current_user, count_only=false, last_activity_time=nil)
		results = current_user.feed_users
													.left_outer_joins(:feeds)
													.where("feeds.id IS NOT NULL")
													.group("feed_users.id")
													.order(updated_at: :desc)
		if last_activity_time.present?
			last_activity_date = DateTime.strptime(last_activity_time.to_s,'%s')
			start_time = last_activity_date.strftime("%Y-%m-%d %H:%M:%S")
			if !count_only
				results = results.where("(feed_users.updated_at >= DATE_SUB('#{start_time}', INTERVAL #{pagination_by_hours} HOUR) AND feed_users.updated_at <= '#{start_time}')")
			else
				results = results.where("feed_users.updated_at <= '#{start_time}'")
			end
		end
		results
	end

	def self.fetch_categorisations_for_user(current_user, count_only=false, last_activity_time=nil)
		join_sql = "INNER JOIN articles_exchanges ON articles_exchanges.id = feeds.actionable_id"
		join_sql << " INNER JOIN articles ON articles_exchanges.article_id = articles.id"
		categorisations = current_user.feeds.select("feeds.*, articles.published_at").joins(join_sql)
														.where(actionable_type: 'Categorisation')
														.order("articles.published_at DESC")
		if last_activity_time.present?
			last_activity_date = DateTime.strptime(last_activity_time.to_s,'%s')
			start_time = last_activity_date.strftime("%Y-%m-%d %H:%M:%S")
			if !count_only
				categorisations = categorisations.where("(articles.published_at >= DATE_SUB('#{start_time}', INTERVAL #{pagination_by_hours} HOUR) AND articles.published_at <= '#{start_time}')")
			else
				categorisations = categorisations.where("articles.published_at <= '#{start_time}'").group("articles.id")
			end
		end
		categorisations
	end
end
