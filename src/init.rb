# User: janmejay.singh
# Time: 16 Jun, 2008 8:11:31 PM

$version = "in-development"

unless defined?(BAKERY_CONFIGURATION_DEFINED)
  BAKERY_CONFIGURATION_DEFINED = true
  $LOAD_PATH << File.dirname(__FILE__) + '/../lib/x86-linux' if RUBY_PLATFORM =~ /86-linux/
  $LOAD_PATH << File.dirname(__FILE__) + '/../lib/x86_64-linux' if RUBY_PLATFORM =~ /86_64-linux/
  $LOAD_PATH << File.dirname(__FILE__)
end

$LOAD_PATH << File.dirname(__FILE__)

$BAKERY_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$BAKERY_TMP = File.join($BAKERY_HOME, 'tmp')

$PLAYER_DATA_BASE_PATH = File.join($BAKERY_TMP, '#name#')
$SAVED_GAMES_DIR = File.join($BAKERY_TMP, '#name#', 'saved_games')
$LAST_PLAYED_GAME_PATH = File.join($BAKERY_TMP, '#name#', 'last_played')

require "rubygems"
require 'gosu'
require 'yaml'
require 'util/actions'
require 'logger'
require File.join('util', 'util')
require 'fileutils'
FileUtils.mkdir_p($BAKERY_TMP)

$logger = Logger.new($BAKERY_LOG_FILE = File.join($BAKERY_HOME, 'tmp', 'bakery.log'))
$logger.level = Logger::DEBUG

$death_trace_file = File.join($BAKERY_HOME, 'tmp', 'death_stack_trace')