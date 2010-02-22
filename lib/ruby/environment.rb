# This file is auto-generated;
# use 'rake gems:environment' to update it.

gem_root = File.join(File.dirname(__FILE__), 'gems/').
  gsub(%r(^/gems/$),'gems/')

%w(activerecord-2.3.5
   activerecord-jdbc-adapter-0.9.2
   activerecord-jdbcsqlite3-adapter-0.9.2
   activesupport-2.3.5
   haml-2.2.20
   jdbc-sqlite3-3.6.3.054
   rack-1.1.0
   sinatra-0.9.4).each do |dir|
  $: << "#{gem_root}#{dir}/lib"
end
