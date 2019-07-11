class HelpSection < ApplicationRecord
	has_many	:help_contents, foreign_key: :section_id
end
