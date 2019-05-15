# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :controller do
  it { expect(v1_registrations_path).to eq('/v1/registrations') }
  it {
    expect(post: v1_registrations_url).to route_to(
      controller: 'api/v1/registrations',
      action: 'create',
      format: :json
    )
  }

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:member_params) do
        FactoryBot.attributes_for(:member).merge(
          password: 'ValidPassword',
          password_confirmation: 'ValidPassword'
        )
      end

      before { post :create, params: { member: member_params } }

      it { expect(response).to have_http_status(200) }
      it { expect(json).not_to                      be_nil }
      it { expect(json['name']).to                  eq member_params[:name] }
      it { expect(json['email']).to                 eq member_params[:email] }
      it { expect(json['password']).to              be_nil }
      it { expect(json['password_confirmation']).to be_nil }
    end

    context 'with non-valid parameters' do
      let(:member_params) { FactoryBot.attributes_for(:member) }

      before { post :create, params: { member: member_params.except(:email) } }

      it { expect(response).to   have_http_status(422) }
      it { expect(json).not_to   be_nil }
      it { expect(errors).not_to be_nil }
      it { expect(errors).not_to be_empty }
    end
  end
end
