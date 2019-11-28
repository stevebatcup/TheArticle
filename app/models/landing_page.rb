class LandingPage < ApplicationRecord
	has_and_belongs_to_many	:keyword_tags
	after_save	:generate_route

	def generate_route
		if self.slug_changed?
			Rails.application.routes.draw do
				get "/#{self.slug}", :to => "landing_pages#show", defaults: { id: self.id }
			end
		end
	end

end
