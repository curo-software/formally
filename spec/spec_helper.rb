require 'pry'
require 'simplecov'
require 'faker'

SimpleCov.start

require 'formally'

Dry::Validation.messages_paths.push Pathname.new File.expand_path('./messages.yml', __dir__)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
