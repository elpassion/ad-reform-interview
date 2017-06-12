module Classifiers
  class DummyClassifier
    def initialize(klass:)
      @klass = klass
    end

    def call
      [
        { class: klass, likelihood: 1.0 }
      ]
    end

    attr_reader :klass
  end
end
