class Person
  class Gender
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
end
