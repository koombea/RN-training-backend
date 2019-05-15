# frozen_string_literal: true

# Main application mailer used to inherit from
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
