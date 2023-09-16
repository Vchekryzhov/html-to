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
  config.include ActiveJob::TestHelper
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.after(:suite) do
    FileUtils.rm_f( TEST_DATABASE_FILE )
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  config.after(:each) do
    FileUtils.rm_rf( Dir.glob(Rails.root.join("tmp/storage/*")) )
  end
end

if ENV['CI'] == 'true'
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }
ENV['RAILS_ENV'] = 'test'
require_relative '../spec/dummy/config/environment'

TEST_DATABASE_FILE = File.expand_path('dummy/db/test.sqlite3', __dir__)
FileUtils.rm_f( TEST_DATABASE_FILE )
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::WARN
ActiveRecord::MigrationContext.new("spec/dummy/db/migrate").migrate

