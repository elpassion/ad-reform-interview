require 'rails_helper'

describe Person::GenderClassifier do
  describe '.call' do
    subject { -> { described_class.call(*args) } }

    context 'with valid arguments' do
      let(:args) { Person.new(height: 100, weight: 80) }

      it { expect(subject).to_not raise_error }

      it 'should use NaiveBayesClassifier' do
        naive_double = double(Classifiers::NaiveBayesClassifier, call: true)
        allow(Classifiers::NaiveBayesClassifier).to receive(:new).with(
          ar_scope:      Person,
          class_column:  :gender,
          features:      %i[height weight],
          observed_data: { height: 100, weight: 80 }
        ).and_return(naive_double)
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
      it { expect { subject }.to raise_error(KeyError) }
    end

    context 'with valid classifier' do
      let(:classifier_name) { :dummy }

      it 'should use given classifier' do
        expect(Classifiers::DummyClassifier).to receive(:new)
        subject
      end
    end
  end
end
