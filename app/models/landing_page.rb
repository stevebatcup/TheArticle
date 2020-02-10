class LandingPage < ApplicationRecord
	has_and_belongs_to_many	:keyword_tags
	before_save :send_dev_email_if_newly_published
	after_save	:generate_route
	enum status: [:draft, :live, :deleted]

	def generate_route
		if self.slug_changed?
			Rails.application.routes.draw do
				get self.url, :to => "landing_pages#show", defaults: { id: self.id }
			end
		end
	end

	def url
		"/#{self.slug}"
	end

	def preview_url
		"/#{self.slug}?preview=1"
	end

	def keyword_tag_list
		self.keyword_tags.map(&:name).join(", ")
	end

	def self.for_homepage
		Rails.cache.fetch("landing_page_links_for_homepage", expires_in: 30.minutes) do
			where(show_home_link: true).where(status: :live).all
		end
	end

	def send_dev_email_if_newly_published
		if self.status_changed? && self.status.to_sym == :live
			DeveloperMailer.landing_page_published(self).deliver_now
		end
	end

end
