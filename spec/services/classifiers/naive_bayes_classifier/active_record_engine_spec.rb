require 'rails_helper'

describe Classifiers::NaiveBayesClassifier.const_get(:ActiveRecordEngine) do
  let(:valid_args) do
    [
      ar_scope:      Person,
      class_column:  :gender,
      features:      %i[height weight],
      observed_data: { height: 100, weight: 100 }
    ]
  end

  describe '#new' do
    subject { -> { described_class.new(*args) } }

    context 'with no args' do
      let(:args) { [] }
      it { expect(subject).to raise_error(ArgumentError) }
    end

    context 'with no :ar_scope, no :class_column and no :features' do
      let(:args) { [wrong: :key] }
      it { expect(subject).to raise_error(ArgumentError, 'missing keywords: ar_scope, class_column, features, observed_data') }
    end

    context 'with valid arguments' do
      let(:args) { valid_args }
      it { expect(subject).to_not raise_error }
    end
  end

  describe '#call' do
    before do
      Person::PersonImporter.from_csv_to_db(
        csv_file_path: Rails.root.join('spec', 'data', 'training_data.csv')
      )
    end

    let(:opts) do
      { ar_scope: Person, class_column: :gender, features: %i[height weight] }
    end

    let(:test_data) do
      Person::PersonImporter.from_csv_to_memory(
        csv_file_path: Rails.root.join('spec', 'data', 'test_data.csv')
      )
    end

    it 'has accuracy greater than 0.75' do
      correct_predictions = 0
      test_data.each do |person|
        opts[:observed_data] = person
        results              = described_class.new(opts).call
        actual_gender        = person.fetch(:gender)
        calculated_gender    = results.first.fetch('class')
        correct_predictions += 1 if calculated_gender == actual_gender
      end
      accuracy = correct_predictions / test_data.size.to_f
      expect(accuracy).to be > 0.75
    end
  end
end
