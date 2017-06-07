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

      def classes
        @classes ||=
          ar_model.select(class_column).distinct.pluck(class_column)
      end

      def classes_with_count
        @classes_with_count ||=
          ar_model.group(class_column).count
      end

      # Returns Hash structured as follows:
      # {
      #   'class1' => { 'feature1' => feature1_mean_in_class_1, 'feature2' => feature2_mean_in_class_1 },
      #   'class2' => { 'feature1' => feature1_mean_in_class_2, 'feature2' => feature2_mean_in_class_2 }
      # }
      def classes_with_features_mean
        classes_with_features_mean = {}

        classes.each do |klass|
          classes_with_features_mean[klass] = {}

          # AVG(height) AS height_avg, AVG(weight) AS weight_avg
          select_sql = features.map do |feature|
            "AVG(`#{feature}`) AS #{feature}_avg"
          end.join(', ')

          # Get all averages with one query
          averages = ar_model.where(class_column => klass).select(select_sql).first

          features.each do |feature|
            average = averages["#{feature}_avg"].to_f.round(2)
            classes_with_features_mean[klass][feature] = average
          end
        end

        classes_with_features_mean
      end

      def classes_with_mean
        classes_with_mean = {}
        classes_with_count.each_pair do |klass, klass_count|
          classes_with_mean[klass] = (klass_count / total_count.to_f).round(2)
        end
        classes_with_mean
      end

      def total_count
        @total_count ||=
          classes_with_count.values.inject(:+)
      end
    end
  end
end
