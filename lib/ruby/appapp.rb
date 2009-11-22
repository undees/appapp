$: << File.dirname(__FILE__)
require 'environment'

require 'activesupport'
require 'activerecord'
require 'haml'
require 'rack'
require 'sinatra/base'

require 'models'

class AppApp < Sinatra::Base
  use_in_file_templates!

  get '/' do
    haml :index
  end

  get '/category/:cat' do
    @category = Category.find :first, :conditions => {:name => params[:cat]}
    haml :category
  end

  get '/app/:id' do
    @app = App.find params[:id]
    @place = ActiveSupport::Inflector.ordinalize(@app.rank)
    haml :app
  end
end

AppApp.run!

__END__
<<EOF

@@ layout
!!!
%html
  = yield

@@ index
%h1 the app app
- Category.find(:all).each do |cat|
  %h2
    top
    %a{:href => "/category/#{cat.name}"} #{cat.name}
  %ol
  - App.of_type(cat).awesome.each do |app|
    %li
      %a{:href => "/app/#{app.id}"} #{app.name}

@@ category
%h1= @category.name
%ol
- App.of_type(@category).find(:all).each do |app|
  %li
    %a{:href => "/app/#{app.id}"} #{app.name}

@@ app
%h1= @app.name
%dl
  %dt Rank:
  %dd #{@place} in #{@app.category.name}
  %dt Price:
  %dd= @app.price
  %dt Released on:
  %dd= @app.released_on
