require 'csv'

class Person
  class PersonImporter
    class << self
      CSV_GENDER_COLUMN = 'sex'.freeze; private_constant :CSV_GENDER_COLUMN
      CSV_HEIGHT_COLUMN = 'heightIn'.freeze; private_constant :CSV_HEIGHT_COLUMN
      CSV_WEIGHT_COLUMN = 'weightLb'.freeze; private_constant :CSV_WEIGHT_COLUMN

      # This is designed to be fast, not safe.
      # Use it to import large data from a safe source.
      def from_csv_to_db(csv_file_path:)
        sql_values = ''
        now        = Time.now.to_s(:db)

        each_csv_row(csv_file_path: csv_file_path) do |row|
          gender, height, weight = row
          sql_values << "('#{gender}', #{height}, #{weight}, '#{now}', '#{now}')," # Using #<< for performance
        end

        sql_values  = sql_values.chomp(',')
        sql_columns = 'gender, height, weight, created_at, updated_at'

        sql = <<-SQL
          INSERT INTO #{Person.table_name} (#{sql_columns}) VALUES #{sql_values}
        SQL

        # Bulk insert (no validation and possible sql injection!)
        # Unfortunately, bulk insert is not possible with Arel yet :(
        ActiveRecord::Base.connection.execute(sql)
      end

      def from_csv_to_memory(csv_file_path:)
        [].tap do |array|
          each_csv_row(csv_file_path: csv_file_path) do |row|
            gender, height, weight = row
            array << { gender: gender, height: height, weight: weight }
          end
        end
      end

      private

      def each_csv_row(csv_file_path:)
        # CSV.foreach for low memory usage
        CSV.foreach(csv_file_path, headers: true).each do |row|
          yield(csv_row_to_array(row))
        end
      end

      def csv_row_to_array(csv_row)
        gender = csv_row.fetch(CSV_GENDER_COLUMN)
        height = csv_row.fetch(CSV_HEIGHT_COLUMN)
        weight = csv_row.fetch(CSV_WEIGHT_COLUMN)
        height = height.to_f.round
        weight = weight.to_f.round
        [gender, height, weight]
      end
    end
  end
end
