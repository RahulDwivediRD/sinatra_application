# spec/support/factory_bot.rb

require 'factory_bot'
require_relative '../../models/user'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
