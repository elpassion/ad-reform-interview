require 'rails_helper'

describe Classifiers::NaiveBayesClassifier::ActiveRecordStorage do
  let(:valid_args) do
    [
      ar_model:     Person,
      class_column: :gender,
      features:     %i[height weight]
    ]
  end

  describe '#new' do
    subject { -> { described_class.new(*args) } }

    context 'with no args' do
      let(:args) { [] }
      it { expect(subject).to raise_error(ArgumentError) }
    end

    context 'with no :ar_model, no :class_column and no :features' do
      let(:args) { [wrong: :key] }
      it { expect(subject).to raise_error(ArgumentError, 'missing keywords: ar_model, class_column, features') }
    end

    context 'with valid arguments' do
      let(:args) { valid_args }

      it { expect(subject).to_not raise_error }
    end
  end

  describe '#call' do
    subject { described_class.new(*args).call(*call_args) }

    before { Person::PersonImporter.from_csv(csv_file_path: Rails.root.join('db', 'training_data.csv')) }

    let(:args) { valid_args }

    context 'when person has average height and weight for a male' do
      let(:call_args) { [{ 'height' => 70, 'weight' => 110 }] }

      it { expect(subject.first.fetch('class')).to eql 'm' }
    end

    context 'when person has average height and weight for a female' do
      let(:call_args) { [{ 'height' => 60, 'weight' => 99 }] }

      it { expect(subject.first.fetch('class')).to eql 'f' }
    end
  end
end
