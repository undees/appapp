require 'fileutils'
require 'rubygems'
require 'rubygems/commands/unpack_command'
require 'rake/clean'
require 'rawr'

task :default => %w(
  gems:bundle
  gems:unjar
  rawr:jar
  app:stage app:manifest app:package)

# rawr will remove the entire package/ dir for us
task :clobber => 'rawr:clean'

# TODO: see if Bundler has a clean/clobber mechanism

# jars extracted from gems are considered intermediate build products
CLEAN.include 'package/classes'

namespace :gems do
  desc 'Extract gems into app directory'
  task :bundle do
    # TODO: go through Bundler's library instead of launching a process
    sh 'jruby -S bundle install lib/ruby --disable-shared-gems'
  end

  desc 'Configure app environment for installed gems'
  task :environment do |t|
    dirs = Dir.chdir('lib/ruby/gems') do
      Dir['*'].to_a
    end

    File.open('lib/ruby/environment.rb', 'w') do |f|
      f.puts "# This file is auto-generated;"
      f.puts "# use 'rake #{t}' to update it.\n\n"

      f.puts "gem_root = File.join(File.dirname(__FILE__), 'gems/')."
      f.puts "  gsub(%r(^/gems/$),'gems/')"
      f.puts

      f.puts "%w(" + dirs.join("\n   ") + ").each do |dir|"
      f.puts '  $: << "#{gem_root}#{dir}/lib"' # single quotes!
      f.puts "end"
    end
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

namespace :db do
  desc 'Create empty app database'
  task :create do
    require 'active_record'
    require 'active_record/connection_adapters/jdbc_adapter'
    require 'lib/ruby/models'

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

    AddAppsTable.migrate(:up)
    AddCategoriesTable.migrate(:up)
  end

  desc 'Populate empty app database from CSV file'
  task :populate do
    require 'active_record'
    require 'active_record/connection_adapters/jdbc_adapter'
    require 'lib/ruby/models'
    require 'fastercsv'

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
