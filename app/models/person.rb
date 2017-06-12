class Person < ApplicationRecord
  def gender_value
    Gender.new(gender)
  end
end
