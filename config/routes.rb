Rails.application.routes.draw do
  root to: 'people#index'
  resources :people do
    member do
      get :calculate_gender
    end
  end
end
