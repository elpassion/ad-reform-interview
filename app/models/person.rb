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

    genders = GenderClassifier.call(self)
    return Gender(nil) if genders.empty?

    calculated_gender = genders.first.fetch(:class)
    Gender(calculated_gender)

  rescue Classifiers::ClassifiersError => error
    Gender(nil).tap { |gender| gender.error = error }
  end

  def gender_value
    Gender(gender)
  end
end
