# User: janmejay.singh
# Time: 16 Jun, 2008 8:11:31 PM

unless defined?(BAKERY_CONFIGURATION_DEFINED)
  BAKERY_CONFIGURATION_DEFINED = true
  $LOAD_PATH << File.dirname(__FILE__) + '/../lib/x86-linux' if RUBY_PLATFORM =~ /86-linux/
  $LOAD_PATH << File.dirname(__FILE__) + '/../lib/x86_64-linux' if RUBY_PLATFORM =~ /86_64-linux/
  $LOAD_PATH << File.dirname(__FILE__)
end

$LOAD_PATH << File.dirname(__FILE__)

require "rubygems"
require 'gosu'
require File.join('util', 'util')
require 'game_wizard'