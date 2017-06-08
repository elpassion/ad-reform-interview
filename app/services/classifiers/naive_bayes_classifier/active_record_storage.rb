module Classifiers
  class NaiveBayesClassifier
    class ActiveRecordStorage
      def initialize(ar_model:, class_column:, features:)
        @class_column = class_column
        @features     = features.map(&:to_s)
        @ar_model     = ar_model
      end

      def call
        :female
      end

      private

      attr_reader :ar_model, :class_column, :features

      # Returns averages and variances grouped by classes as a following structure:
      # {
      #   'm' => {
      #     'height_avg' => 86.67,
      #     'height_var' => 133.33,
      #   },
      #   'f' => {
      #     'height_avg' => 75.0,
      #     'height_var' => 50.0,
      #   }
      # }
      def averages_and_variances_grouped_by_classes
        {}.tap do |hash|
          results_grouped_by_classes = ar_model.select(select_sql).group(class_column)
          results_grouped_by_classes.each do |result|
            klass       = result[class_column]
            hash[klass] = {}
            features.each do |feature|
              feature_average               = result["#{feature}_avg"]
              feature_variance              = result["#{feature}_var"]
              feature_average               = feature_average.to_f.round(2)
              feature_variance              = feature_variance.to_f.round(2)
              hash[klass]["#{feature}_avg"] = feature_average
              hash[klass]["#{feature}_var"] = feature_variance
            end
          end
        end
      end

      def select_sql
        @select_sql ||=
          "#{class_column}, #{averages_select_sql}, #{variances_select_sql}"
      end

      def averages_select_sql
        features.map { |feature| "AVG(#{feature}) AS #{feature}_avg" }.join(',')
      end

      def variances_select_sql
        features.map do |feature|
          "VARIANCE(#{feature}) AS #{feature}_var"
        end.join(',')
      end
    end
  end
end
