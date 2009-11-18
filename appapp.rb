require 'sinatra'
require 'haml'
require 'connect'

class App < ActiveRecord::Base
end

get '/' do
  haml :index
end

__END__
"

@@ layout
!!!
%html
  = yield

@@ index
%p= App.count
