# frozen_string_literal: true

# Main application model used to inherit from
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
