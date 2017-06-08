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

  #TODO: add comments why I write tests for private methods
  describe '#averages_and_variances_grouped_by_classes' do
    subject { -> { described_class.new(*args).send(:averages_and_variances_grouped_by_classes) } }
    before do
      Person.create([
                      female(height: 80, weight: 55),
                      female(height: 70, weight: 50),
                      male(height: 100, weight: 70),
                      male(height: 80, weight: 73),
                      male(height: 80, weight: 72),
                    ])
    end
    let(:args) { valid_args }

    it do
      expected = {
        'm' => {
          'height_avg' => 86.67,
          'height_var' => 133.33,
          'weight_avg' => 71.67,
          'weight_var' => 2.33
        },
        'f' => {
          'height_avg' => 75.0,
          'height_var' => 50.0,
          'weight_avg' => 52.5,
          'weight_var' => 12.5
        }
      }
      expect(subject.call).to eql(expected)
    end
  end

  def female(height: 88, weight: 55)
    { gender: 'f', height: height, weight: weight }
  end

  def male(height: 99, weight: 66)
    { gender: 'm', height: height, weight: weight }
  end
end
