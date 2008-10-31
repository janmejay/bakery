require 'rubygems'
require 'rake'
require File.join(File.dirname(__FILE__), 'src', 'init')
require 'customer'

namespace :bakery do
  desc "Run all the tests"
  task :test do
    FileList['test/**/*_test.rb', 'test/*_test.rb'].each do |file_path|
      require file_path
    end
  end
  
  namespace :reporting do
    namespace :customers do
      
      def aggregation_for map, criteria
        value = criteria.kind_of?(Array) ? criteria.inject(1) {|inj, crit| map[crit]*inj } : map[criteria]
        value.is_a?(Symbol) ? value.to_s : value
      end
      
      def print_sort_on criteria
        Customer::CUSTOMER_CONFIG.sort do |one, other|
          aggregation_for(one[1], criteria) <=> aggregation_for(other[1], criteria)
        end.each do |customer_details|
          values = Array(criteria).inject([]) {|inj, crit| inj << "#{crit} -> #{customer_details[1][crit]}"}
          puts "#{customer_details[0]} -> {#{values.join(', ')}}"
        end
      end
      
      def task_for display_name, *sorted_on
        desc "Show customers sorted on #{display_name}[#{sorted_on.join("*")}]"
        task display_name do
          print_sort_on(sorted_on.length > 1 ? sorted_on : sorted_on[0])
        end
      end
      
      task_for :patience_count, :patience_count
      
      task_for :patience_factor, :patience_factor
      
      task_for :patience, :patience_factor, :patience_count
      
      task_for :cost_inclination, :cost_inclination
    end
  end
end

task :default => 'bakery:test'