require "administrate/field/base"

class AuthorSelectField < Administrate::Field::Base
	def to_s
	  data
	end

	def choices
	  options.fetch(:choices)
	end

	def selected_choice
	  data
	end
end
