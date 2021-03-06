Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	get '/', to: 'application#index'

  get 'rates', to: 'rates#index'
  post 'rates', to: 'rates#create'
end
