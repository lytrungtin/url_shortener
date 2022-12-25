# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/:slug', to: 'redirection#redirect', as: :shortened

  # Defines the root path route ("/")
  # root "articles#index"
end
