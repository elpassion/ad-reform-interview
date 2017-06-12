class Person
  class Gender
    ALLOWED_GENDERS = %w[f m].freeze

    VALUE_TO_LABEL = {
      m: 'Male',
      f: 'Female',
      nil => 'Unknown'
    }.freeze; private_constant :VALUE_TO_LABEL

    def initialize(value)
      @value = build_value(value)
    end

    def to_s
      VALUE_TO_LABEL.fetch(value)
    end

    private

    attr_reader :value

    def build_value(value)
      value ? value.to_sym : nil
    end
  end
end
