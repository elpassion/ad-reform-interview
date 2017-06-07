module Classifiers
  class NaiveBayesClassifier
    #TODO: add array_storage
    require_relative 'naive_bayes_classifier/active_record_storage'

    def call(*args)
      raise(StrategyNotSet) unless @strategy
      @strategy.call(*args)
    end

    def with_strategy(strategy)
      @strategy = strategy
      self
    end
  end

  class StrategyNotSet < StandardError
    def initialize
      super('Please set strategy with #with_strategy')
    end
  end
end
