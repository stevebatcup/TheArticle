class HelpContent < ApplicationRecord
	belongs_to	:help_section, foreign_key: :section_id
end