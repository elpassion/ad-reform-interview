require 'rails_helper'

describe Person::PersonImporter do
  context 'import from CSV file' do
    before { expect(CSV).to receive(:foreach).and_return(training_data.each) }

    let(:training_data) do
      [{ 'sex' => 'f', 'heightIn' => 70.2, 'weightLb' => 80.6 },
       { 'sex' => 'm', 'heightIn' => 60.8, 'weightLb' => 85.2 }]
    end

    shared_examples_for 'loads data with proper attributes' do
      it do
        first_person = collection.first
        last_person  = collection.last
        expect(first_person.gender).to eql('f')
        expect(first_person.height).to eql(70)
        expect(first_person.weight).to eql(81)
        expect(last_person.gender).to eql('m')
        expect(last_person.height).to eql(61)
        expect(last_person.weight).to eql(85)
      end
    end

    describe '.from_csv_to_db' do
      subject { described_class.from_csv_to_db(csv_file_path: 'data.csv') }

      it 'loads data from csv to database' do
        expect { subject }.to change { Person.count }.from(0).to(training_data.size)
      end

      include_examples 'loads data with proper attributes' do
        let(:collection) do
          subject
          Person.all
        end
      end
    end

    describe '.from_csv_to_memory' do
      subject { described_class.from_csv_to_memory(csv_file_path: 'data.csv') }

      include_examples 'loads data with proper attributes' do
        let(:collection) { subject.map { |hash| OpenStruct.new(hash) } }
      end
    end
  end
end
