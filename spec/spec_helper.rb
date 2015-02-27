ENV["RAILS_ENV"] ||= 'test'

require "rails"
require "active_record"
require "database_cleaner"
require "pry"
require "generator_spec"
require "carrierwave"
require 'carrierwave/orm/activerecord'

require "sprig-reap"

%w(
  /fixtures/**/*.rb
  /support/**/*.rb
).each do |file_set|
  Dir[File.dirname(__FILE__) + file_set].each { |file| require file }
end

RSpec.configure do |config|
  config.include RailsStubs
  config.include FileSetup
  config.include LoggerMock
  config.include ColoredText

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start

    stub_rails_application
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# Database
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "spec/db/activerecord.db")

User.connection.execute "DROP TABLE IF EXISTS users;"
User.connection.execute "CREATE TABLE users (id INTEGER PRIMARY KEY , first_name VARCHAR(255), last_name VARCHAR(255), type VARCHAR(255), avatar VARCHAR(225));"

Post.connection.execute "DROP TABLE IF EXISTS posts;"
Post.connection.execute "CREATE TABLE posts (id INTEGER PRIMARY KEY , title VARCHAR(255), content VARCHAR(255), published BOOLEAN , poster_id INTEGER);"

Comment.connection.execute "DROP TABLE IF EXISTS comments;"
Comment.connection.execute "CREATE TABLE comments (id INTEGER PRIMARY KEY , post_id INTEGER, body VARCHAR(255));"

Vote.connection.execute "DROP TABLE IF EXISTS votes;"
Vote.connection.execute "CREATE TABLE votes (id INTEGER PRIMARY KEY, votable_id INTEGER, votable_type VARCHAR(255));"

Tag.connection.execute "DROP TABLE IF EXISTS tags;"
Tag.connection.execute "CREATE TABLE tags (id INTEGER PRIMARY KEY, vote_id INTEGER, tag_id INTEGER);"
