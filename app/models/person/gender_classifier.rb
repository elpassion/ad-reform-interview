class Person
  class GenderClassifier
    extend Service

    CLASSIFIERS = {
      dummy:       :dummy_classifier,
      naive_bayes: :naive_bayes_classifier
    }.freeze; private_constant :CLASSIFIERS

    def initialize(person)
      @person = person
    end

    def call
      classifier.call
    end

    def with_classifier(classifier_name)
      @classifier = send(CLASSIFIERS.fetch(classifier_name))
      self
    end

    private

    attr_reader :person

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
                                            observed_data: person_features)
    end

    def person_features
      { height: person.height, weight: person.weight }
    end
  end
end
