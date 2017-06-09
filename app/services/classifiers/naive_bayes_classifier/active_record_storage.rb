module Classifiers
  class NaiveBayesClassifier
    class ActiveRecordStorage
      #TODO: replace #new with #call
      def initialize(ar_model:, class_column:, features:, observed_data:)
        @class_column  = class_column
        @features      = features.map(&:to_s)
        @ar_model      = ar_model
        @observed_data = observed_data
      end

      def call
        classes_with_likelihood = classes.map do |klass|
          { 'class'      => klass,
            'likelihood' => likelihood_for_class(observed_data, klass) }
        end

        classes_with_likelihood.sort_by do |hash|
          hash['likelihood']
        end.reverse
      end

      private

      attr_reader :ar_model, :class_column, :features, :observed_data

      def classes
        ar_model.select(class_column).distinct.pluck(class_column)
      end

      # Returns averages and variances grouped by classes as a following structure:
      # {
      #   'm' => {
      #     'averages'  => { 'height' => 86.67, 'weight' => 71.67 },
      #     'variances' => { 'height' => 133.33, 'weight' => 2.33 },
      #   },
      #   'f' => {
      #     'averages'  => { 'height' => 75.0, 'weight' => 52.5 },
      #     'variances' => { 'height' => 50.0, 'weight' => 12.5 },
      #   }
      # }
      def means_and_variances_grouped_by_classes
        @means_and_variances_grouped_by_classes ||= {}.tap do |hash|
          results_grouped_by_classes = ar_model.select(select_sql).group(class_column)
          results_grouped_by_classes.each do |result|
            klass                = result[class_column]
            hash[klass]          = { 'ratio' => 0, 'means' => {}, 'variances' => {} }
            hash[klass]['ratio'] = result['ratio'].to_f.round(2)
            features.each do |feature|
              feature_average                   = result["#{feature}_mean"].to_f.round(2)
              feature_variance                  = result["#{feature}_var"].to_f
              hash[klass]['means'][feature]     = feature_average
              hash[klass]['variances'][feature] = feature_variance
            end
          end
        end
      end

      def likelihood(observed_feature_value, feature_mean, feature_variance)
        #TODO: rename vars
        a = 1 / Math.sqrt(2 * Math::PI * feature_variance)
        b = -(observed_feature_value - feature_mean)**2 / (2 * feature_variance)
        c = Math::E**b
        a * c
      end

      def likelihood_for_class(observed_data, klass)
        class_ratio     = means_and_variances_grouped_by_classes[klass]['ratio']
        features_factor = features.map do |feature|
          mean     = means_and_variances_grouped_by_classes[klass].fetch('means').fetch(feature)
          variance = means_and_variances_grouped_by_classes[klass].fetch('variances').fetch(feature)
          value    = observed_data.fetch(feature.to_sym) #TODO: remove #to_sym
          likelihood(value, mean, variance)
        end.inject(&:*)
        class_ratio * features_factor
      end

      def select_sql
        @select_sql ||=
          "#{class_column}, #{ratio_select_sql}, #{averages_select_sql}, #{variances_select_sql}"
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
    end
  end
end
