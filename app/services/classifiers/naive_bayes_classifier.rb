module Classifiers
  class NaiveBayesClassifier
    #TODO: add pure ruby engine
    require_relative 'naive_bayes_classifier/active_record_engine'
    private_constant :ActiveRecordEngine

    #TODO: what about strings as keys? Can I remove them?
    ACTIVE_RECORD_ENGINE_OPTIONS = %i[ar_scope class_column features].freeze
    private_constant :ACTIVE_RECORD_ENGINE_OPTIONS

    REQUIRED_OPTIONS = %i[observed_data].freeze
    private_constant :REQUIRED_OPTIONS

    ALLOWED_OPTIONS = REQUIRED_OPTIONS + ACTIVE_RECORD_ENGINE_OPTIONS
    private_constant :ALLOWED_OPTIONS

    class << self
      def call(opts)
        validate_opts(opts)
        engine(opts).call
      end

      private

      def engine(opts)
        keys = opts.keys
        if (ACTIVE_RECORD_ENGINE_OPTIONS - keys).empty?
          ActiveRecordEngine.new(opts)
        else
          raise EngineNotFound,
                "Could not find engine for following options: #{keys}"
        end
      end

      def validate_opts(opts)
        keys = opts.keys
        missing_keys = REQUIRED_OPTIONS - keys
        if missing_keys.any?
          raise TypeError, "Missing required keys: #{missing_keys}"
        end

        non_allowed_keys = ALLOWED_OPTIONS - keys
        raise TypeError, "Unknown keys: #{non_allowed_keys}" if non_allowed_keys.any?
      end
    end
  end

  class EngineNotFound < StandardError;
  end
end
