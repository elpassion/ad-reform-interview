require_relative '../../../app/services/classifiers/gender_classifier'

describe GenderClassifier do
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
  end
end
