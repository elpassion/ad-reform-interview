class Person
  class Gender
    include ErrorValue

    ALLOWED_GENDERS = %w[f m].freeze

    VALUE_TO_LABEL = {
      m: 'Male',
      f: 'Female',
      nil => 'Unknown'
    }.freeze

    attr_reader :value

    def initialize(value)
      @value = build_value(value)
    end

    def female?
      value == :f
    end

    def male?
      value == :m
    end

    def to_s
      VALUE_TO_LABEL.fetch(value)
    end

    def unknown?
      value.nil?
    end

    private

    def build_value(value)
      value.present? ? value.to_sym : nil
    end
  end

  def Gender(gender)
    Gender.new(gender)
  end
end
