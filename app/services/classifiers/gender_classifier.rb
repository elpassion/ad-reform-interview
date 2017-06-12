module Classifiers
  class GenderClassifier
    extend Service

    CLASSIFIERS = {
      dummy:       :dummy_classifier,
      naive_bayes: :naive_bayes_classifier
    }.freeze; private_constant :CLASSIFIERS

    def initialize(height:, weight:)
      validate_height(height)
      validate_weight(weight)
      @height = height
      @weight = weight
    end

    def call
      classifier.call
    end

    def with_classifier(classifier_name)
      @classifier = send(CLASSIFIERS.fetch(classifier_name))
      self
    end

    private

    attr_reader :height, :weight

    def classifier
      @classifier ||= naive_bayes_classifier
    end

    def dummy_classifier
      Classifiers::DummyClassifier.new(klass: :f)
    end

    def naive_bayes_classifier
      Classifiers::NaiveBayesClassifier.new(ar_scope:      Person,
                                            class_column:  :gender,
                                            features:      %i[height weight],
                                            observed_data: person_data)
    end

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
