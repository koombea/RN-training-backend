# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:member) { FactoryBot.build(:member) }

  subject { member }

  # Existing attributes
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }

  # Required fields
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }

  # Uniqueness validations
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should be_valid }
end
