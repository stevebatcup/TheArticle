class PageRouter
  def self.load
    Rails.application.routes.draw do
      Page.all.each do |pg|
        puts "Routing /#{pg.slug}"
        get "/#{pg.slug}", :to => "pages#show", defaults: { id: pg.id }
      end
    end
  end

  def self.reload
    Rails.application.routes_reloader.reload!
  end
end