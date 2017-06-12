require 'rails_helper'

describe 'Person management', type: :feature, js: true do
  scenario do
    visit new_person_path

    # Try to create Person with no attributes
    click_button 'Create Person'
    within 'form' do
      expect(page).to have_content '4 errors prohibited this person from being saved'
      ["Height can't be blank",
       "Height is not a number",
       "Weight can't be blank",
       "Weight is not a number"].each do |error_message|
        expect(page).to have_content error_message
      end
    end

    # Create Person
    select 'Female', from: 'Gender'
    fill_in 'Height', with: '5.5'
    fill_in 'Weight', with: '66'
    click_button 'Create Person'
    expect(page).to have_content 'Person was successfully created.'
    expect(page).to have_content 'Gender:Female'
    expect(page).to have_content 'Height:5.5'
    expect(page).to have_content 'Weight:66.0'

    # Remove gender
    click_link 'Edit'
    select 'Unknown', from: 'Gender'
    click_button 'Update Person'
    expect(page).to have_content 'Person was successfully updated.'
    expect(page).to have_content 'Gender:Unknown'

    # Expect Person to be displayed on index page
    visit people_path
    within('table tbody tr:nth-child(1)') do
      expect(find('td:nth-child(1)').text).to eql 'Unknown'
      expect(find('td:nth-child(2)').text).to eql '5.5'
      expect(find('td:nth-child(3)').text).to eql '66.0'

      # Remove Person
      accept_confirm { click_link 'Destroy' }
    end
    expect(page).to have_content 'Person was successfully destroyed.'
    expect(page).to_not have_selector 'table tbody tr'
  end
end
