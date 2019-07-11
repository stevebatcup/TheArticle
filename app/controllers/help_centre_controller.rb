class HelpCentreController < ApplicationController
	def index
		@sections = HelpSection.order(sort: :asc)
		@top_questions = HelpContent.where("top_question_sort > 0").order(top_question_sort: :asc)
	end
end