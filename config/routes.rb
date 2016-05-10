Rails.application.routes.draw do
  get '/login', as: :login, controller: 'login', action: 'new'
  get '/logout', as: :logout, controller: 'login', action: 'destroy'
  post '/login', as: :new_login, controller: 'login', action: 'create'
  resources :virtual_machines do
    collection do
      post :price_box
    end
    member do
      get :reboot
      get :power_cycle
    end
  end
  root to: 'virtual_machines#index'
end
