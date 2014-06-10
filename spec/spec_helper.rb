ENV["RAILS_ENV"] ||= 'test'

require "rails"
require "active_record"
require "database_cleaner"
require "pry"
require "generator_spec"

require "sprig/reap"

%w(
  /fixtures/models/*rb
  /support/**/*.rb
).each do |file_set|
  Dir[File.dirname(__FILE__) + file_set].each { |file| require file }
end

RSpec.configure do |config|
  config.include RailsStubs
  config.include FileSetup

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# Database
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "spec/db/activerecord.db")

User.connection.execute "DROP TABLE IF EXISTS users;"
User.connection.execute "CREATE TABLE users (id INTEGER PRIMARY KEY , first_name VARCHAR(255), last_name VARCHAR(255), type VARCHAR(255));"

Post.connection.execute "DROP TABLE IF EXISTS posts;"
Post.connection.execute "CREATE TABLE posts (id INTEGER PRIMARY KEY , title VARCHAR(255), content VARCHAR(255), published BOOLEAN , user_id INTEGER);"

Comment.connection.execute "DROP TABLE IF EXISTS comments;"
Comment.connection.execute "CREATE TABLE comments (id INTEGER PRIMARY KEY , post_id INTEGER, body VARCHAR(255));"
