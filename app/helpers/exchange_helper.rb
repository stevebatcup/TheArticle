module ExchangeHelper
	def exchange_excerpt(exchange, cutoff)
		exchange.description.truncate_words(cutoff)
	end
end
