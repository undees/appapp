Gems = %w(activerecord-2.3.4
          activerecord-jdbc-adapter-0.9.2
          activerecord-jdbcsqlite3-adapter-0.9.2
          activesupport-2.3.4
          haml-2.2.13
          jdbc-sqlite3-3.6.3.054
          rack-1.0.1
          sinatra-0.9.4)

Gems.each do |gem|
  $: << File.dirname(__FILE__) + "/#{gem}/lib"
end

$: << File.dirname(__FILE__)

require 'sinatra/base'
require 'haml'
require 'connect'

class App < ActiveRecord::Base
  belongs_to :category
end

class Category < ActiveRecord::Base
  has_many :apps
end

class AppApp < Sinatra::Base
  use_in_file_templates!

  get '/' do
    haml :index
  end
end

AppApp.run!

__END__
"

@@ layout
!!!
%html
  = yield

@@ index
%p= App.first.category.name
