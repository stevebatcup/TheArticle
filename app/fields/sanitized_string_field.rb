require "administrate/field/base"

class SanitizedStringField < Administrate::Field::Base
  def to_s
    data
  end
end
