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
  describe '#classes' do
    subject { -> { described_class.new(*args).send(:classes) } }
    before { Person.create([female, female, male]) }
    let(:args) { valid_args }

    it { expect(subject.call).to eql(['f', 'm']) }
  end

  describe '#classes_with_count' do
    subject { -> { described_class.new(*args).send(:classes_with_count) } }
    before { Person.create([female, female, male]) }
    let(:args) { valid_args }

    it { expect(subject.call).to eql({ 'f' => 2, 'm' => 1 }) }
  end

  describe '#classes_with_mean' do
    subject { -> { described_class.new(*args).send(:classes_with_mean) } }
    before { Person.create([female, female, male]) }
    let(:args) { valid_args }

    it { expect(subject.call).to eql({ 'f' => 0.67, 'm' => 0.33}) }
  end

  def female(height: 88, weight: 55)
    { gender: 'f', height: height, weight: weight }
  end

  def male(height: 99, weight: 66)
    { gender: 'm', height: height, weight: weight }
  end
end
