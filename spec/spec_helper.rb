require 'json'
require 'securerandom'
require 'fileutils'
require 'c3d'
require 'epm'

RSpec.configure do |config|
  config.mock_with :rspec
  config.after(:all) do
    # FileUtils.rm(Dir['/tmp/lmdtests*'])
  end
end
