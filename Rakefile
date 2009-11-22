require 'fileutils'
require 'rubygems'
require 'rubygems/commands/unpack_command'
require 'fastercsv'
require 'rake/clean'
require 'rawr'
require 'lib/ruby/models'

# rawr will remove the entire package/ dir for us
task :clobber => 'rawr:clean'

Gems = %w(activerecord
          activerecord-jdbc-adapter
          activerecord-jdbcsqlite3-adapter
          activesupport
          haml
          jdbc-sqlite3
          rack
          sinatra)

# vendored gems are considered intermediate build products
Gems.each do |gem|
  Dir["lib/ruby/#{gem}*"].grep(/#{gem}-[.0-9]+/).each do |dir|
    CLEAN.include dir
  end
end

# jars extracted from gems are considered intermediate build products
CLEAN.include 'package/classes'

namespace :gems do
  desc 'Write version numbers of installed gems into app'
  task :vendor do |t|
    dirs = Gems.map do |gem|
      dependency = Gem::Dependency.new gem, nil
      version    = Gem.source_index.search(dependency).last.version.to_s
      "#{gem}-#{version}"
    end

    File.open('lib/ruby/vendor_everything.rb', 'w') do |f|
      f.puts "# This file is auto-generated; use 'rake #{t}' to update it.\n\n"

      f.puts "%w(" + dirs.join("\n   ") + ").each do |dir|"
      f.puts '  $: << File.dirname(__FILE__) + "/#{dir}/lib"' # single quotes!
      f.puts "end"
    end
  end

  desc 'Unpack installed gems into our lib/ruby'
  task :unpack do
    unpack = Gem::Commands::UnpackCommand.new
    unpack.options[:target] = 'lib/ruby'
    unpack.options[:args] = Gems

    unpack.execute
  end

  directory 'package/classes'

  desc 'Extract jars from our gems into staging area'
  task :unjar => 'package/classes' do
    Dir['lib/ruby/**/*.jar'].each do |jar|
      path = File.expand_path(jar)

      Dir.chdir 'package/classes' do
        sh "jar -xf #{path}"
      end
    end
  end
end

namespace :app do
  directory 'package/bigjar/contents'

  desc 'Extract app and jruby-complete for later combining'
  task :stage => 'package/bigjar/contents' do
    Dir.chdir('package/bigjar/contents') do
      sh 'jar -xf ../../jar/appapp.jar'
      sh 'jar -xf ../../jar/lib/java/jruby-complete.jar'
    end
  end

  desc 'Point the big jar manifest at our app'
  task :manifest do
    manifest = IO.read 'package/bigjar/contents/META-INF/MANIFEST.MF'
    manifest.gsub! /^Main-Class: .+$/, 'Main-Class: org.rubyforge.rawr.Main'
    File.open('package/bigjar/manifest', 'w') {|f| f.write manifest}
  end

  desc 'Combine staged app and jruby-complete files into one jar'
  task :package do
    Dir.chdir('package/bigjar') do
      sh 'jar -cfm appapp.jar manifest -C contents/ .'
    end
  end
end

class AddCategoriesTable < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :categories
  end
end

class AddAppsTable < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|
      t.string  :name
      t.integer :rank
      t.integer :category_id
      t.decimal :price, :scale => 2
      t.date    :released_on
    end
  end

  def self.down
    drop_table :apps
  end
end

namespace :db do
  desc 'Create empty app database'
  task :createb do
    AddAppsTable.migrate(:up)
    AddCategoriesTable.migrate(:up)
  end

  desc 'Populate empty app database from CSV file'
  task :populate do
    categories = {}

    FasterCSV.foreach('apps.csv') do |row|
      next if row[0] == 'name' # header

      name, rank, list, price, released_on, _, _ = row

      cat = /(.+) Full List$/.match(list)[1].downcase.gsub(' ', '_')
      unless categories[cat]
        categories[cat] = (Category.create :name => cat).id
      end

      App.create(:name => name,
                 :rank => rank.to_i,
                 :category_id => categories[cat],
                 :price => price,
                 :released_on => Date.parse(released_on))
    end
  end
end
