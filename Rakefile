require 'rubygems'
require 'rake'

namespace :bakery do
  desc "Run all the tests"
  task :test do
    FileList['test/**/*_test.rb', 'test/*_test.rb'].each do |file_path|
      require file_path
    end
  end
end

task :default => 'bakery:test'