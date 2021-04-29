class LandingPageRouter
  def self.load
    Rails.application.routes.draw do
      LandingPage.all.each do |landing_page|
        get "/#{landing_page.slug}", :to => "landing_pages#show", defaults: { id: landing_page.id }
      end
    end
   rescue Exception => e
   	puts e.message
  end
end