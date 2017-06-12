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
    subject { described_class.new(*args).call }

    before do
      Person.create([{ height: 95, weight: 102, gender: :m },
                     { height: 100, weight: 100, gender: :m },
                     { height: 80, weight: 80, gender: :f },
                     { height: 70, weight: 60, gender: :f }])
    end

    let(:args) { valid_args }

    it 'should return array of hashes' do
      expect(subject.size).to eql(2)
      expect(subject[0].keys).to eql(%i[class likelihood])
      expect(subject[1].keys).to eql(%i[class likelihood])
      expect(subject[0][:class]).to eql(:m)
      expect(subject[1][:class]).to eql(:f)
      expect(subject[0][:likelihood]).to be_instance_of BigDecimal
      expect(subject[1][:likelihood]).to be_instance_of BigDecimal
    end
  end

  describe 'accuracy' do
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

    it 'should be greater than 0.75' do
      correct_predictions = 0
      test_data.each do |person|
        opts[:observed_data] = person
        results              = described_class.new(opts).call
        actual_gender        = person.fetch(:gender).to_sym
        calculated_gender    = results.first.fetch(:class)
        correct_predictions  += 1 if calculated_gender == actual_gender
      end
      accuracy = correct_predictions / test_data.size.to_f
      expect(accuracy).to be > 0.75
    end
  end
end
