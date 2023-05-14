# frozen_string_literal: true

ENV['environment'] = 'test'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
