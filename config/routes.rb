Rails.application.routes.draw do
  devise_for :users

  resources :events do
    collection do
      get 'calendar'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'events#calendar'
end
