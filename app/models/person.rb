class Person < ApplicationRecord
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :gender,
            presence:  true,
            inclusion: { in: Gender::ALLOWED_GENDERS },
            allow_blank: true

  nilify_blanks only: [:gender]

  def calculated_gender
    return gender_value.value unless gender_value.unknown?
    GenderClassifier.call(self)
  end

  def gender_value
    Gender.new(gender)
  end
end
