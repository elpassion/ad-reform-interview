require 'rails_helper'

describe Person do
  describe 'validations' do
    subject { Person.new(attrs).tap(&:valid?) }

    describe '#gender' do
      context 'with invalid value' do
        let(:attrs) { { gender: 'invalid gender' } }
        it { expect(subject.errors[:gender]).to eql ['is not included in the list'] }
      end

      context 'with empty value' do
        let(:attrs) { { gender: '' } }
        it { expect_no_errors_for(:gender) }
      end

      context 'with value=m' do
        let(:attrs) { { gender: 'm' } }
        it { expect_no_errors_for(:gender) }
      end

      context 'with value=f' do
        let(:attrs) { { gender: 'f' } }
        it { expect_no_errors_for(:gender) }
      end
    end

    shared_examples_for 'should be number' do |attribute_name|
      let(:attrs) { { attribute_name => 'not a number' } }
      it { expect(subject.errors[attribute_name]).to eql ['is not a number'] }
    end

    shared_examples_for 'should be greater than zero' do |attribute_name, attribute_value|
      let(:attrs) { { attribute_name => -1 } }
      it { expect(subject.errors[attribute_name]).to eql ['must be greater than 0'] }
    end

    describe '#height' do
      it_behaves_like 'should be number', :height
      it_behaves_like 'should be greater than zero', :height
    end

    describe '#weight' do
      it_behaves_like 'should be number', :weight
      it_behaves_like 'should be greater than zero', :weight
    end
  end

  def expect_no_errors_for(attribute)
    expect(subject.errors[attribute]).to be_empty
  end
end