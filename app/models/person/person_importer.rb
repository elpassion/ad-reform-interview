require 'csv'

class Person
  class PersonImporter
    class << self
      ALLOWED_ATTRIBUTES = [:gender, :height, :weight].freeze; private_constant :ALLOWED_ATTRIBUTES

      def from_csv(csv_file_path:)
        # CSV.foreach for low memory usage
        enumerator = CSV.foreach(csv_file_path, headers: true)
        enumerator.lazy.each do |row|
          gender = row.fetch('sex')
          height = row.fetch('heightIn')
          weight = row.fetch('weightLb')
          height = height.to_f.round
          weight = weight.to_f.round
          Person.create(gender: gender, height: height, weight: weight)
        end
      end
    end
  end
end
