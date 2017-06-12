require 'rails_helper'

describe 'Person management', type: :feature, js: true do
  before do
    Person::PersonImporter.from_csv_to_db(
      csv_file_path: Rails.root.join('spec', 'data', 'training_data.csv')
    )
  end

  scenario do
    visit people_path

    # Create Person
    click_link 'New Person'
    select 'Unknown', from: 'Gender'
    fill_in 'Height', with: '6'
    fill_in 'Weight', with: '130'
    click_button 'Create Person'
    visit people_path
    click_link 'Calculate gender'
    expect(page).to have_content 'Calculated gender:Female'
  end
end
