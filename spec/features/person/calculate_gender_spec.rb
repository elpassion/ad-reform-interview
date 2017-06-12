require 'rails_helper'

describe 'Person management', type: :feature, js: true do
  scenario 'with reasonable training data' do
    Person::PersonImporter.from_csv_to_db(
      csv_file_path: Rails.root.join('spec', 'data', 'training_data.csv')
    )

    create_person
    visit people_path
    click_link 'Calculate gender'
    expect(page).to have_content 'Calculated gender:Female'
  end

  scenario 'with no training data' do
    create_person
    visit people_path
    click_link 'Calculate gender'
    expect(page).to have_content 'Could not calculate gender! not enough data'
  end

  scenario 'with not enough training data' do
    create_person
    create_person(gender: 'Female')
    create_person(gender: 'Male')
    visit people_path
    click_link 'Calculate gender'
    expect(page).to have_content 'Could not calculate gender! could not calculate variance for: height'
  end

  def create_person(gender: 'Unknown')
    visit new_person_path
    select gender, from: 'Gender'
    fill_in 'Height', with: '6'
    fill_in 'Weight', with: '130'
    click_button 'Create Person'
  end
end
