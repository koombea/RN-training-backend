# frozen_string_literal: true

FactoryBot.define do
  factory :member do
    name     { FFaker::Name.name }
    email    { FFaker::Internet.email }
    password { FFaker::Internet.password }
  end
end
