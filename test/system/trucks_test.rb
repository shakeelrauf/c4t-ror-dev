require "application_system_test_case"

class TrucksTest < ApplicationSystemTestCase
  setup do
    @truck = trucks(:one)
  end

  test "visiting the index" do
    visit trucks_url
    assert_selector "h1", text: "Trucks"
  end

  test "creating a Truck" do
    visit trucks_url
    click_on "New Truck"

    fill_in "Car capacity", with: @truck.car_capacity
    fill_in "Flatbed", with: @truck.flatbed
    fill_in "Flatbed type", with: @truck.flatbed_type
    fill_in "Make", with: @truck.make
    fill_in "Model", with: @truck.model
    fill_in "Name", with: @truck.name
    fill_in "Year", with: @truck.year
    click_on "Create Truck"

    assert_text "Truck was successfully created"
    click_on "Back"
  end

  test "updating a Truck" do
    visit trucks_url
    click_on "Edit", match: :first

    fill_in "Car capacity", with: @truck.car_capacity
    fill_in "Flatbed", with: @truck.flatbed
    fill_in "Flatbed type", with: @truck.flatbed_type
    fill_in "Make", with: @truck.make
    fill_in "Model", with: @truck.model
    fill_in "Name", with: @truck.name
    fill_in "Year", with: @truck.year
    click_on "Update Truck"

    assert_text "Truck was successfully updated"
    click_on "Back"
  end

  test "destroying a Truck" do
    visit trucks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Truck was successfully destroyed"
  end
end
