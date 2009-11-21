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

def backtick(command)
  `#{command}`
  raise "#{command} returned error #{$?}" unless $? == 0
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
      backtick "jar -xf #{path}"
    end
  end
end

desc 'Extract app and jruby-complete for later combining'
task :stage_big_jar do
  Dir.chdir('package/bigjar/contents') do
    backtick 'jar -xf ../../jar/appapp.jar'
    backtick 'jar -xf ../../jar/lib/java/jruby-complete.jar'
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
    backtick 'jar -cfm appapp.jar manifest -C contents/ .'
  end
end
