module Classifiers
  class NaiveBayesClassifier
    # Returns classes sorted by likelihood as following structure:
    # [{ class: "f", likelihood: 0.007850654 },
    #  { class: "m", likelihood: 0.001904104 }]
    class ActiveRecordEngine
      def initialize(ar_scope:, class_column:, features:, observed_data:)
        @class_column  = class_column
        @features      = features
        @ar_scope      = ar_scope
        @observed_data = observed_data
      end

      def call
        classes_with_likelihood = classes.map do |klass|
          { class:      klass.to_sym,
            likelihood: likelihood_for_class(observed_data, klass) }
        end

        classes_with_likelihood.sort_by do |hash|
          hash.fetch(:likelihood)
        end.reverse
      end

      private

      attr_reader :ar_scope, :class_column, :features, :observed_data

      def classes
        ar_scope.select(class_column).distinct.pluck(class_column)
      end

      def classes_metadata
        @classes_metadata ||= {}.tap do |hash|
          results_grouped_by_classes = ar_scope.select(select_sql).group(class_column)
          results_grouped_by_classes.each do |result|
            klass               = result[class_column]
            hash[klass]         = { ratio: nil, means: {}, variances: {} }
            hash[klass][:ratio] = result[:ratio].to_d.round(2)
            features.each do |feature|
              feature_average  = result["#{feature}_mean"].to_d.round(2)
              feature_variance = result["#{feature}_var"]
              if feature_variance.nil?
                raise CouldNotCalculateError, "variance could not be calculated for the following feature: #{feature}"
              end
              hash[klass][:means][feature]     = feature_average
              hash[klass][:variances][feature] = feature_variance
            end
          end
        end
      end

      def likelihood(observed_feature_value, feature_mean, feature_variance)
        exp_power = (observed_feature_value - feature_mean)**2 / (2 * feature_variance)
        exp       = Math::E ** -exp_power
        1 / Math.sqrt(2 * Math::PI * feature_variance) * exp
      end

      def likelihood_for_class(observed_data, klass)
        class_metadata  = classes_metadata.fetch(klass)
        class_ratio     = class_metadata.fetch(:ratio)
        features_factor = features.map do |feature|
          mean     = class_metadata.fetch(:means).fetch(feature)
          variance = class_metadata.fetch(:variances).fetch(feature)
          value    = observed_data.fetch(feature)
          likelihood(value, mean, variance)
        end.inject(&:*)
        class_ratio * features_factor
      end

      def select_sql
        @select_sql ||= [
          class_column,
          ratio_select_sql,
          averages_select_sql,
          variances_select_sql
        ].join(',')
      end

      def averages_select_sql
        features.map { |feature| "AVG(#{feature}) AS #{feature}_mean" }.join(',')
      end

      def ratio_select_sql
        "COUNT(#{class_column}) / SUM(COUNT(#{class_column})) OVER() AS ratio"
      end

      def variances_select_sql
        features.map do |feature|
          "VARIANCE(#{feature}) AS #{feature}_var"
        end.join(',')
      end

      class CouldNotCalculateError < StandardError
      end
    end
  end
end
