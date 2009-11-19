require 'activerecord'
require 'active_record/connection_adapters/jdbc_adapter'

db_file = Dir.pwd + '/appapp.sqlite3'

ActiveRecord::Base.establish_connection \
  :adapter => 'jdbcsqlite3',
  :database => db_file
