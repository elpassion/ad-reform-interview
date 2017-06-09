module Classifiers
  class NaiveBayesClassifier
    #TODO: add array_storage
    require_relative 'naive_bayes_classifier/active_record_storage'

    #TODO: what about strings as keys? Can I remove them?
    #TODO: rename :ar_model to :scope
    ACTIVE_RECORD_STORAGE_OPTIONS = %i[ar_model class_column features].freeze
    private_constant :ACTIVE_RECORD_STORAGE_OPTIONS

    REQUIRED_OPTIONS = %i[observed_data].freeze; private_constant :REQUIRED_OPTIONS

    ALLOWED_OPTIONS = REQUIRED_OPTIONS + ACTIVE_RECORD_STORAGE_OPTIONS
    private_constant :ALLOWED_OPTIONS

    class << self
      def call(opts)
        validate_opts(opts)
        strategy(opts).call
      end

      private

      def strategy(opts)
        keys = opts.keys
        if (ACTIVE_RECORD_STORAGE_OPTIONS & keys).size == ACTIVE_RECORD_STORAGE_OPTIONS.size
          Classifiers::NaiveBayesClassifier::ActiveRecordStorage.new(opts)
        else
          raise StrategyNotFound,
                "Could not find strategy for following options: #{keys}"
        end
      end

      def validate_opts(opts)
        keys = opts.keys
        missing_keys = REQUIRED_OPTIONS - keys
        if missing_keys.any?
          raise TypeError, "Missing required keys: #{missing_keys}"
        end

        non_allowed_keys = ALLOWED_OPTIONS - keys
        if non_allowed_keys.any?
          raise TypeError, "Unknown keys: #{non_allowed_keys}"
        end
      end
    end
  end

  class StrategyNotFound < StandardError;
  end
end
