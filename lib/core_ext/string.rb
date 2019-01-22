class String
  def ucfirst
    str = self.clone
    str[0] = str[0,1].upcase
    str
  end

  def lcfirst
    str = self.clone
    str[0] = str[0,1].downcase
    str
  end

  def capitalise_with_exceptions(exceptions=['in','on','under','by','the','next','upon','with'])
    phrase = self.split(" ").map {|word|
      if exceptions.include?(word)
        word
      else
        word.capitalize
      end
    }.join(" ").strip
  end
end