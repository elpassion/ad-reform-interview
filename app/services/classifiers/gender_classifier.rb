module Classifiers
  class GenderClassifier
    extend Service

    def initialize(height:, weight:)
      validate_height(height)
      validate_weight(weight)
      @height = height
      @weight = weight
    end

    def call
      Classifiers::NaiveBayesClassifier.call(ar_model:      Person,
                                             class_column:  :gender,
                                             features:      %i[height weight],
                                             observed_data: person_data)
    end

    private

    attr_reader :height, :weight

    def person_data
      { height: height, weight: weight }
    end

    def validate_height(height)
      raise(TypeError, 'height must be Integer') unless height.is_a?(Integer)
    end

    def validate_weight(weight)
      raise(TypeError, 'weight must be Integer') unless weight.is_a?(Integer)
    end
  end
end
