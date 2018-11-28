class ArticleRouter
  def self.load
    Rails.application.routes.draw do
      Article.all.each do |a|
        puts "Routing /#{a.slug}"
        get "/#{a.slug}", :to => "articles#show", defaults: { id: a.id }
      end
    end
  end

  def self.reload
    Rails.application.routes_reloader.reload!
  end
end