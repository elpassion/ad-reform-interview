module Classifiers
  class NaiveBayesClassifier
    #TODO: add pure ruby engine
    require_relative 'naive_bayes_classifier/active_record_engine'
    private_constant :ActiveRecordEngine

    ACTIVE_RECORD_ENGINE_OPTIONS = %i[ar_scope class_column features].freeze
    private_constant :ACTIVE_RECORD_ENGINE_OPTIONS

    REQUIRED_OPTIONS = %i[observed_data].freeze
    private_constant :REQUIRED_OPTIONS

    ALLOWED_OPTIONS = REQUIRED_OPTIONS + ACTIVE_RECORD_ENGINE_OPTIONS
    private_constant :ALLOWED_OPTIONS

    def initialize(opts)
      @opts = opts
      validate_opts
    end

    def call
      engine.call
    end

    private

    attr_reader :opts

    def engine
      keys = opts.keys
      if (ACTIVE_RECORD_ENGINE_OPTIONS - keys).empty?
        ActiveRecordEngine.new(opts)
      else
        raise EngineNotFound,
              "Could not find engine for following options: #{keys}"
      end
    end

    def validate_opts
      keys = opts.keys

      missing_keys = REQUIRED_OPTIONS - keys
      raise TypeError, "Missing required keys: #{missing_keys}" if missing_keys.any?

      non_allowed_keys = ALLOWED_OPTIONS - keys
      raise TypeError, "Unknown keys: #{non_allowed_keys}" if non_allowed_keys.any?
    end
  end

  class EngineNotFound < StandardError; end
end
