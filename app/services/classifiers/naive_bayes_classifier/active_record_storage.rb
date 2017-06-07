module Classifiers
  class NaiveBayesClassifier
    class ActiveRecordStorage
      def initialize(ar_model:, class_column:, features:)
        @class_column = class_column
        @features     = features
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
