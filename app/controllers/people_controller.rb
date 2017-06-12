class PeopleController < ApplicationController
  before_action :set_person, only: %i[calculate_gender show edit update destroy]

  def index
    @people = Person.all.order(created_at: :desc)
  end

  def calculate_gender
    @gender = @person.calculated_gender
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)

    if @person.save
      redirect_to @person, notice: 'Person was successfully created.'
    else
      render :new
    end
  end

  def update
    if @person.update(person_params)
      redirect_to @person, notice: 'Person was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @person.destroy
    redirect_to people_url, notice: 'Person was successfully destroyed.'
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:gender, :height, :weight)
  end
end
