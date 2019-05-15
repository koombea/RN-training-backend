# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  it { expect(v1_sessions_path).to eq('/v1/sessions') }
  it {
    expect(post: v1_sessions_url).to route_to(
      controller: 'api/v1/sessions',
      action: 'create',
      format: :json
    )
  }
  it {
    expect(delete: v1_sessions_url).to route_to(
      controller: 'api/v1/sessions',
      action: 'destroy',
      format: :json
    )
  }

  describe 'authentication is required to' do
    {
      destroy: { method: :delete, params: {} }
    }.each do |action, params|
      include_examples 'authentication is required', action, params
    end
  end

  describe 'POST #create' do
    context 'with existing credentials' do
      let(:member) { FactoryBot.create(:member, password: '12345678') }
      let(:credentials) { { email: member.email, password: '12345678' } }

      before { post :create, params: { session: credentials } }

      it { expect(response).to                  have_http_status(200) }
      it { expect(json).not_to                  be_nil }
      it { expect(json['name']).to              eq member.name }
      it { expect(json['email']).to             eq member.email }
      it { expect(json['session_token']).not_to eq member.session_token }
      it { expect(Redis.new.get(member.redis_token)).not_to be_nil }
    end

    context 'with non-existing credentials' do
      before { post :create, params: { session: { email: 'email@server.com', password: '12345678' } } }

      it { expect(response).to   have_http_status(401) }
      it { expect(json).not_to   be_nil }
      it { expect(errors).not_to be_nil }
      it { expect(errors).not_to be_empty }
    end
  end

  describe 'GET #destroy' do
    let(:member) { FactoryBot.create(:member, password: '12345678') }

    context 'as an autheticated member' do
      before do
        authenticate_member!(member)
        delete :destroy
      end

      it { should respond_with :ok }
      it { expect(Redis.new.get(member.redis_token)).to be_nil }
    end

    context 'as an unautheticated member' do
      before do
        delete :destroy
      end

      it { should respond_with :unauthorized }
      it { expect(Redis.new.get(member.redis_token)).to be_nil }
    end
  end
end
