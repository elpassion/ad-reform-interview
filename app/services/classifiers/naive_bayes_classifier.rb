module Classifiers
  class NaiveBayesClassifier
    #TODO: add array_storage
    require_relative 'naive_bayes_classifier/active_record_storage'

    ACTIVE_RECORD_STORAGE_OPTIONS = [
      :ar_model,
      :class_column,
      :features
    ].freeze; private_constant :ACTIVE_RECORD_STORAGE_OPTIONS

    class << self
      def call(opts)
        strategy(opts).call
      end

      def strategy(opts)
        keys = opts.keys
        if (ACTIVE_RECORD_STORAGE_OPTIONS & keys).size == ACTIVE_RECORD_STORAGE_OPTIONS.size
          Classifiers::NaiveBayesClassifier::ActiveRecordStorage.new(opts)
        else
          raise StrategyNotFound.new(keys)
        end
      end
    end
  end

  class StrategyNotFound < StandardError
    def initialize(opts_keys)
      super("Could not find strategy for following options: #{opts_keys}")
    end
  end
end
