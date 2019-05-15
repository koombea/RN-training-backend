# frozen_string_literal: true

RSpec.shared_examples 'authentication is required' do |action, params|
  context "##{params[:method].to_s.upcase} #{action}" do
    before { process action, params }

    it { expect(response).to   have_http_status(401) }
    it { expect(json).not_to   be_nil }
    it { expect(errors).not_to be_nil }
    it { expect(errors).not_to be_empty }
  end
end
