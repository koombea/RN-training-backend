# frozen_string_literal: true

Rails.application.routes.draw do

  # constraints subdomain: /api.*/ do
    scope module: 'api', defaults: { format: :json } do
      namespace :v1 do
        resources :registrations, only: [:create]
        resources :sessions, only: [:create] do
          delete :destroy, on: :collection
        end
      end
    end
  # end

end
