require 'activerecord'

db_file = File.expand_path(File.dirname(__FILE__)) +
  '/appapp.sqlite3'

ActiveRecord::Base.establish_connection \
  :adapter => 'jdbcsqlite3',
  :database => db_file
