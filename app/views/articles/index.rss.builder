xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "TheArticle"
    xml.description "Eclectic, enjoyable, essential reading. We are the only publisher that is also a social media platform so you get personalised debate with no pay wall."
    xml.link root_url

    @articles.each do |article|
      xml.item do
        xml.title article.title
        xml.description { xml << CGI.unescapeHTML(article.content) }
        xml.pubDate article.published_at.to_s(:rfc822)
        xml.link full_article_url(article)
        xml.guid full_article_url(article)
      end
    end
  end
end