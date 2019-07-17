require "administrate/base_dashboard"

class HelpContentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    help_section: Field::BelongsTo,
    id: Field::Number,
    section_id: Field::Number,
    question: Field::String,
    answer: Field::Text,
    sort: Field::Number,
    top_question_sort: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :sort,
    :question
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :help_section,
    :id,
    :section_id,
    :question,
    :answer,
    :sort,
    :top_question_sort,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :help_section,
    :question,
    :answer,
    :sort,
    :top_question_sort,
  ].freeze

  # Overwrite this method to customize how help contents are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(help_content)
    "Question '#{help_content.question}'"
  end
end
