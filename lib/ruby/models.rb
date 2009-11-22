db_file = Dir.pwd + '/appapp.sqlite3'

ActiveRecord::Base.establish_connection \
  :adapter => 'jdbcsqlite3',
  :database => db_file

class App < ActiveRecord::Base
  belongs_to :category

  named_scope :awesome, :conditions => {:rank => 1..10}
  named_scope :of_type, lambda {|cat| {:conditions => {:category_id => cat}}}
end

class Category < ActiveRecord::Base
  has_many :apps
end
