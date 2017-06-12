require 'rails_helper'

describe Classifiers::GenderClassifier do
  describe '.call' do
    subject { -> { described_class.call(*args) } }

    context 'with no args' do
      let(:args) { [] }
      it { expect(subject).to raise_error(ArgumentError) }
    end

    context 'with no :height and no :weight' do
      let(:args) { [wrong: :key] }
      it { expect(subject).to raise_error(ArgumentError, 'missing keywords: height, weight') }
    end

    context 'with non-integer :height' do
      let(:args) { [height: 'string', weight: 100] }
      it { expect(subject).to raise_error(TypeError, 'height must be Integer') }
    end

    context 'with non-integer :weight' do
      let(:args) { [height: 100, weight: 'string'] }
      it { expect(subject).to raise_error(TypeError, 'weight must be Integer') }
    end

    context 'with valid arguments' do
      let(:args) { [height: 100, weight: 80] }

      it { expect(subject).to_not raise_error }

      it 'uses NaiveBayesClassifier' do
        naive_double = double(Classifiers::NaiveBayesClassifier, call: true)
        allow(Classifiers::NaiveBayesClassifier).to receive(:new).and_return(naive_double)
        expect(naive_double).to receive(:call)
        subject.call
      end
    end
  end

  describe '#with_classifier' do
    subject do
      described_class.new(height: 100, weight: 80).with_classifier(classifier_name)
    end

    context 'with invalid classifier' do
      let(:classifier_name) { :wrong_name }

      it { expect{ subject }.to raise_error(KeyError) }
    end

    context 'with valid classifier' do
      let(:classifier_name) { :dummy }

      it 'uses DummyClassifier' do
        expect(Classifiers::DummyClassifier).to receive(:new)
        subject
      end
    end
  end
end
