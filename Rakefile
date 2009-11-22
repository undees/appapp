require 'fileutils'
require 'rubygems'
require 'rubygems/commands/unpack_command'
require 'rawr'
require 'fastercsv'
require 'lib/ruby/models'

Gems = %w(activerecord
          activerecord-jdbc-adapter
          activerecord-jdbcsqlite3-adapter
          activesupport
          haml
          jdbc-sqlite3
          rack
          sinatra)

desc 'Write version numbers of installed gems into app'
task :update_vendor do |t|
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
task :unpack_gems do
  unpack = Gem::Commands::UnpackCommand.new
  unpack.options[:target] = 'lib/ruby'
  unpack.options[:args] = Gems

  unpack.execute
end

desc 'Remove unpacked gems from our lib/ruby'
task :clobber_gems do
  Gems.each do |gem|
    Dir["lib/ruby/#{gem}*"].grep(/#{gem}-[.0-9]+/).each do |dir|
      FileUtils.rm_rf dir
    end
  end
end

desc 'Extract jars from our gems into staging area'
task :extract_gem_jars do
  Dir['lib/ruby/**/*.jar'].each do |jar|
    path = File.expand_path(jar)

    Dir.chdir 'package/classes' do
      sh "jar -xf #{path}"
    end
  end
end

desc 'Extract app and jruby-complete for later combining'
task :stage_big_jar do
  Dir.chdir('package/bigjar/contents') do
    sh 'jar -xf ../../jar/appapp.jar'
    sh 'jar -xf ../../jar/lib/java/jruby-complete.jar'
  end
end

desc 'Point the big jar manifest at our app'
task :tweak_manifest do
  manifest = IO.read 'package/bigjar/contents/META-INF/MANIFEST.MF'
  manifest.gsub! /^Main-Class: .+$/, 'Main-Class: org.rubyforge.rawr.Main'
  File.open('package/bigjar/manifest', 'w') {|f| f.write manifest}
end

desc 'Combine staged app and jruby-complete files into one jar'
task :big_jar do
  Dir.chdir('package/bigjar') do
    sh 'jar -cfm appapp.jar manifest -C contents/ .'
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

desc 'Create empty app database'
task :create_db do
  AddAppsTable.migrate(:up)
  AddCategoriesTable.migrate(:up)
end

desc 'Populate empty app database from CSV file'
task :populate_db do
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
