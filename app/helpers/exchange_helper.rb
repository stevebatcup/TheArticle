module ExchangeHelper
	def exchange_excerpt(exchange, cutoff)
		if exchange.description
			exchange.description.truncate_words(cutoff)
		else
			''
		end
	end
end
