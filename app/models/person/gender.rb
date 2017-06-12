class Person
  class Gender
    ALLOWED_VALUES = ['f', 'm', ''].freeze; private_constant :ALLOWED_VALUES

    VALUE_TO_LABEL = {
      m: 'Male',
      f: 'Female'
    }.freeze; private_constant :VALUE_TO_LABEL

    UNKNOWN_LABEL = 'Unknown'.freeze; private_constant :UNKNOWN_LABEL

    def initialize(value)
      raise TypeError unless value.to_s.in? ALLOWED_VALUES
      @value = build_value(value)
    end

    def to_s
      return UNKNOWN_LABEL unless value
      VALUE_TO_LABEL.fetch(value, UNKNOWN_LABEL)
    end

    private

    attr_reader :value

    def build_value(value)
      value ? value.to_sym : nil
    end
  end
end
