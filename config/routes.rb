Rails.application.routes.draw do
  root "tasks#index"
  resources :tasks do
    member do
      post :edit
    end
  end
end
