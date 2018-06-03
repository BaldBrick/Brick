Rails.application.routes.draw do
  devise_for :users
  get 'download', to: 'comparator#download'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "comparator#index"

end
