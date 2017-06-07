require 'rails_helper'

describe Person::PersonImporter do
  describe '.from_csv' do
    subject { described_class.from_csv(csv_file_path: 'data.csv') }

    before { expect(CSV).to receive(:foreach).and_return(training_data.each) }

    let(:training_data) do
      [
        { 'sex' => 'f', 'heightIn' => 70.2, 'weightLb' => 80.6 },
        { 'sex' => 'm', 'heightIn' => 60.8, 'weightLb' => 85.2 },
      ]
    end

    it 'loads data from csv to database' do
      expect { subject }.to change { Person.count }.from(0).to(training_data.size)
    end

    it 'loads data from csv to database with proper attributes' do
      subject

      first_person = Person.first
      expect(first_person.gender).to eql('f')
      expect(first_person.height).to eql(70)
      expect(first_person.weight).to eql(81)

      last_person = Person.last
      expect(last_person.gender).to eql('m')
      expect(last_person.height).to eql(61)
      expect(last_person.weight).to eql(85)
    end
  end
end
