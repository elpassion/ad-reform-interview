module Classifiers
  # Classifies Person as a female or male
  class GenderClassifier
    extend Service

    def initialize(height:, weight:)
      validate_height(height)
      validate_weight(weight)
      @height = height
      @weight = weight
    end

    def call
      NaiveBayesClassifier.call(
        ar_model:     Person,
        class_column: :gender,
        features:     %i[height weight]
      )
    end

    private

    def validate_height(height)
      raise(TypeError.new('height must be Integer')) unless height.is_a?(Integer)
    end

    def validate_weight(weight)
      raise(TypeError.new('weight must be Integer')) unless weight.is_a?(Integer)
    end
  end
end
