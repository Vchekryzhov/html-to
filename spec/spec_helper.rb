require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'spec/'
  add_filter '.github/'
  add_filter 'lib/generators/templates/'
  add_filter 'lib/html_to/version'
end
require 'rspec'
require 'rails/all'
require_relative '../lib/html_to'
require 'sqlite3'

require 'active_job'

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }
ENV['RAILS_ENV'] = 'test'
require_relative '../spec/dummy/config/environment'
ENV['RAILS_ROOT'] ||= "#{File.dirname(__FILE__)}../../../spec/dummy"

TEST_DATABASE_FILE = File.expand_path('dummy/db/test.sqlite3', __dir__)
FileUtils.rm( TEST_DATABASE_FILE ) rescue nil
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::WARN
ActiveRecord::Base.connection.create_table :dummy_models do |t|
  t.string :title
  t.integer :description
end
ActiveRecord::Base.connection.create_table :dummy_classes do |t|
  t.string :title
  t.integer :description
end