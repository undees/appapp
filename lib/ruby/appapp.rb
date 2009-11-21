$: << File.dirname(__FILE__)
require 'vendor_everything'
require 'sinatra/base'
require 'haml'
require 'models'

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
%p
  = Category.first.apps.count
  = Category.first.name
  app(s)
