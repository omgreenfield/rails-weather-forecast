Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :forecasts, only: :index do
    collection do
      get :show
    end
  end

  root 'forecasts#index'
end
