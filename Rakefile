require 'fileutils'
require 'rubygems'
require 'rubygems/commands/unpack_command'
require 'rawr'

Gems = %w(activerecord
          activerecord-jdbc-adapter
          activerecord-jdbcsqlite3-adapter
          activesupport
          haml
          jdbc-sqlite3
          rack
          sinatra)

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
task :extract_jars do
  Dir["lib/ruby/**/*.jar"].each do |jar|
    path = File.expand_path(jar)

    Dir.chdir 'package/classes' do
      `jar -xf #{path}`
    end
  end
end
